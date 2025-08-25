Q1. who is the senior most employee  based on the job title?

select * from employee
order by levels desc

limit 1

Q2: which countries have the most Invoices?

-- select * from invoice   comment line check tables 
select count(*) as  c,  billing_country from invoice

group by billing_country
order by c desc

-- print the most two country invoice: use limit 2 
limit 2 

Q3: What are top 3 values of total invoice ?
-- frist select the table 
select * from invoice
-- total column are persent in table 
select total from invoice
order by total desc
limit 3   -- top 3 chaiye tho print used limit 3

Q4: which city has the best customers? We would like to throw a 
promotional Music festival in the city we made the most money. write 
a query that returns one city that has the highest sum of invoice totals.
Return both the city names & sum of all invoice totals.

select * from invoice
-- mainly focus above ques. two parameters city & total invoic.

select SUM(total) as invoice_total , billing_city 
from invoice

group by billing_city
order by invoice_total desc


Q5: Who is the best customer? The customer who has spent the most money will 
be declared the best customer. write a query that return the person 
who has spent the most money.

select * from customer  -- customer table mein invoice se related column nhi hai

-- using scheme - move to another tables make a relation.
select customer.customer_id, customer.first_name, customer.last_name , sum(invoice.total) as total 
from customer 

-- useing join 
join invoice on customer.customer_id = invoice.customer_id

group by customer.customer_id
order by total desc
limit 1   -- best customer is customer_id 5, first_name & last_name = R & Madhav
 

-- Question Set2 - Moderate Levels:
Q1. write query to return the email, first name, last name, & Genre of all Rock Music Listeners.
Return your list ordered aplphabetically by email starting with A .

-- select the customer table need to email, first , last name.

select distinct email ,first_name , last_name from customer 

join invoice ON customer.customer_id = invoice.customer_id
join invoice_line ON invoice.invoice_id = invoice_line.invoice_id
-- condition inner 
where track_id IN (
      select track_id from track
	  join genre ON track.genre_id = genre.genre_id
	  where genre.name LIKE 'Rock'
)
order by email;
