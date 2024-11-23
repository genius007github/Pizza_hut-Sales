create database pizza_hut;

select * from orders;
select * from pizza_types;
select * from pizzas;
select * from order_details;

-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

--- Calculate the total revenue generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
    
    
 --- Identify the highest prize pizza.
 
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
 
 --- Identify the most common pizza size ordered
 
 select quantity, count(order_details_id)
 from order_details group by quantity;
 
  --- Identify the most common pizza size ordered
  
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;
 
 
  SELECT size, order_count
FROM (
    SELECT pizzas.size, COUNT(order_details.order_details_id) AS order_count
    FROM pizzas
    JOIN order_details
    ON pizzas.pizza_id = order_details.pizza_id
    GROUP BY pizzas.size
) AS subquery
ORDER BY order_count DESC
LIMIT 0, 1000;


--- List the top 5 most ordered pizza types 
--- along with their quantities.


SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

--- Join the necessary tables to find the total 
--- quantity of each pizza category ordered.

select pizza_types.category,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by quantity desc;


--- Determine the distribution of orders by hour of the day.

select hour(time) as hour, count(order_id) as order_count from orders
group by hour(time);

--- Join relevant tables to find the category-wise distribution of pizzas.

select category,count(name) from pizza_types
group by category;

--- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    AVG(quantity) as avg_pizza_ordered_perday
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;


--- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc limit 3;


--- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
(sum(order_details.quantity*pizzas.price) / (SELECT 
    SUM(order_details.quantity * pizzas.price)
             AS revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id))*100 as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue;

--- Analyze the cumulative revenue generated over time.

select date,
sum(revenue) over(order by date) as cum_revenue
from
(select orders.date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as sales;

--- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name ,revenue from

(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category,pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn <=3;










