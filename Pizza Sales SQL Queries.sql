create database pizza;
use pizza;
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(ord.quantity * p.price), 2) AS total_revenu
FROM
    order_details ord
        JOIN
    pizzas p ON ord.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    MAX(p.price) AS max_price, pi.name
FROM
    pizzas p
        JOIN
    pizza_types pi ON pi.pizza_type_id = p.pizza_type_id
GROUP BY pi.name
ORDER BY max_price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    pi.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas pi
        JOIN
    order_details o ON pi.pizza_id = o.pizza_id
GROUP BY pi.size
ORDER BY order_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pi.name, SUM(o.quantity) AS total_quantity
FROM
    pizza_types pi
        JOIN
    pizzas p ON pi.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pi.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pi.category, SUM(o.quantity) AS total_quantity
FROM
    pizza_types pi
        JOIN
    pizzas p ON p.pizza_type_id = pi.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY pi.category
ORDER BY total_quantity;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS hour_time, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour_time
ORDER BY order_count DESC
;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS count
FROM
    pizza_types
GROUP BY category
ORDER BY count;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) AS avg_orderd_pizza_per_day
FROM
    (SELECT 
        o.date, SUM(od.quantity) AS quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.date
    ORDER BY quantity) AS order_quantity;


-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pi.name, SUM(o.quantity * p.price) AS revenue
FROM
    pizza_types pi
        JOIN
    pizzas p ON p.pizza_type_id = pi.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY pi.name
ORDER BY revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue
WITH total_revenue AS (
    SELECT 
        SUM(o.quantity * p.price) AS overall_revenue
    FROM
        order_details o
        JOIN pizzas p ON o.pizza_id = p.pizza_id
),
pizza_revenue AS (
    SELECT 
        pi.category,
        SUM(o.quantity * p.price) AS category_revenue
    FROM
        pizza_types pi
        JOIN pizzas p ON p.pizza_type_id = pi.pizza_type_id
        JOIN order_details o ON p.pizza_id = o.pizza_id
    GROUP BY
        pi.category
)
SELECT 
    pr.category,
    ROUND((pr.category_revenue / tr.overall_revenue) * 100, 2) AS percentage_contribution
FROM 
    pizza_revenue pr,
    total_revenue tr
ORDER BY 
    percentage_contribution DESC;
