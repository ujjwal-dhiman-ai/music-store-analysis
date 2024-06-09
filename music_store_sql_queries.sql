select * from album;

select * from artist;

select * from customer;

select * from employee;

select * from genre;

select * from invoice;

select * from invoice_line;

select * from media_type;

select * from playlist;

select * from playlist_track;

select * from track;

-- 1.
select *
from employee
order by levels desc
limit 1

-- 2.
select 
	billing_country,
	count(invoice_id) as invoice_count
from invoice
group by billing_country
order by invoice_count desc
limit 1

-- 3.
select total
from invoice
order by total desc
limit 3


-- 4.
select 
	billing_city,
	sum(total) as invoice_total
from 	
	invoice
group by billing_city
order by invoice_total desc
limit 1

-- 5.
select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_spending
from customer c
left join invoice i on c.customer_id = i.customer_id
group by c.customer_id
order by total_spending desc
limit 1

-- 6.
select distinct c.email, c.first_name, c.last_name, g.name
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock'
order by c.email asc

-- 7.
with cte as (
	select a.artist_id, count(t.track_id) as track_count
	from album a
	join track t on a.album_id = t.album_id
	join genre g on t.genre_id = g.genre_id
	where g.name = 'Rock'
	group by a.artist_id
)

select a.name, cte.track_count
from artist a
join cte on cte.artist_id = a.artist_id
order by cte.track_count desc
limit 10

-- 8.
select t.name, t.milliseconds
from track t
where t.milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc

-- 9.
with cte as (select 
				c.customer_id, c.first_name, c.last_name, 
				il.track_id, (il.unit_price*il.quantity) as total_spent
			from customer c
			join invoice i on c.customer_id = i.customer_id
			join invoice_line il on i.invoice_id = il.invoice_id
),
cte2 as (select a.name, t.track_id
		from artist a
		join album al on a.artist_id = al.artist_id
		join track t on al.album_id = t.album_id
)

select cte.first_name, cte.last_name, cte2.name as artist_name, sum(cte.total_spent) as total_spent
from cte 
join cte2 on cte.track_id = cte2.track_id
group by cte.first_name, cte.last_name, cte2.name
-- having cte.first_name = 'Hugh' and cte2.name = 'Queen'

-- 10.
with cte as (
	select distinct t.genre_id, i.billing_country, il.invoice_line_id
	from track t
	join invoice_line il on t.track_id = il.track_id
	join invoice i on il.invoice_id = i.invoice_id
),
ranked_genre as (
	select cte.billing_country, cte.genre_id, count(1) as genre_count,
		dense_rank() over(partition by billing_country order by count(1) desc) as dr
	from cte
	group by cte.billing_country, cte.genre_id
)

select rg.billing_country as country, g.name, rg.genre_count as purchased_count
from ranked_genre rg
join genre g on g.genre_id = rg.genre_id
where dr = 1;


-- 11.
select country, first_name, last_name, total_spent, dr
from (
		select i.billing_country as country, c.customer_id, c.first_name, c.last_name, sum(i.total) as total_spent,
			dense_rank() over(partition by c.country order by sum(i.total) desc) as dr
		from customer c
		join invoice i on c.customer_id = i.customer_id
		group by i.billing_country, c.customer_id
	)
where dr = 1








