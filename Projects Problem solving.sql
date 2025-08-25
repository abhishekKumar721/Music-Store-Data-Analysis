Q1: who is the senior most employee  based on the job title?

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


Q2: Lets invite the artists who have written the most rock music 
    in our dataset . write a query that returns the Artists name 
	and total track count of the top 10 rock bands.

    select * from track -- check which row are reuired in this problem
-- step wise slove;
	select artist.artist_id, artist.name , Count(artist.artist_id) as number_of_songs
	from track

	join album ON album.album_id = track.album_id
	join artist ON artist.artist_id = album.artist_id
	join genre ON genre.genre_id = track.genre_id

	where genre.name = 'Rock'
    group by artist.artist_id   -- artist pe chaiye b/c kisne sab-se jayda signing of songs
	order by  number_of_songs DESC   -- sort kiya basis of NUmber of songs or count of songs.
	limit 10;  -- limit use b/c result mein top 10 hi chaiyethe .



Q3. Return all the track names that have a songs length longer than 
the average song length. Return the name and Milliseconds for each track. 
Order by the song length with the largest songs listed first.

-- above ques. are related track tables
select name, milliseconds from track

where milliseconds > (
            select avg (milliseconds) as avg_track_length 
			from track )		
			 
order by milliseconds DESC;




-- Question Set-3 : Advance levels

Q1.Find how much amount spent by each customeron artists? 
write a query to return customer name, aartist name and total spent.

-- above ques. has related to 3 tables of databases.
-- solve by CTE method - common table expression helps to create a temporary table .

-- CTE Syntax: with  cte _name_ as (inner_Query write)

WITH best_selling_artist AS (
     SELECT artist.artist_id AS artist_id , artist.name AS artist_name ,
	 SUM(invoice_line.unit_price * Invoice_line.quantity) AS Total_sales

	 FROM invoice_line 

	 --- data lane ke liye joint kar rahe hai..

	 JOIN track ON track.track_id = invoice_line.track_id
	 JOIN album ON album.album_id = track.album_id
	 JOIN artist ON artist.artist_id = album.artist_id

	 group by 1     -- 1 means:artist_id pe group kar rahe hai..
	 order by 3 desc   -- 3 means: sort by total_sales

	 limit 1    -- return of limit values prints
)
SELECT c.customer_id, c.first_name , c.last_name , bsa.artist_name,   
Sum(il.unit_price * il.quantity) AS amount_spent
from invoice i

join customer c ON c.customer_id = i.customer_id
join invoice_line il ON il.invoice_id = i.invoice_id
join track t ON t.track_id = il.track_id 
join album alb ON alb.album_id = t.album_id
join best_selling_artist bsa ON bsa.artist_id = alb.artist_id

group by 1, 2, 3,4
order by 5  DESC;



Q2: we want to find out the most popular music Genre for each country.
we determin the most popular genre as the genre with the Highest amount of purchases.
-- write a query that return each country along with the top genre.
for countries where the maximum number of purchases is shared return all Genre.


-- through CTE methods:

with popular_Genre As (
            select Count (invoice_line.quantity) As purchases , 
			customer.country , genre.name , genre.genre_id ,

			Row_number ()over(partition by customer.country order by count (invoice_line.quantity) DESC) AS
			RowNo
			from invoice_line

			join invoice ON invoice.invoice_id = invoice_line.invoice_id

			join customer ON customer.customer_id = invoice.customer_id
			join track ON track.track_id = invoice_line.track_id
			join genre ON genre.genre_id = track.genre_id

			group by 2,3,4
			order by 2 ASC , 1 DESC	
)
 select * from popular_Genre where RowNo <=1



--- Method 2. Recursive: similar to CTE
with recursive  sales_per_country AS (
               select Count(*) AS purchases_per_genre, customer.country , genre.name , genre.genre_id
			   from invoice_line

			   join invoice on invoice.invoice_id = invoice_line.invoice_id
			   join customer on customer.customer_id = invoice.customer_id
			   join track on track.track_id  = invoice_line.track_id
			   join genre on genre.genre_id  = track.genre_id

			   group by 2,3,4
			   order by 2 
 ),
 max_genre_per_country AS (select max(purchases_per_genre) AS max_genre_number, country
  from sales_per_country
  Group by 2
  order by 2)

select sales_per_country.*
from sales_per_country

join max_genre_per_country on sales_per_country.country = max_genre_per_country.country
where sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number




Q3. write a query that determines the customer that has spent the most on music for each 
country. write a query that returns the country along with the top customer 
and how much they spent. for countries where the top amount is shared, provide
all customer who spent this amount.

-- CTE methods:
with customer_with_country AS (
     select customer.customer_id , first_name, last_name, billing_country, SUm(total) AS total_spending

	 ROW_NUMBER() over(partition by billing_country order by SUM(total) DESC) AS RowNo

	 from inovice
	 join customer on customer.customer_id = invoice.customer_id

	 group by 1,2,3, 4
	 order by 4 ASC , 5 DESC 
)
select * from customer_with_country where RowNo <= 1


  
WITH customer_with_country AS (
     SELECT 
         customer.customer_id, 
         first_name, 
         last_name, 
         billing_country, 
         SUM(total) AS total_spending,
         ROW_NUMBER() OVER (
             PARTITION BY billing_country 
             ORDER BY SUM(total) DESC
         ) AS RowNo
     FROM invoice
     JOIN customer 
         ON customer.customer_id = invoice.customer_id
     GROUP BY customer.customer_id, first_name, last_name, billing_country
     ORDER BY billing_country ASC, total_spending DESC
)
SELECT * 
FROM customer_with_country 
WHERE RowNo <= 1;

	

