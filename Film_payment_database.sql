-- Basic
-- Q1. Find out distinct ratings of films and show them based on their rental durations.

SELECT DISTINCT rating, rental_duration 
	FROM Film  
	ORDER BY rental_duration DESC

--Q2. Find out the customers who have made the payment of more than $9.99. show limited number of customers.
SELECT customer_id, amount  
	FROM payment 
	WHERE amount > 9.99 
	ORDER BY customer_id DESC 
	LIMIT 8

-- Q3. which of the 2 staff_ids are responsible for more payment and who is responsible for higher payment amount if we don’t consider amount equals to 0.

SELECT staff_id, SUM(amount), count(amount) 
	FROM payment 
	WHERE amount<>0 
	GROUP BY staff_id

-- Q4.find out the average payment amount grouped by customer and day-consider only the customer/dates with more than 1 payment.
SELECT customer_id, DATE(payment_date) AS dates, count(*), ROUND(AVG(amount),2) AS averageamount
	FROM payment 
GROUP BY customer_id,dates 
HAVING count(*)>1
ORDER BY dates


/* Intermediate 

	
 Q1. find out the month for highest payment amount. */

    SELECT payment_date, EXTRACT(month from payment_date) AS month_, 
SUM(amount) AS total_sum
FROM payment 
GROUP BY payment_date,
 month_
ORDER BY sum(amount) DESC

/* Q2. You want to create a tier list in the following way:
1. Rating is 'PG' or 'PG-13' or length is more then 210 min:'Great rating or long (tier 1)
2. Description contains 'Drama' and length is more than 90min:'Long drama (tier 2)'
3. Description contains 'Drama' and length is not more than 90min:'Short drama (tier 3)'
4. Rental_rate less than $1:'Very cheap (tier 4)'
If one movie can be in multiple categories it gets the higher tier assigned.How can you filter to only those movies that appear in one of these 4 tiers? */

  SELECT film.title,
	CASE 
	WHEN (rating IN ('PG','PG-13')) OR length > 210 THEN 'TIER 1'
	WHEN description ILIKE '%drama%' AND length> 90 THEN 'TIER 2'
	WHEN description ILIKE '%drama%' AND length < 90 THEN 'SHORT DRAMA'
	WHEN rental_rate <1.00 THEN 'VERY CHEAP'
	END AS REVIEWS

	FROM film
	WHERE 
	CASE 
	WHEN (rating IN ('PG','PG-13')) OR length > 210 THEN 'TIER 1'
	WHEN description ILIKE '%drama%' AND length> 90 THEN 'TIER 2'
	WHEN description ILIKE '%drama%' AND length < 90 THEN 'SHORT DRAMA'
	WHEN rental_rate <1.00 THEN 'VERY CHEAP'
	END IS NOT NULL 
 GROUP BY REVIEWS, film.title

--Q3. What are the customer’s(firstname, lastname, phone,district ) from texas?
 select first_name, last_name, phone, district , address, address2 from address as a
    FULL OUTER JOIN customer as c
    ON a.address_id = c.address_id
    WHERE district ILIKE 'Texas'


--Q4. Write a query to get firstname, lastname, email and country for allthe customers from brazil
  select first_name, last_name, email , ct.city_id 
	from customer as c 
            left join address as a
             ON c.address_id= a.address_id
            LEFT join city as ct
            ON ct.city_id = a.city_id
          LEFT join country as co
           on co.country_id = ct.country_id
           WHERE country ILIKE 'brazil'


-- Q5. union tojoin multiple tables

    select first_name,  'a' AS orgin  from actor
       UNION 
    SELECT first_name,  'c' from customer
       UNION 
    select first_name, 's' from staff 
      ORDER BY 2 DESC


/* Advance

	
 Q1. find out all the customer’s firstname and lastname that are from California and have spent more than $100 in total. */

   SELECT first_name, last_name 
   FROM customer 
   WHERE customer_id IN 
	(select customer_id 
	from payment 
	group by customer_id 
	having sum(amount)> 100)
 AND address_id IN
	( select address_id 
	from address 
	where district ILIKE 'california')


--Q2. Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendinglyand category filter is action.

  select p.payment_id, name, amount,title,
	(select sum(amount) from payment
	inner join rental as r
    on r.rental_id = p.rental_id
     inner join inventory as i
     on i.inventory_id = r.inventory_id
    inner join film_category as fc
     on fc.film_id = i.film_id
	inner join film fi
     on fi.film_id = fc.film_id
    inner join category ct2
	 on ct2.category_id = fc.category_id 
	where ct2.name = 'Action')
 from payment as p
      inner join rental as r
       on r.rental_id = p.rental_id
      inner join inventory as i
       on i.inventory_id = r.inventory_id
      inner join film_category as fc
      on fc.film_id = i.film_id
	inner join film fi
      on fi.film_id = fc.film_id
    inner join category ct1
	on ct1.category_id = fc.category_id 
	where name = 'Action'
    order by name ,payment_id 

  


/* Q3. write a query that returns the list of movies including: film_id, length, name as category, avg length based on category order by film_id. */
   select f.film_id, title, 
	length, name as category,  round(avg(length) over (partition by name),2)
		from film as f
    left join film_category as fc
     on f.film_id = fc.film_id
    left join category as c
     on c.category_id = fc.category_id
      order by film_id



/*Q4. show all the payment and the total payment based on paymentid also partition by customer id */

  select * ,
	sum(amount) over (partition by customer_id order by payment_id) 
  from payment


/* Q5. write a query that shows title, name and length also rank them based on length into each category */
  select f.title, c.name, f.length  ,

	DENSE_RANK () over(partition by name order by length )
  from film as f
   left join film_category as fc
    on f.film_id = fc.film_id
   Left join category as c
    on c.category_id= fc.category_id
































































































































