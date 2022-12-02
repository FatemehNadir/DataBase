-- DATABASE DESIGN 1 3991 @ IUT
-- YOUR NAME:
-- YOUR STUDENT NUMBER:


---- Q9-A
select dept_name
from department
where budget > (
				select budget 
				from department
				where dept_name = 'Psychology'
				)
order by dept_name ASC

---- Q9-B


select id, course_id
from takes
group by id, course_id
having count(*) > 2


---- Q9-C

select distinct I.id , I.name
from instructor as I
where not exists(
					select course_id
					from course
					where dept_name = I.dept_name
					except
					(
						select T.course_id
						from teaches as T
						where I.id = T.id
					)

)



---- Q9-D

select name
from student
where name like '___' and dept_name = 'History'



---- Q10-A

select first_name , last_name , city.city
from 	customer , address ,city , country 
where  	customer.first_name like '_____' and
		customer.address_id = address.address_id and 
		address.city_id = city.city_id and 
		country.country_id = city.country_id  and 
		country.country = 'Iran'
					


---- Q10-B

select *
from film , inventory as inv , rental as r
where length<100 and rental_rate<2 and inv.film_id = film.film_id and inv.store_id = 2 and  inv.inventory_id = r.inventory_id and DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) * 24 + 
               DATE_PART('hour',r.return_date::timestamp - r.rental_date::timestamp)<24


---- Q10-C

select distinct  actor.first_name,actor.last_name
from film_actor , actor, film
where film_actor.actor_id = actor.actor_id and film_actor.film_id = film.film_id and film.rental_rate>4  and
  not exists (
		select *
		from film_actor as FC , film as F
		where FC.actor_id = actor.actor_id and FC.film_id = F.film_id and F.length>180 

	)

******************

with longTime (actor_id , rate) as (
select actor.actor_id , rental_rate
from  film_actor , actor, film 
where film_actor.actor_id = actor.actor_id and film_actor.film_id = film.film_id and film.length>180  
					
)
select distinct  actor.first_name,actor.last_name
from  actor,longTime 
where rate > 4 and
		not exists(
		select *
		from longTime
		where actor.actor_id = longTime.actor_id
	)




---- Q10-D

(
select distinct  actor.first_name,actor.last_name
from film_actor , actor, film
where film_actor.actor_id = actor.actor_id and film_actor.film_id = film.film_id and film.rental_rate>4
)	
		
union 
(
select distinct first_name, last_name
from customer as c, rental as r, inventory as inv, film
where 	c.customer_id = r.customer_id and
 		r.inventory_id = inv.inventory_id and
		rental_rate < 1 and
 		inv.film_id = film.film_id and
		DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) * 24 + 
        DATE_PART('hour',r.return_date::timestamp - r.rental_date::timestamp)<24
)

---- Q10-E

with min_rate (rate) as (
select min(rental_rate)
from film
where length >184
	)
	
select distinct  actor.first_name,actor.last_name
from  film_actor , actor, film , min_rate
where film_actor.actor_id = actor.actor_id and film_actor.film_id = film.film_id and film.rental_rate < min_rate.rate


---- Q10-F


select customer_id, count(*), sum(amount)
from payment
group by customer_id
having count(*) < 15


---- Q10-G


with countperCustomer (customer_id,num) as(
select customer_id, count(*)
from payment
group by customer_id
)

select customer_id
from countperCustomer
where countperCustomer.num > (
							select avg(num)
							from countperCustomer)


---- Q10-H

with rank (category_id, max_len , max_rate) as(
select category_id, max(length), max(rental_rate)
from film, film_category
where film.film_id = film_category.film_id
group by category_id
)
select distinct title
from  film, film_category , rank
where 	film.film_id = film_category.film_id and 
		rank.category_id = film_category.category_id and 
		(
			(rank.max_len , rank.max_rate) = (film.length,film.rental_rate)  OR 
			rank.max_len = film.length OR
		 	rank.max_rate  = film.rental_rate
		)


---- Q10-I


select name, count(*)
from rental as r, inventory as inv, film_category, category as c
where 	r.inventory_id = inv.inventory_id and
		inv.film_id = film_category.film_id and
		c.category_id = film_category.category_id
group by name

---- Q10-J



---- Q10-K

select c.name , s.count as soon , e.count as exact_time , l.count as late  
from (select category_id , count(time) from(select f_c.category_id , f.rental_duration - DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) as time
    from film as f , inventory as i , rental as r , film_category as f_c
    where f_c.film_id = f.film_id and i.film_id = f.film_id and i.inventory_id = r.inventory_id 
    and DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) < f.rental_duration ) as s
    group by category_id) as s,
    
  (select category_id , count(time) from(select f_c.category_id  , f.rental_duration - DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) as time
  from film as f , inventory as i , rental as r , film_category as f_c
  where f_c.film_id = f.film_id and i.film_id = f.film_id and i.inventory_id = r.inventory_id 
  and DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) = f.rental_duration ) as e
   group by category_id) as e,
  
  (select category_id , count(time) from(select f_c.category_id , f.rental_duration - DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) as time
  from film as f , inventory as i , rental as r , film_category as f_c
  where f_c.film_id = f.film_id and i.film_id = f.film_id and i.inventory_id = r.inventory_id 
  and DATE_PART('day', r.return_date::timestamp - r.rental_date::timestamp) > f.rental_duration) as l
  group by category_id) as l,
  category as c
  
where c.category_id = s.category_id and e.category_id = l.category_id and s.category_id = e.category_id
