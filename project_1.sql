
--retrive the total nunber of orders

select count(order_id) as total_orders from orders



--calculate the total revenue generated from pizza sales


select sum((cast(order_detail.quantity as int)* 
cast (pizzas.price as decimal ))) as total_sales
from order_detail inner join pizzas
on pizzas.pizza_id = order_detail.pizza_id

--identify the highest-priced pizza

select top(2) pizza_types.name,pizzas.price 
from pizza_types inner join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price desc;

--identify the most common pizza orderd


select pizzas.size,count(order_detail.order_details_id)as Total_quantity
from pizzas inner join order_detail
on order_detail.pizza_id = pizzas.pizza_id 
group by pizzas.size
order by total_quantity desc;


--list the top 5 most ordered pizza types along with their quantites


select top 5 pizza_types.name,count(order_detail.quantity) as
total_quantity
from pizza_types inner join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
inner join order_detail
on order_detail.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by total_quantity desc;

-- join the necessary tables to find the total quantity of each pizza category orderd


select pizza_types.category, count(order_detail.quantity) as Total_quantity
from pizza_types inner join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
inner join order_detail
on order_detail. pizza_id= pizzas.pizza_id
GROUP BY  pizza_types.category;


---determine the distribution of orders by hour of the day


select DATEPART (hour,cast(time as DATETIME)) Hour , 
Count (order_id) as total_orders
from orders
GROUP BY DATEPART(HOUR,CAST(time  as DATETIME))
ORDER BY Hour ASC

--- join the relevant taables to find the category -wise distribution of pizzas




select category ,count(name) as Total_pizzas from pizza_types
GROUP BY category

---group the orders by date and calculate the avg number of pizzas orderd per day 

select avg (CAST(quantity as INT)) as average_number from 
(select orders.date ,sum(CAST (order_detail.quantity as int)) as quantity
from orders inner join order_detail
on order_detail.order_id = orders.order_id
group by orders.date) as order_quantity ;



---Determine the top 3 most orderd  pizzas types based on revenue

select top 3 pizza_types.name,sum(cast(order_detail.quantity as int)* 
cast (pizzas.price as float)) as revenue
from pizza_types inner join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id inner join
order_detail
on order_detail.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc;



-----Calculate the percentage contribution of each pizza type to total revenue 


select pizza_types.category, (sum(cast(order_detail.quantity as int)*
cast(pizzas.price as float )) / 
(select sum((cast (order_detail.quantity as int )* cast(pizzas.price as decimal ))) as total_sales
from order_detail inner join pizzas
on pizzas.pizza_id = order_detail.pizza_id) * 100) as revenue_percentage
from
pizza_types inner join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id inner join
order_detail
on order_detail .pizza_id = pizzas.pizza_id 
group by pizza_types.category order by revenue_percentage desc;


---analyze the cumulative revenue generated over time




select date,
  sum (revenue) over (order by date) as cum_revenue 
  from (
  select orders.date,
  sum(cast(order_detail.quantity as int)*cast (pizzas.price  as float )) as revenue 
  from order_detail

inner join pizzas on order_detail.pizza_id = pizzas.pizza_id
inner join orders on orders.order_id = order_detail.order_id
group by orders.date

 ----Determine the top 3 most orderded pizza types based on revenue for each pizza category


 with a as 
  (select pizza_types.category,pizza_types.name,sum(cast(order_detail.quantity as int )* cast (pizzas.price as float)) as revenue 
from pizza_types inner join pizzas
on pizza_types.pizza_type_id  = pizzas.pizza_type_id
inner join order_detail
on order_detail.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name
)

select name, revenue from 
(select category , name ,revenue , rank()over(partition by category order by revenue desc ) as rn
from A ) as B
where rn <= 3 order by rn desc


select name,revenue from
(select category ,name ,revenue,rank() over (partition by category order by revenue desc )as rn 
from
(select pizza_types.category,pizza_types.name,
sum(cast(order_detail.quantity as int )*cast (pizzas.price as float)) as revenue 
from pizza_types inner join pizzas on pizza_types. pizza_type_id =pizzas.pizza_type_id
inner join order_detail
on order_detail.pizza_id = pizzas.pizza_id group by pizza_types.category , pizza_types.name) as a) as b
where rn <=3;








