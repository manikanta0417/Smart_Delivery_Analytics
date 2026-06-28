                     --customers--

 create table customers(customer_id int primary key,customer_name
 varchar(50) ,age int check(age>=18),gender char(10),
 city varchar(50),signup_date date);
 
 insert into customers
 select customer_id,customer_name,age,gender,city,signup_date from customer;
 
                    --customer_behaviour--

 create table customer_behaviour(customer_id  int primary key,
 total_orders int,total_spending decimal(10,2),
 avg_order_value decimal(10,2) ,last_order_days int,churn_flag boolean default 0,
 foreign key(customer_id) references customers(customer_id));
 
 insert into customer_behaviour
 select customer_id,total_orders,total_spending,avg_order_value,last_order_days,churn_flag from customer_summary;

                     --restaurant--

 create table restaurant(restaurant_id int primary key,restaurant_name varchar(30),cuisine_type varchar(30),city varchar(20),
 rating decimal(5,2) check(rating>=1 and rating<=5));
 
 insert into restaurant
 select restaurant_id,restaurant_name,cuisine_type,city,rating from restaurant;
 
                  --delivery_partner--

 create table delivery_partners(partner_id int primary key,partne_name varchar(50),vehicle_type varchar(50),joining_date date);
 
 insert into delivery_partners
 select partner_id,partne_name,vehicle_type,joining_date from delivery_partner;

                  --order_details--

create table order_details(order_id int primary key,customer_id int,restaurant_id int,partner_id int,
order_time timestamp,delivered_time timestamp,order_amount decimal(10,2),delivery_fee decimal(10,2),
status varchar(20) not null default 'Pending',foreign key (customer_id) references customers(customer_id),
foreign key (partner_id) references delivery_partners(partner_id),foreign key (restaurant_id) references
 restaurant(restaurant_id));

update orders set  delivered_time = null where delivered_time = '';

insert into order_details
select order_id,customer_id,restaurant_id,partner_id,order_time,delivered_time,order_amount,delivery_fee,status from orders;

                 --payments--

create table payment_details(payment_id int not null,order_id int,payment_mode varchar(30),amount decimal(10,2),
foreign key (order_id) references order_details(order_id));

insert into payment_details
select payment_id,order_id,payment_mode,amount from payments;

                 --ratings--

create table rating(rating_id int not null,order_id int,customer_rating decimal(5,2),feedback varchar(50),foreign key(order_id) references order_details(order_id));

insert into rating
select rating_id,order_id,customer_rating,feedback from ratings;

update orders set  delivered_time = null where delivered_time = '';
