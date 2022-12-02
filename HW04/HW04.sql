-- DATABASE DESIGN 1 3991 @ IUT
-- YOUR NAME: Fatemeh Nadi
-- YOUR STUDENT NUMBER: 9636753


---- Q01

------ a
create view customer_29994 as
(
select *
from sales.salesorderheader
where customerid = 29994 and
current_date - sales.salesorderheader.orderdate <= interval '1 day'
)


create user "29994"

set session authorization "29994"

update customer_29994
set orderdate = current_date

set session authorization 'postgres'


grant update on customer_29994 to "29994"

set session authorization "29994"


update customer_29994
set orderdate = current_date


------ b
-- first create default table


CREATE TABLE production.InventoryDefaults
(
    productid integer NOT NULL,
    locationid smallint NOT NULL,
    shelf character varying(10) COLLATE pg_catalog."default" NOT NULL,
    bin smallint NOT NULL,
    PRIMARY KEY (productid, locationid),
    FOREIGN KEY (locationid)
        REFERENCES production.location (locationid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    FOREIGN KEY (productid)
        REFERENCES production.product (productid) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CHECK (bin >= 0 AND bin <= 100)
)

-- define procedure 

create or replace procedure transfer(
    product_id int,
    source_id int, 
    destination_id int,
    num int
)
language plpgsql    
as $$
declare
  tshelf 	integer;
  tbin 		integer;
begin
    
    update production.productinventory
    set quantity = quantity - num 
    where productid = product_id and
    locationid = source_id;

    if exists(
			select* 
			from production.productinventory 
            where productid = product_id and locationid = source_id) 
	then
			update 	production.productinventory
			set 	bin = bin + 1, quantity = quantity + num 
			where 	productid = product_id	and	locationid = destination_id;
    else
			tshelf = (
						select shelf 
						from  production.InventoryDefaults 
						where productid = product_id and locationid = source_id
			);
			tbin = (
						select bin 
						from  production.InventoryDefaults 
						where productid = product_id and locationid = source_id
			);
			insert into production.productinventory(productid,locationid,shelf, bin,quantity)
			values (product_id,destination_id,tshelf, tbin,num);
    end if;

    commit;
end;$$








---- Q02

------ a
create table RegistrationLog(
StudentID       varchar(5) ,
Semester character varying(6) COLLATE pg_catalog."default" NOT NULL,
Year numeric(4,0) NOT NULL,
Status          varchar(12) check (Status in('Normal','NotReg','CheckUnder','CheckOver')),
OverAttempts    int default 0,
foreign key (StudentID) references Student (ID),
primary key (StudentID,semester,year)
  
);

------ b

create or Replace procedure Register(
    temp_StudentID	varchar(5),
	incourse		varchar(8),
	temp_Semester	varchar(6),
	temp_sec		varchar(8),
	temp_Year		numeric(4,0)
)
language plpgsql    
as $$
declare
  precreds integer;
begin
	precreds = (select sum(credits)
	from takes JOIN course USING (course_id)
	where takes.id = temp_StudentID and takes.semester = temp_Semester and takes.sec_id  = temp_sec and takes.year = temp_Year 
);
	insert into RegistrationLog  
  	select distinct temp_StudentID,temp_Semester,temp_Year,'Normal',0
    where not exists (
      select * 
      from RegistrationLog
      where 
        RegistrationLog.StudentID    	= temp_StudentID	and
        RegistrationLog.Semester 		= temp_Semester	and
        RegistrationLog.year     		= temp_Year
    );  
  
  	if precreds <= 20 then
		insert into takes values (temp_StudentID, incourse, temp_sec, temp_Semester, temp_Year);
  		update RegistrationLog
  		set Status 		= 'Normal'
  		where 
			(
			StudentID 	= temp_StudentID	and
			Semester 	= temp_Semester		and
			Year		= temp_Year
			);
	
	else
		update RegistrationLog
  		set 			OverAttempts =	OverAttempts + 1
  		where 
		StudentID    	= temp_StudentID		and 
		Semester 		= temp_Semester			and 
		Year    		= temp_Year				;
  
  	end if;

  commit;
end; $$






-- call Register('38548','401','1','Fall','2003')



------ c

create function under12()
  returns trigger 
  language PLPGSQL
  as
$$
declare
  sumcreds integer;
begin
  sumcreds = (select sum(course.credits) 
					FROM course JOIN takes USING (course_id)
                	where takes.id = new.id);
  
  if sumcreds < 12 
  then
    update RegistrationLog  
    set Status = 'CheckUnder'
    where new.id = RegistrationLog.StudentID;
  elsif sumcreds > 18 then
    update RegistrationLog  
    set Status = 'CheckOver'
    where new.id = RegistrationLog.StudentID;
  end if;

  RETURN NEW;
end;
$$

-- trigger


CREATE TRIGGER checkstatus
AFTER UPDATE OR INSERT ON takes
FOR EACH ROW
EXECUTE PROCEDURE under12();



---- Q03

------ a
Create table category_rating(
category_name 	character varying(25) COLLATE pg_catalog."default" NOT NULL,
avg_rental_rate numeric(4,2) NOT NULL DEFAULT 4.99 ,
avg_len			smallint
);

INSERT INTO category_rating 
select category.name , avg(film.rental_rate) , avg(length)
from film 
		JOIN film_category 	ON (film.film_id = film_category.film_id )
		JOIN category		ON (film_category.category_id = category.category_id)
		
group by category.name
create or replace procedure dropping()
language plpgsql    
as $$
declare
  tri_len  integer;
begin

  tri_len  = (
    select avg(average_rental_rate)
    from (
      select average_rental_rate 
      from category_rating 
      order by average_rental_rate  desc
      limit 3 ) as cat_ret
  );

    delete from category_rating
    where average_rental_rate >= top_three_avg;
      

  commit;
end; $$



------ b
create function Award ( tdate timestamp )
returns integer
language plpgsql
as
$$
declare
   s integer;
begin
   s = (
     select count(*) 
     from rental as r
     where tdate between r.rental_date and r.return_date );
     
   if s > 0 then
       return 1;
   else
       return 0;
  end if;
end;
$$;
------ c

create or replace function over7()
  returns trigger 
  language PLPGSQL
  as
$$
declare
   storeID integer ; 
   invID integer ; 
   endrentalID integer;
begin

  if new.amount > 7 then
  
  	storeID = (
      select inventory.store_id
      from payment join rental  on (payment.rental_id = rental.rental_id)
      join inventory  on (rental.inventory_id = inventory.inventory_id)
      where new.payment_id = payment.payment_id
    );
  
  
  	invID  = (
      select inventory.inventory_id
      from payment join rental on (payment.rental_id = rental.rental_id)
      join inventory  on (rental.inventory_id = inventory.inventory_id)
      where storeID = 	inventory.store_id and 
						rental.return_date <= now() and 
						rental.return_date is not null and 
						payment.payment_id <> new.payment_id
      limit 1
    );
	
    
    
    
		insert into rental(rental_date, inventory_id, customer_id, return_date, staff_id)
		values(now() , invID , new.customer_id , null , new.staff_id)
		returning rental_id into endrentalID;

		insert into payment (customer_id, staff_id, rental_id, amount, payment_date)
		values (new.customer_id , new.staff_id , last_rental_id , 0 , now());

  end if;
  
  RETURN NEW;
end;
$$



---- trigger

create trigger gift
    AFTER UPDATE or INSERT ON payment
    FOR EACH ROW
    EXECUTE PROCEDURE over7();
	
	


------ d
create view V1_inv as
(
  select *
  from inventory
);

create role "staff_order";


grant SELECT on V1_inv to "staff_order";


create view V2_staff as
(
  select *
  from staff
);



create role "staff_ceo";



grant SELECT,DELETE,INSERT,update on V1_inv to "staff_ceo";
grant SELECT,DELETE,INSERT,update on V2_staff to "staff_ceo";



------ e

