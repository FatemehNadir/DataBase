-- DATABASE DESIGN 1 3991 @ IUT
-- YOUR NAME: Fatemeh Nadi
-- YOUR STUDENT NUMBER: 9636753


---- Q1a
select 
		id , name , dept_name , salary , 
		LAG(salary , 1) over (partition by dept_name order by salary )  as lower_salary
from instructor
order by dept_name , salary desc


---- Q1b
select * , 
		dense_rank () over (order by tot_cred desc)
from student

---- Q2

-- create table 
CREATE TABLE  Turn_Over (
   Dep_Id  int,
   Trn_Time TIMESTAMP,
   Trn_Over int
);

-- insert value

INSERT INTO public.turn_over(
	dep_id, trn_time, trn_over)
	VALUES (1022, '2018-06-15 14:00', 100);
INSERT INTO public.turn_over(
	dep_id, trn_time, trn_over)
	VALUES (1022, '2018-06-15 14:28', -50);
INSERT INTO public.turn_over(
	dep_id, trn_time, trn_over)
	VALUES (1022, '2018-06-16 14:58', 25);
INSERT INTO public.turn_over(
	dep_id, trn_time, trn_over)
	VALUES (1067, '2019-07-18 23:32', 300);
-- question wana
select * ,  
		 sum(trn_over) over 
        (partition by dep_id 
         order by trn_time 
        )  as Balance
from Turn_Over
order by trn_time

---- Q3a

select payment_id, customer_id,payment_date,amount ,
		avg(amount) over (partition by customer_id order by payment_date) as avg_before
		,
		(sum(amount) over (partition by customer_id order by payment_date desc) - amount) as sum_after
from payment

---- Q3b
with 
sumPcus (customer_id , amount_sum) as(
select customer_id , sum(amount)
from payment
group by customer_id
) ,
allnt as
(select first_name, last_name , ntile(4) over ( order by amount_sum desc ) as nt
from sumPcus JOIN customer ON (sumPcus.customer_id = customer.customer_id ) 
)
select first_name, last_name  from allnt where nt = 1


---- Q3c

with 
av  (payment_id , customer_id ,payment_date , amount ,avg) as
(
	select payment_id , customer_id ,payment_date,amount,(select avg(amount) from payment as B where A.customer_id = B.customer_id and B.payment_date<=A.payment_date)
	from payment as A
	order by customer_id
),
su (payment_id , customer_id , sum) as
(
	select payment_id , customer_id ,(select sum(amount) from payment as B where A.customer_id = B.customer_id and A.payment_date<=B.payment_date)-amount
	from payment as A
	order by customer_id
)
select av.payment_id ,av.customer_id ,av.payment_date, amount,avg , sum
from av JOIN su ON (av.payment_id = su.payment_id and av.customer_id = su.customer_id)
order by av.customer_id , av.payment_date  

---- Q3d
select country, city, count(distinct customer.customer_id) numOfcustomer , count(distinct rental.rental_id)  numOfrental
from customer 
			join address	on(customer.address_id = address.address_id)
            join city		on(city.city_id = address.city_id)
            join country  	on(country.country_id = city.country_id)
            join rental   	on(rental.customer_id = customer.customer_id)
group by grouping sets((country), (country , city))

---- Q3e
select  category.name ,rental_rate , count(distinct film.film_id) numOffilm
from category 
			join film_category on(category.category_id = film_category.category_id)
            join film on(film_category.film_id = film.film_id)
group by
grouping sets(
  (),
  (rental_rate),
  (rental_rate , category.name)
)
order by category.name ,rental_rate

---- Q3f
select city.city_id , payment_date , count(distinct payment.payment_id) as numOfpay
from payment 
			join customer	on(customer.customer_id = payment.customer_id)
            join address	on(address.address_id = customer.address_id )
      		join city  		on(city.city_id = address.city_id)
group by cube(city.city_id , payment.payment_date)
