📊 End-to-End Exploratory Data Analysis (EDA) & Advanced Data Analytics (SQL + Python)

📌 Project Overview

This repository showcases a complete, dual-stack Exploratory Data Analysis (EDA) and Advanced Data Analytics solution built on top of an enterprise retail Data Warehouse (gold star schema).

To demonstrate analytical versatility across both database engines and data science ecosystems, every business question, metric, segmentation rule, and analytical report in this project was implemented twice:

In SQL (MySQL): Leveraging Common Table Expressions (CTEs), Window Functions (RANK, ROW_NUMBER, LAG, SUM/AVG OVER), CASE logic, date functions, and reusable production VIEWs.

In Python (pandas, NumPy, Matplotlib): Replicating and validating every SQL transformation using vectorized DataFrame operations, groupby aggregations, window transforms, conditional arrays, and visual charts.

🗂️ Dataset & Star Schema Architecture

The analysis is performed on the Gold Layer (business-ready star schema) consisting of one fact table and two dimension tables:

Table Name

Type

Rows

Columns

Description

gold.fact_sales (sales)

Fact

60,398

9

Transaction-level order lines (order_number, product_key, customer_key, order_date, shipping_date, due_date, sales_amount, quantity, price).

gold.dim_products (products)

Dimension

295

11

Product catalog attributes (product_key, product_name, category, subcategory, maintenance, cost, product_line, start_date).

gold.dim_customers (customers)

Dimension

18,484

10

Customer demographics (customer_key, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date).

Data Quality Observations Identified During EDA:

sales contains 19 records with missing (NULL/NaT) order_date values (all located between August and November 2013 shipping dates).

customers contains 337 records with missing country values, 17 missing birthdate values, and 15 missing gender values.

products contains 7 records without an assigned category/subcategory and 17 without a product_line.

Zero duplicate rows exist across all three tables.

🧭 Analytical Workflow & Modules

Part 1: Exploratory Data Analysis (EDA)

Database & Metadata Exploration: Inspecting table structures, row counts, data types, and column schemas via information_schema.TABLES, information_schema.COLUMNS, and .info().

Dimension Exploration: Profiling unique product hierarchies (category & subcategory) and customer geographic distributions across 6 countries (United States, Australia, United Kingdom, Germany, France, Canada).

Date & Demographic Boundary Analysis:

Order history spans from 2010-12-29 to 2014-01-28 (3.1 years / 37 months).

Customer birthdates range from 1916-02-10 to 1986-06-25.

Core Business KPI Summary (UNION ALL Report): Consolidated executive snapshot of total revenue, volume, average selling price, order counts, and active customer base.

Magnitude Analysis: Evaluating revenue, order volume, and product costs across countries, genders, categories, and individual customers.

Ranking Analysis: Identifying Top 5 highest-revenue products, Bottom 5 lowest-performing products, Top 10 VIP revenue-generating customers, and lowest-frequency buyers using RANK() and ROW_NUMBER().

Part 2: Advanced Data Analytics & Reporting

Change-Over-Time Analysis: Tracking daily, monthly (%Y-%b), and yearly trends in revenue, unique customers, order count, and units sold.

Cumulative Analysis: Computing Running Totals and Moving Averages both across the entire timeline and partitioned annually (PARTITION BY sales_year).

Year-over-Year (YoY) Product Performance: Comparing each product's annual revenue against:

Its multi-year historical average (Above Average vs. Below Average).

Its prior year's sales using LAG() (Increase, Decrease, or No Change).

Part-to-Whole Analysis: Calculating percentage revenue contribution by product category using window totals.

Data Segmentation:

Product Cost Tiers: Grouping products into Below 100, 100 - 500, 500 - 1000, and Above 1000 cost brackets.

Customer Value Tiers: Classifying customers based on purchase lifespan and total spend:

VIP: Lifespan $\ge 12$ months and Total Spending $> \$5,000$

Regular: Lifespan $\ge 12$ months and Total Spending $\le \$5,000$

New: Lifespan $< 12$ months

Production Reporting Views (gold.report_customers & gold.report_products):

Built reusable SQL views consolidating demographic/product attributes, behavioral segments, and business KPIs including Recency (months since last order), Lifespan, Average Order Value (AOV), Average Order Revenue (AOR), and Average Monthly Spend/Revenue.

🔄 SQL vs. Python (pandas) Implementation Matrix

A core focus of this project is translating set-based SQL logic into vectorized Python operations:

Analytical Concept

SQL Implementation

Python (pandas / NumPy) Equivalent

Table Joins

LEFT JOIN gold.customers c ON c.customer_key = s.customer_key

sales.merge(customers, on='customer_key', how='left')

Multi-Metric Aggregation

GROUP BY year ORDER BY year with COUNT(DISTINCT ...)

.groupby().agg(total_customers=('customer_key', 'nunique'))

Running Totals

SUM(Total_Sales) OVER (PARTITION BY year ORDER BY month)

.groupby(df.index.year)['total_sales'].cumsum()

Partitioned Group Average

AVG(current_sales) OVER (PARTITION BY product_name)

.groupby('product_name')['current_sales'].transform('mean')

Year-over-Year Shift

LAG(current_sales) OVER (PARTITION BY product_name ORDER BY year)

.groupby('product_name')['current_sales'].shift(1)

Conditional Segmentation

CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP' ... END

np.select([cond1, cond2], ['VIP', 'Regular'], default='New')

Date Differences

TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date))

(last_order.dt.year - first_order.dt.year) * 12 + ...

💡 Key Business Insights & Findings

Executive KPIs:

Total Revenue: $29,356,250 ($29,351,258 excluding records with missing order dates)

Total Units Sold: 60,423 across 27,659 unique orders (60,398 line items)

Average Selling Price (ASP): $486.04

Active Customer Base: 18,484 unique customers

Category Revenue Concentration (Pareto Effect):

Bikes dominate the business, generating $28,316,272 (96.46%) of total revenue.

Accessories contribute $700,262 (2.39%), while Clothing contributes $339,716 (1.16%).

(Note: Although Components account for 127 SKUs in the product catalog, they record zero direct retail transactions in fact_sales.)

Top Geographic Markets:

United States ($9,162,327 | 7,482 customers) and Australia ($9,060,172 | 3,591 customers) together drive over 62% of global revenue. Notably, Australian customers exhibit nearly double the average revenue per customer compared to the US.

Top & Bottom Performing Products:

Top Revenue Driver: Mountain-200 Black-46 ($1,373,454), followed closely by Mountain-200 Black-42 ($1,363,128) and Mountain-200 Silver-38 ($1,339,394). All top 5 products belong to the Mountain-200 bike line.

Lowest Revenue Products: Racing Socks-L ($2,430) and Racing Socks-M ($2,682).

Growth Trajectory:

Sales surged dramatically in 2013, reaching $16,344,878 (21,287 orders from 17,427 unique customers)—nearly 2.8x the revenue recorded in 2012 ($5,842,231), with December 2013 marking the single highest-grossing month ($1,874,128).

📐 Key KPI Formulas Used in Reporting Views

Average Order Value (AOV):


$$\text{AOV} = \frac{\text{Total Sales}}{\text{Total Orders}}$$

Average Monthly Spend (Customer):


$$\text{Average Monthly Spend} = \begin{cases} \text{Total Sales}, & \text{if } \text{Lifespan} = 0 \\ \frac{\text{Total Sales}}{\text{Lifespan (Months)}}, & \text{if } \text{Lifespan} > 0 \end{cases}$$

Average Order Revenue (AOR):


$$\text{AOR} = \frac{\text{Total Product Sales}}{\text{Total Product Orders}}$$

📁 Suggested Repository Structure

├── 01_datasets/
│   └── csv-files/
│       ├── gold.fact_sales.csv
│       ├── gold.dim_products.csv
│       └── gold.dim_customers.csv
├── 02_sql_scripts/
│   ├── 01_exploratory_data_analysis.sql
│   ├── 02_advanced_data_analytics.sql
│   ├── 03_report_customers_view.sql
│   └── 04_report_products_view.sql
├── 03_python_analysis/
│   └── eda_and_advanced_analytics.ipynb
├── 04_outputs/
│   └── Yearly_Product_Sales_Performance.csv
└── README.md


🚀 How to Run This Project

1. Running the SQL Queries

Create a schema named gold in your MySQL instance (CREATE DATABASE gold;).

Import gold.fact_sales.csv, gold.dim_products.csv, and gold.dim_customers.csv into tables named sales, products, and customers.

Execute the scripts in 02_sql_scripts/ sequentially to run the EDA queries, window-function analyses, and create the gold.report_customers and gold.report_products views.

2. Running the Python Jupyter Notebook

Clone this repository:

git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>


Install the required dependencies:

pip install pandas numpy matplotlib jupyter


Update the CSV file paths in cell 2 of eda_and_advanced_analytics.ipynb to match your local directory (or relative path 01_datasets/csv-files/...) and run all cells.

🙌 Acknowledgments

Project curriculum and dataset inspired by Baraa Khatib Salkini (Data With Baraa — The Complete SQL Bootcamp: Go from Zero to Hero).

Extended with full Python (pandas, NumPy, Matplotlib) implementations and visualizations to practice end-to-end dual-stack data analytics.
