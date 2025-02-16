select c.customer_id, c.first_name, c.last_name, count(r.rental_id) as total_rentals 
from public.customer c 
join rental r on c.customer_id = r.customer_id 
where EXTRACT(YEAR FROM r.rental_date) = 2017
group by c.customer_id , c.first_name , c.last_name 
order by total_rentals desc 
limit 1;


-- Retrieve a customer with the most rentals in 2017 year
select * from customer c 
select movie_id, title, income from film f 
order by income desc 
limit 3;

select * from payment p 
select * from rental r 
select film_id, title, release_year from film f; 

-- Get a list of the three highest-income movies in 2017 with income under $30.
-- 3
-- highest-income
-- 2017
-- income under 30$

SELECT f.title, 
       SUM(p.amount) AS total_income
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE EXTRACT(YEAR FROM r.rental_date) = 2017
GROUP BY f.title
HAVING SUM(p.amount) < 30
ORDER BY total_income DESC
LIMIT 3;


