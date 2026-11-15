select COUNT(*) as total_sales from sales;
select COUNT(*) as total_products from products;
select COUNT(*) as total_customers from customers;

alter table fact_sales rename to sales;

describe sales;
describe products;
describe customers;

drop table products;
drop table customers;

select * from information_schema.TABLES;

select * from information_schema.COLUMNS;

select * from information_schema.COLUMNS where table_name = 'sales' and table_schema = 'gold';

select DISTINCT products.category,
                subcategory
from gold.products
order by products.category;

select DISTINCT customers.country,
                count(*) as customer_count
from gold.customers
group by customers.country;

select MIN(sales.order_date) as first_order_date,
       MAX(sales.order_date) as last_order_date,
       round(datediff(MAX(sales.order_date), MIN(sales.order_date)) / 365, 1) as sales_duration
from gold.sales;

WITH order_range AS (
    SELECT
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date
    FROM gold.sales
)
SELECT
    first_order_date,
    last_order_date,
    ROUND(DATEDIFF(last_order_date, first_order_date) / 365.2425, 1)
        AS sales_duration_years
FROM order_range;

SELECT customers.first_name,
            customers.last_name,
            customers.birthdate,
            customers.marital_status,
            customers.gender,
            customers.country
FROM customers
where birthdate is not null and birthdate = (SELECT MAX(birthdate) FROM customers);

SELECT
    'Total_Sales_Amount' as Measure_Name , SUM(sales.sales_amount) as Masured_Values
FROM sales
UNION ALL

SELECT
        'Total_Quantity', SUM(sales.quantity)
FROM sales
UNION ALL

SELECT
        'Average_Selling_Price', AVG(sales.price)
FROM sales

UNION ALL
SELECT
        'Total_Orders', COUNT(DISTINCT order_number) as Total_Orders
FROM sales
UNION ALL

select
    'total_products', COUNT(*)
from products

UNION ALL

select
    'total_customers', COUNT(*)
from gold.customers

UNION ALL

select
    'total_order_placed_customers', COUNT(DISTINCT sales.customer_key)
from gold.sales;


SELECT
    c.country,
    SUM(s.sales_amount) as Total_Sales_Amount
FROM sales s
join customers c on c.customer_key = s.customer_key
WHERE c.country != 'n/a'
GROUP BY c.country
ORDER BY Total_Sales_Amount DESC;

SELECT
    customers.country,
    COUNT(customers.customer_key) as Total_Customers
FROM customers
WHERE country != 'n/a'
GROUP BY customers.country
ORDER BY COUNT(customers.customer_key) DESC;

SELECT
    customers.gender,
    COUNT(customers.customer_key) as Total_Customers
FROM customers
GROUP BY customers.gender
ORDER BY COUNT(customers.customer_key) DESC;

SELECT
    products.category,
    COUNT(products.product_key) as Total_Products,
    AVG(cost) as Average_Cost
FROM products
GROUP BY products.category
ORDER BY COUNT(products.product_key) DESC;

SELECT
    p.category,
    SUM(s.sales_amount) as Total_Revenue
FROM gold.sales s
LEFT JOIN gold.products p ON p.product_key = s.product_key
GROUP BY p.category
ORDER BY  SUM(s.sales_amount) DESC;


SELECT
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) as Customer_Name,
    SUM(s.sales_amount) as Total_Revenue
FROM gold.sales s
LEFT JOIN gold.customers c ON c.customer_key = s.customer_key
GROUP BY c.customer_key, Customer_Name
ORDER BY  SUM(s.sales_amount) DESC;

SELECT
    c.country,
    SUM(s.quantity) as Total_Sold_Items
FROM gold.sales s
LEFT JOIN gold.customers c ON c.customer_key = s.customer_key
GROUP BY c.country
ORDER BY  SUM(s.quantity) DESC;

WITH Product_Sale AS (
    SELECT
    p.product_name,
    SUM(s.sales_amount) as Total_Revenue
FROM gold.sales s
LEFT JOIN gold.products p ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY SUM(s.sales_amount) DESC
)
SELECT
    product_name,
    Total_Revenue,
    RANK() over (ORDER BY Total_Revenue DESC ) AS Product_Rank
FROM Product_Sale
limit 5;

WITH Product_Sale AS (
    SELECT
    p.product_name,
    SUM(s.sales_amount) as Total_Revenue,
    RANK() over (ORDER BY SUM(s.sales_amount) DESC ) AS Product_Rank
FROM gold.sales s
LEFT JOIN gold.products p ON p.product_key = s.product_key
GROUP BY p.product_name
ORDER BY SUM(s.sales_amount) DESC
)
SELECT
    product_name,
    Total_Revenue
FROM Product_Sale
WHERE Product_Rank <= 5;

WITH Top_10_Customer AS (
    SELECT
    c.customer_key,
    CONCAT(c.first_name, ' ', c.last_name) as Customer_Name,
    SUM(s.sales_amount) as Total_Revenue,
    ROW_NUMBER() over ( ORDER BY SUM(s.sales_amount) DESC) AS Customer_Rank
FROM gold.sales s
LEFT JOIN gold.customers c ON c.customer_key = s.customer_key
GROUP BY c.customer_key, Customer_Name
ORDER BY  SUM(s.sales_amount) DESC
)
SELECT
    Customer_Name,
    Total_Revenue,
    Customer_Rank
FROM Top_10_Customer
WHERE  Customer_Rank <= 10 ;

SELECT
    c.customer_key,
    c.first_name,
    C.last_name,
    COUNT(DISTINCT s.order_number) as Total_Orders
FROM gold.sales s
LEFT JOIN gold.customers c ON c.customer_key = s.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY Total_Orders;


SELECT
    YEAR(sales.shipping_date) AS Year,
    SUM(sales.sales_amount) AS Total_Amount
FROM gold.sales
GROUP BY YEAR(sales.shipping_date)
ORDER BY Total_Amount DESC;

SELECT
    YEAR(products.start_date) AS Year,
    MONTH(products.start_date) AS Month,
    AVG(cost) AS Average_Cost
FROM gold.products
GROUP BY YEAR(products.start_date), MONTH(products.start_date)
ORDER BY Average_Cost DESC;

SELECT
    sales.order_date,
    SUM(sales.sales_amount) as Total_Sales
FROM gold.sales
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date;

SELECT
    YEAR(sales.order_date),
    SUM(sales.sales_amount) as Total_Sales,
    COUNT(DISTINCT sales.customer_key) as Total_customer,
    SUM(sales.quantity) as Total_Quantity
FROM gold.sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(sales.order_date);

SELECT
    YEAR(sales.order_date) as Year,
    MONTH(sales.order_date) as Months,
    SUM(sales.sales_amount) as Total_Sales,
    COUNT(DISTINCT sales.customer_key) as Total_customer,
    SUM(sales.quantity) as Total_Quantity
FROM gold.sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(sales.order_date), MONTH(sales.order_date);


SELECT
    DATE_FORMAT(order_date, '%Y-%b') AS sales_month,
    SUM(sales_amount) AS Total_Sales,
    COUNT(DISTINCT customer_key) AS Total_customer,
    SUM(quantity) AS Total_Quantity
FROM gold.sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%b')
ORDER BY sales_month;


SELECT
    DATE_FORMAT(MIN(order_date), '%Y-%b') AS sales_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);


WITH Cummulative_Calculate AS (
    SELECT
        YEAR(sales.order_date) as sales_year,
        CAST(DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS DATE ) AS sales_month,
        SUM(sales.sales_amount) as Total_Sales,
        ROUND(AVG(sales.sales_amount), 2) as Average_Sales
    FROM gold.sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(sales.order_date)
    ORDER BY YEAR(sales.order_date)
)
SELECT
    sales_year,
    DATE_FORMAT(sales_month, '%Y-%m-01') as sales_month,
    Total_Sales,
    SUM(Total_Sales) OVER ( ORDER BY sales_month) AS Running_Total,
    Average_Sales,
    SUM(Average_Sales) OVER ( ORDER BY sales_month) AS Moving_Average
FROM Cummulative_Calculate;


WITH Cummulative_Calculate AS (
    SELECT
        YEAR(sales.order_date) as sales_year,
        CAST(DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS DATE ) AS sales_month,
        SUM(sales.sales_amount) as Total_Sales,
        ROUND(AVG(sales.sales_amount), 2) as Average_Sales
    FROM gold.sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(sales.order_date), MONTH(sales.order_date)
    ORDER BY YEAR(sales.order_date), MONTH(sales.order_date)
)
SELECT
    sales_year,
    DATE_FORMAT(sales_month, '%Y-%m-01') as sales_month,
    Total_Sales,
    SUM(Total_Sales) OVER (PARTITION BY sales_year ORDER BY sales_month) AS Running_Total,
    Average_Sales,
    SUM(Average_Sales) OVER (PARTITION BY sales_year ORDER BY sales_month) AS Moving_Average
FROM Cummulative_Calculate;


/* Analyze the yearly performance of products by comparing their sales to both the average sales
   performance of the product and the previous year's sales */

WITH Yearly_Product_Sales AS (
    SELECT
        YEAR(s.order_date) as order_year,
        p.product_name,
        SUM(s.sales_amount) as current_sales
    FROM gold.sales s
    LEFT JOIN gold.products p ON p.product_key = s.product_key
    WHERE s.order_date IS NOT NULL
    GROUP BY YEAR(s.order_date), p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) as avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) as diff_avg,
    CASE
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Belove Average'
    ELSE 'Average'
    END as average_status,
    lag(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as previous_sales,
    current_sales - lag(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) as diff_previous_sales,
    CASE
        WHEN current_sales - lag(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - lag(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
    ELSE 'No Change'
    END as previous_average_status
FROM Yearly_Product_Sales
ORDER BY product_name, order_year;


/* Analysis the Cetegory by sales amount with percentage */

WITH Category_Performance AS (
    SELECT
        p.category,
        SUM(s.sales_amount) as Total_Sales_by_Category
    FROM gold.sales s
    LEFT JOIN gold.products p ON p.product_key = s.product_key
    GROUP BY p.category
)
SELECT
    category,
    Total_Sales_by_Category,
    SUM(Total_Sales_by_Category) OVER () as Overall_Sales,
    CONCAT(ROUND((Total_Sales_by_Category / SUM(Total_Sales_by_Category) OVER ()) * 100, 2),'%') as Percentage
FROM Category_Performance
ORDER BY Total_Sales_by_Category DESC;


/*Segment products into cost ranges and count how many products fall into each segment.*/

WITH Cost_Segment_Product AS (
    SELECT
    products.product_key,
    products.product_name,
    products.cost,
    CASE
        WHEN cost < 100 THEN 'Below 100'
        WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
        WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
    ELSE 'Above 1000'
    END AS Cost_Range
FROM gold.products
)
SELECT
    Cost_Range,
    COUNT(product_key) as Total_Product
FROM Cost_Segment_Product
GROUP BY Cost_Range
ORDER BY Total_Product DESC ;


/*Group customers into three segments based on their spending behavior:
- VIP: Customers with  y and spending more than €5,000.
- Regular: Customers with at least 12 months of history but spending €5,000 or less.
- New: Customers with a lifespan of less than 12 months.

Find the total number of customers in each group.*/

WITH Customer_Spending AS (
SELECT
    c.customer_key,
    SUM(s.sales_amount) as Total_Spending,
    MIN(s.order_date) as First_order,
    MAX(s.order_date) as Last_Order,
    TIMESTAMPDIFF(MONTH ,MIN(s.order_date), MAX(s.order_date)) as lifespan
FROM gold.sales s
left join gold.customers c ON c.customer_key = s.customer_key
GROUP BY c.customer_key
)
SELECT
    Customer_Segment,
    COUNT(customer_key) as Total_Customer
FROM(
    SELECT
        customer_key,
        CASE
            WHEN lifespan >= 12 and Total_Spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 and Total_Spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS Customer_Segment
    FROM Customer_Spending
    ) t
GROUP BY Customer_Segment;



CREATE VIEW gold.report_customers AS
/*============================================================
Customer Report
============================================================
Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - lifespan (in months)
4. Calculates valuable KPIs:
   - recency (months since last order)
   - average order value
   - average monthly spend
============================================================*/
WITH base_query AS (
/*------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------------------------*/
SELECT
    s.order_number,
    s.product_key,
    s.order_date,
    s.sales_amount,
    s.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS age
FROM gold.sales s
LEFT JOIN gold.customers c ON c.customer_key = s.customer_key
WHERE s.order_date IS NOT NULL
),
    customer_aggregation AS (
/*------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
------------------------------------------------------------*/
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_Sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) as last_order_date,
    TIMESTAMPDIFF(MONTH ,MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
GROUP BY
    customer_key,
    customer_number,
    customer_name,
    age
    )
SELECT
/*------------------------------------------------------------
3) Segments customers into categories (VIP, Regular, New) and age groups.
4). Calculates valuable KPIs:
    - recency (months since last order)
    - average order value (AOV)
    - average monthly spend
------------------------------------------------------------*/
    customer_key,
    customer_number,
    customer_name,
    age,
        CASE
            WHEN age < 20 THEN 'Under 20'
            WHEN age BETWEEN 20 and 29 THEN '20-29'
            WHEN age BETWEEN 30 and 39 THEN '30-39'
            WHEN age BETWEEN 40 and 49 THEN '40-49'
        ELSE '50 and Above'
        END AS age_group,
        CASE
            WHEN lifespan >= 12 and total_Sales > 5000 THEN 'VIP'
            WHEN lifespan >= 12 and total_Sales <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS Customer_Segment,
    last_order_date,
    TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
    total_orders,
    total_Sales,
    total_quantity,
    total_products,
    lifespan,
    -- Compute Average order value (AOV)
    CASE
        WHEN total_orders = 0 THEN 0
    ELSE ROUND(total_Sales / total_orders , 2)
    END AS AOV,
    -- Average Monthly Spend
    CASE
        WHEN lifespan = 0 THEN total_Sales
    ELSE ROUND(AVG(total_Sales / lifespan) , 2)
    END AS avg_monthly_spend
FROM customer_aggregation;

SELECT
    Customer_Segment,
    COUNT(customer_number) as total_customer
FROM gold.report_customers
GROUP BY Customer_Segment;



CREATE VIEW gold.report_products AS
/*============================================================
Product Report
============================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue (AOR)
        - average monthly revenue
============================================================*/
WITH base_query AS (
/*------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
------------------------------------------------------------*/
SELECT
    s.order_number,
    s.order_date,
    s.customer_key,
    s.sales_amount,
    s.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.sales s
LEFT JOIN gold.products p ON p.product_key = s.product_key
WHERE s.order_date IS NOT NULL
),
    product_aggregation AS (
/*------------------------------------------------------------
2) Products Aggregations: Summarizes key metrics at the product level
------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_Sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customer,
    MAX(order_date) as last_sale_date,
    TIMESTAMPDIFF(MONTH ,MIN(order_date), MAX(order_date)) AS lifespan,
    ROUND(AVG(sales_amount / NULLIF(quantity, 0)), 2) AS avg_selling_price
FROM base_query
GROUP BY
    product_key,
    product_name,
    category,
    subcategory,
    cost
    )
SELECT
/*------------------------------------------------------------
3) Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
4). Calculates valuable KPIs:
    - recency (months since last order)
    - average order revenue (AOR)
    - average monthly revenue
------------------------------------------------------------*/
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    TIMESTAMPDIFF(MONTH, last_sale_date, CURDATE()) AS recency,
        CASE
            WHEN total_Sales > 50000 THEN 'High Performer'
            WHEN total_Sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low Performer'
        END AS product_Segment,
    total_orders,
    total_Sales,
    total_quantity,
    total_customer,
    lifespan,
    avg_selling_price,
    -- Compute Average order Revenue (AOR)
    CASE
        WHEN total_orders = 0 THEN 0
    ELSE ROUND(total_Sales / total_orders , 2)
    END AS AOR,
    -- Average Monthly Spend
    CASE
        WHEN lifespan = 0 THEN total_Sales
    ELSE ROUND(total_Sales / lifespan , 2)
    END AS avg_monthly_revenue
FROM product_aggregation;

SELECT
    *
FROM gold.report_products;

