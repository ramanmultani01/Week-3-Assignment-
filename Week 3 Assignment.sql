CREATE DATABASE superstore_db;
USE superstore_db;

 CREATE TABLE superstore_raw (
    row_id INT,
    order_id VARCHAR(30),
    order_date VARCHAR(30),
    ship_date VARCHAR(30),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(30),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
);

CREATE TABLE customers AS
SELECT DISTINCT
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    region
FROM superstore_raw;


CREATE TABLE products AS
SELECT DISTINCT
    product_id,
    category,
    sub_category,
    product_name
FROM superstore_raw;


CREATE TABLE orders AS
SELECT DISTINCT 
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    sales,
    quantity,
    discount,
    profit
FROM superstore_raw;

-- Above Average Sales 
SELECT `customer_id`, SUM(Sales) AS total_sales
FROM orders
GROUP BY `customer_id`
HAVING total_sales >
(
    SELECT AVG(customer_total)
    FROM
    (
        SELECT SUM(Sales) AS customer_total
        FROM orders
        GROUP BY `customer_id`
    ) AS avg_sales
);

-- Highest Order per customer 
SELECT o.*
FROM orders o
JOIN
(
    SELECT customer_id, MAX(Sales) AS max_sales
    FROM orders
    GROUP BY customer_id
) m
ON o.customer_id = m.customer_id
AND o.Sales = m.max_sales;

-- Total sales per customer 
WITH customer_sales AS
(
    SELECT
        `customer_id`,
        SUM(Sales) AS total_sales
    FROM orders
    GROUP BY `customer_id`
)
SELECT * FROM customer_sales ORDER BY total_sales DESC;

-- Row Number
SELECT
    `customer_id`,
    Sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY `customer_id`
        ORDER BY Sales DESC
    ) AS row_num
FROM orders;

-- Rank
SELECT
    `customer_id`,
    SUM(Sales) AS total_sales,
    RANK() OVER
    (
        ORDER BY SUM(Sales) DESC
    ) AS customer_rank
FROM orders
GROUP BY `customer_id`;

-- Final Results 
WITH customer_sales AS
(
    SELECT
        c.`customer_id`,
        c.`customer_name`,
        SUM(o.Sales) AS total_sales
    FROM customers c
    JOIN orders o
    ON c.`customer_id` = o.`customer_id`
    GROUP BY c.`customer_id`, c.`customer_name`
)
SELECT *,
RANK() OVER
(
    ORDER BY total_sales DESC
) AS sales_rank
FROM customer_sales;

-- Top 5 Customers
WITH customer_sales AS
(
    SELECT
        c.`customer_name`,
        SUM(o.Sales) AS total_sales
    FROM customers c
    JOIN orders o
    ON c.`customer_id` = o.`customer_id`
    GROUP BY c.`customer_name`
)
SELECT *
FROM customer_sales
ORDER BY total_sales DESC
LIMIT 5;

-- Low 5 customers 
WITH customer_sales AS
(
    SELECT
        c.`customer_name`,
        SUM(o.Sales) AS total_sales
    FROM customers c
    JOIN orders o
    ON c.`customer_id` = o.`customer_id`
    GROUP BY c.`customer_name`
)
SELECT *
FROM customer_sales
ORDER BY total_sales ASC
LIMIT 5;

-- Single order customers 
SELECT
    `customer_id`,
    COUNT(`order_id`) AS total_orders
FROM orders
GROUP BY `customer_id`
HAVING COUNT(`order_id`) = 1;

-- Above average sales 
WITH customer_sales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM orders
    GROUP BY customer_id
)

SELECT *
FROM customer_sales
WHERE total_sales >
(
    SELECT AVG(total_sales)
    FROM customer_sales
);

-- Highest order value per customer (first 20 customers )
SELECT
    c.customer_name,
    MAX(o.sales) AS highest_order_value
FROM orders o
JOIN customers c
ON o.customer_id = c.customer_id
GROUP BY c.customer_name
ORDER BY highest_order_value DESC
LIMIT 20;