Q-01)  Which restaurants are associated with the longest average delivery times------

select 
r.restaurant_id,r.restaurant_name,round(avg(timestampdiff(minute,order_time,delivered_time))
,2) as avg_delivery_time from order_details o
inner join restaurant r
on r.restaurant_id=o.restaurant_id
where o.status = "delivered"
group by r.restaurant_id,r.restaurant_name
order by avg_delivery_time desc limit 1;

Q-02)  Which delivery partners have the highest average time per order-----------
select 
distinct p.partner_id,p.partner_name,round(avg(timestampdiff(minute,order_time,delivered_time)) 
over(partition by p.partner_id),2) as avg_delivery_time from order_details o
inner join delivery_partners p
on p.partner_id=o.partner_id
where o.status = "Delivered"
order by avg_delivery_time desc limit 1;
 
Q-03)  Which cities experience the most delivery delays -------------------

select 
r.city,round(avg(timestampdiff(minute,o.order_time,o.delivered_time)),2) as avg_delay_time
from order_details o
left join restaurant r
on r.restaurant_id=o.restaurant_id
where status="Delivered"
group by r.city
order by avg_delay_time desc limit 1;
 

Q-04) Are delivery delays increasing or decreasing over time----------------

  
select 
date_format(order_time,'%y-%m') as month,round(avg(timestampdiff(minute,order_time,delivered_time)),2)
as avg_delay 
from order_details
where status ="Delivered"
group by month
order by month;

Q-05) Which restaurants receive the highest volume of cancellations?--------

select 
o.restaurant_id,r.restaurant_name,count(o.restaurant_id) as total_cancellations from order_details o
inner join restaurant r
on r.restaurant_id=o.restaurant_id
where o.status="Cancelled"
group by o.restaurant_id,r.restaurant_name
order by total_cancellations desc
limit 1;

Q-06) Which cities have the highest cancellation rates by percentage?-------- 

select 
r.city,count(case when o.status='Cancelled' then 1 end)*100.0/count(*) as cancellation_rate
from order_details o
join restaurant r
on o.restaurant_id=r.restaurant_id
group by r.city
order by cancellation_rate desc;

Q-07) Is there a correlation between delivery delays and cancellations?-------

select
case
when timestampdiff(minute,order_time,delivered_time)<=30 then '0-30'
when timestampdiff(minute,order_time,delivered_time)<=45 then '31-45'
else '45+'
end as delay_range,
count(*) as total_orders
from order_details
where status='Delivered'
group by delay_range;

Q-08) On which days and at which times do cancellations peak----------- 

select 
dayname(order_time) as day,hour(order_time) as hour,count(*) as total_cancellations
from order_details
where status="Cancelled"
group by day,hour
order by total_cancellations desc
limit 1;

Q-09) Which restaurants generate the highest total revenue------------------
select 
r.restaurant_id,r.restaurant_name,t.total_revenue from restaurant r inner join (select restaurant_id,sum(order_amount) as total_revenue from order_details
where status="Delivered"
group by restaurant_id)t
on r.restaurant_id=t.restaurant_id
order by t.total_revenue desc
limit 1;
 
Q-10)  Which cities contribute the most to overall company revenue-----------------

select 
c.city,count(c.city) as total_orders,sum(o.order_amount) as total_revenue from order_details o
inner join customers c
on c.customer_id=o.customer_id
where o.status="Delivered"
group by c.city
order by total_revenue desc
limit 1;
select * from payment_details;

Q-11) Which payment methods are most popular and most valuable-------------

select 
payment_mode,count(*) as total_transactions,
sum(amount) as total_amount
from payment_details
group by payment_mode
order by total_transactions desc;

Q-12) What are the monthly revenue trends over the past year?----------

select
date_format(order_time,'%Y-%m') month,
sum(order_amount) total_revenue
from order_details
where status='Delivered'
group by month
order by month;

Q-13) Who are the top 10 most valuable customers by lifetime spending-------------

select 
c.customer_name,t.total_spendings from customers c
inner join (select customer_id,sum(order_amount) as total_spendings from order_details
where status = "delivered"
group by customer_id)t
on c.customer_id=t.customer_id
order by total_spendings desc
limit 10;

Q-14) Which customers order most frequently, and what is their average order value---------

select 
c.customer_id,c.customer_name,count(o.order_id) as  total_orders,round(avg(o.order_amount),2) as avg_amount from  order_details o
inner join customers c
on c.customer_id=o.customer_id
where status="Delivered"
group by c.customer_id,c.customer_name
order by total_orders desc
limit 1;
 
Q-15) Which customers have gone inactive in the last 90 days------------------------

select 
customer_id,customer_name from customers
where customer_id not in (select customer_id from order_details o
where order_time >= ((select max(order_time) from order_details) - interval 90 day));
 
Q-16) What behavioural patterns signal that a customer is about to churn----------------

--  ---------Declining Order Frequency---------------
select 
customer_id,date_format(order_time, '%y-%m') as month,count(order_id) as total_orders
from order_details
group by customer_id, date_format(order_time, '%y-%m')
order by customer_id, month;

-- -----------Monthly Spending Trend--------
select 
customer_id,date_format(order_time, '%Y-%m') as month,round(sum(order_amount), 2) as total_spent
from order_details
where status = 'Delivered'
group by customer_id, date_format(order_time, '%Y-%m')
order by customer_id, month;

-- ------------Cancellation Trend---------
select 
customer_id,date_format(order_time, '%Y-%m') as month,count(case when status = 'Cancelled' then 1 end) as cancelled_orders,
count(*) as total_orders
from order_details
group by customer_id, DATE_FORMAT(order_time, '%Y-%m')
order by customer_id, month;

Q-17) Who are the fastest delivery partners based on average delivery time-----------

select 
p.partner_id,p.partner_name,count(o.order_id) as total_deliveries,
round(avg(timestampdiff(minute,order_time,delivered_time)),2)
as avg_time_diff_min from order_details o 
inner join delivery_partners p 
on p.partner_id=o.partner_id 
where o.status = "delivered"
group by p.partner_id,p.partner_name 
order by avg_time_diff_min asc
limit 1;
 
Q-18) Which partners handle the highest volume of successful deliveries-----------------

select 
p.partner_id,p.partner_name,count(o.order_id) as successful_orders from order_details o
inner join delivery_partners p
on p.partner_id=o.partner_id
where o.status = "delivered"
group by p.partner_id,p.partner_name
order by successful_orders desc limit 1;

Q-19) Which partners are associated with the most cancellations or delays-----------------------------

select 
p.partner_id,p.partner_name,sum(case when o.status='Cancelled' then 1 else 0 end) cancelled_orders,
round(avg(case when o.status='Delivered' then timestampdiff(minute,order_time,delivered_time)
end),2) avg_delivery_time
from order_details o
join delivery_partners p
on o.partner_id=p.partner_id
group by p.partner_id,p.partner_name
order by cancelled_orders desc,avg_delivery_time desc;
  
--  ------------Q-20) What is the average customer rating received per delivery partner---------------------------

select 
p.partner_id,p.partner_name,round(avg(r.customer_rating),1) as avg_customer_rating,count(distinct o.order_id) as total_orders
from order_details o
left join ratings r
on o.order_id=r.order_id
join delivery_partners p
on o.partner_id=p.partner_id
group by p.partner_id,p.partner_name;  


                                            REVENUE ANALYSIS  

What is the average daily revenue?

select date(order_time) as order_date,round(sum(order_amount),2) as daily_revenue
from order_details
where status='Delivered'
group by date(order_time)
order by order_date;

 Which city has the highest average order value?

select c.city,round(avg(o.order_amount),2) as avg_order_value
from customers c
join order_details o
on c.customer_id=o.customer_id
where o.status='Delivered'
group by c.city
order by avg_order_value desc;

Which hour of the day generates the highest revenue?

select hour(order_time) as hour,round(sum(order_amount),2) as total_revenue
from order_details
where status='Delivered'
group by hour
order by total_revenue desc;

What is the average revenue generated per restaurant?

select r.restaurant_name,round(avg(o.order_amount),2) as avg_revenue_per_order
from restaurant r
join order_details o
on r.restaurant_id=o.restaurant_id
where o.status='Delivered'
group by r.restaurant_name
order by avg_revenue_per_order desc;
 

                                            BUSINESS ANALYSIS

How many new customers were acquired each month?

select
date_format(first_order,'%Y-%m') as month,
count(*) as new_customers
from(select customer_id,min(order_time) as first_order
from order_details
group by customer_id)t
group by month
order by month;

Which cities are showing the fastest revenue growth?

select
c.city,
date_format(o.order_time,'%Y-%m') as month,
round(sum(o.order_amount),2) as monthly_revenue
from customers c
join order_details o
on c.customer_id=o.customer_id
where o.status='Delivered'
group by c.city,month
order by c.city,month;

What is the month-over-month growth in revenue?

select
date_format(order_time,'%Y-%m') as month,
round(sum(order_amount),2) as monthly_revenue,
round(
sum(order_amount) -
lag(sum(order_amount))
over(order by date_format(order_time,'%Y-%m'))
,2) as revenue_growth
from order_details
where status='Delivered'
group by month;

Which month had the highest average order value?

select
date_format(order_time,'%Y-%m') as month,
round(avg(order_amount),2) as avg_order_value
from order_details
where status='Delivered'
group by month
order by avg_order_value desc;
