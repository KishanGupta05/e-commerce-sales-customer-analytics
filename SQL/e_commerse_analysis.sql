CREATE TABLE Ecommerce_Analytics(
    Transaction_ID VARCHAR(20),
    Order_ID VARCHAR(20),
    Customer_ID VARCHAR(20),
    Customer_Name VARCHAR(100),
    Customer_Age INTEGER,
    Customer_Gender VARCHAR(30),
    Customer_Segment VARCHAR(50),
    Order_Date DATE,
    Order_Time TIME,
    Sales_Channel VARCHAR(50),
    Store_ID VARCHAR(20),
    Store_Name VARCHAR(100),
    Country VARCHAR(100),
    Region VARCHAR(100),
    City VARCHAR(100),
    Product_ID VARCHAR(20),
    Product_Name VARCHAR(150),
    Product_Category VARCHAR(100),
    Product_Subcategory VARCHAR(100),
    Quantity INTEGER,
    Unit_Price NUMERIC(12,2),
    Discount_Percentage NUMERIC(5,2),
    Sales_Amount NUMERIC(14,2),
    Cost_Amount NUMERIC(14,2),
    Profit NUMERIC(14,2),
    Payment_Method VARCHAR(50),
    Order_Status VARCHAR(50),
    Shipping_Method VARCHAR(50),
    Delivery_Days INTEGER,
    Return_Flag VARCHAR(10),
    Return_Reason VARCHAR(255),
    Sales_Representative VARCHAR(100),
    Promotion_Code VARCHAR(50),
    Customer_Rating NUMERIC(3,2),
    Inventory_Level INTEGER,
    Order_Year INTEGER
);


SELECT * FROM Ecommerce_Analytics;

SELECT COUNT(*) AS total_rows
FROM ecommerce_analytics;

SELECT *
FROM ecommerce_analytics
LIMIT 10;

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'ecommerce_analytics';

SELECT
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS missing_transaction_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE sales_amount IS NULL) AS missing_sales,
    COUNT(*) FILTER (WHERE cost_amount IS NULL) AS missing_cost,
    COUNT(*) FILTER (WHERE profit IS NULL) AS missing_profit
FROM ecommerce_analytics;


--Business problem: Kuch products achha revenue generate kar sakte hain, lekin unka profit comparatively kam ho sakta hai.
SELECT product_name ,SUM(sales_amount) AS Total_Revenue,
SUM(cost_amount) AS Total_cost,
SUM(profit) AS Total_profit,
ROUND(SUM(profit) /NULLIF(SUM(sales_amount),0) * 100,2) AS profit_Margin
FROM ecommerce_analytics
WHERE product_name is NOT NULL
GROUP BY product_name
HAVING SUM(sales_amount) >0
ORDER BY profit_Margin ASC;

SELECT * FROM Ecommerce_Analytics;

--Business Question: Kaunse products frequently sell hote hain, lekin unka profit margin low hai?
SELECT product_name, sum(quantity) AS Total_units_sold,
SUM(sales_amount) AS Total_Revenue,
SUM(profit) AS Total_Profit,
ROUND(SUM(profit) /NULLIF(SUM(sales_amount),0) * 100,2) AS profit_Margin
FROM ecommerce_analytics
GROUP BY product_name
HAVING sum(quantity)>500 AND sum(sales_amount)>0
ORDER BY sum(quantity) DESC;

--Business Question: Kaunsi product categories revenue mein strong hain, lekin profitability mein weak hain?
SELECT product_category, sum(quantity) AS Total_units_sold,
SUM(sales_amount) AS Total_Revenue,
SUM(cost_amount) AS Total_cost_Amount,
SUM(profit) AS Total_Profit,
ROUND(SUM(profit) /NULLIF(SUM(sales_amount),0) * 100,2) AS profit_Margin
FROM ecommerce_analytics
GROUP BY product_category
HAVING  sum(sales_amount)>0
ORDER BY profit_Margin ASC;

##
SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales_amount), 0) * 100,
        2
    ) AS profit_margin
FROM ecommerce_analytics
WHERE order_date IS NOT NULL
GROUP BY DATE_TRUNC('month', order_date)::DATE
ORDER BY month;

-- month revenue pichhle month ke comparison mein kitna increase ya decrease hua?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales_amount) AS total_revenue,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)::DATE
),

previous_month AS (
    SELECT
        month,
        total_revenue,
        total_profit,
        LAG(total_revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    month,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(previous_month_revenue, 2) AS previous_month_revenue,
    ROUND(
        (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS revenue_growth_percentage
FROM previous_month
ORDER BY month;


--Kya revenue badhne par profit bhi badh raha hai?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales_amount) AS total_revenue,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)::DATE
),

monthly_comparison AS (
    SELECT
        month,
        total_revenue,
        total_profit,

        LAG(total_revenue) OVER (
            ORDER BY month
        ) AS previous_revenue,

        LAG(total_profit) OVER (
            ORDER BY month
        ) AS previous_profit

    FROM monthly_sales
)

SELECT
    month,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_profit, 2) AS total_profit,

    ROUND(
        (total_revenue - previous_revenue)
        / NULLIF(previous_revenue, 0) * 100,
        2
    ) AS revenue_growth_pct,

    ROUND(
        (total_profit - previous_profit)
        / NULLIF(previous_profit, 0) * 100,
        2
    ) AS profit_growth_pct

FROM monthly_comparison
ORDER BY month;


--Who are our most valuable customers, and how do their purchasing behaviours differ?
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(sales_amount) /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
GROUP BY
    customer_id,
    customer_name
ORDER BY total_revenue DESC;


SELECT * FROM ecommerce_analytics;

--Top 10 customers by revenue
SELECT
    customer_id,
    customer_name,
    SUM(sales_amount) AS customer_revenue
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
  AND customer_name IS NOT NULL
GROUP BY customer_id, customer_name
ORDER BY customer_revenue DESC
LIMIT 10;


--Top 10 customers by profit
SELECT
    customer_id,
    customer_name,
    SUM(profit) AS total_profit
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
  AND customer_name IS NOT NULL
GROUP BY customer_id, customer_name
ORDER BY total_profit DESC
LIMIT 10;


--Customers with the highest number of orders
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales_amount) AS total_revenue
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
  AND customer_name IS NOT NULL
GROUP BY customer_id, customer_name
ORDER BY total_orders DESC
LIMIT 10;


-- Customers with the highest average order value
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales_amount) AS total_revenue,
    ROUND(
        SUM(sales_amount) /
        NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
    AND customer_name IS NOT NULL
GROUP BY customer_id, customer_name
HAVING COUNT(DISTINCT order_id) > 0
ORDER BY average_order_value DESC
LIMIT 10;

--Which customers generate high revenue but relatively low profit?
SELECT
    customer_id,
    customer_name,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales_amount), 0) * 100,
        2
    ) AS profit_margin
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
  AND customer_name IS NOT NULL
GROUP BY customer_id, customer_name
HAVING SUM(sales_amount) > 0
ORDER BY profit_margin ASC
LIMIT 10;


--
WITH customer_analysis AS (
    SELECT
        customer_id,
        customer_name,
        SUM(sales_amount) AS total_revenue,
        SUM(profit) AS total_profit,
        ROUND(
            SUM(profit) / NULLIF(SUM(sales_amount), 0) * 100,
            2
        ) AS profit_margin
    FROM ecommerce_analytics
    WHERE customer_id IS NOT NULL
      AND customer_name IS NOT NULL
    GROUP BY customer_id, customer_name
    HAVING SUM(sales_amount) > 0
)
SELECT *
FROM customer_analysis
WHERE total_revenue >= 1000
  AND profit_margin < 5
ORDER BY total_revenue DESC;


--Which products generate the highest losses for customers who have negative overall profitability?
SELECT
    product_name,
    COUNT(DISTINCT customer_id) AS affected_customers,
    SUM(quantity) AS total_quantity_sold,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit
FROM ecommerce_analytics
WHERE customer_id IN (
    SELECT customer_id
    FROM ecommerce_analytics
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
    HAVING SUM(profit) < 0
)
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 10;


--Which products are generating losses for the company overall?
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales_amount), 0) * 100,
        2
    ) AS profit_margin
FROM ecommerce_analytics
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

--
SELECT
    customer_id,
    SUM(profit) AS total_profit
FROM ecommerce_analytics
WHERE customer_id IS NOT NULL
GROUP BY customer_id
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;


--Identify the products responsible for customer losses
WITH loss_customers AS (
    SELECT
        customer_id
    FROM ecommerce_analytics
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
    HAVING SUM(profit) < 0
)
SELECT
    e.product_name,
    COUNT(DISTINCT e.customer_id) AS affected_customers,
    SUM(e.quantity) AS total_quantity_sold,
    ROUND(SUM(e.sales_amount)::numeric, 2) AS total_revenue,
    ROUND(SUM(e.profit)::numeric, 2) AS total_profit
FROM ecommerce_analytics e
JOIN loss_customers lc
    ON e.customer_id = lc.customer_id
GROUP BY e.product_name
HAVING SUM(e.profit) < 0
ORDER BY SUM(e.profit) ASC;



--same products ki profitability across all customers check karenge.
SELECT
    product_name,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales_amount)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(
        SUM(profit)::numeric
        / NULLIF(SUM(sales_amount)::numeric, 0) * 100,
        2
    ) AS profit_margin_pct
FROM ecommerce_analytics
WHERE product_name IN (
    'Meeting Table',
    'ProBook 16 Laptop',
    'EdgeTab 11 Tablet',
    'Webcam HD',
    'AeroBook 14 Laptop',
    'Standing Desk',
    'Security Camera',
    'Copy Paper Box',
    'Laser Toner'
)
GROUP BY product_name
ORDER BY total_profit ASC;


--Which products generate high revenue but have relatively low profit margins?
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales_amount)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(
        SUM(profit)::numeric
        / NULLIF(SUM(sales_amount)::numeric, 0) * 100,
        2
    ) AS profit_margin_pct
FROM ecommerce_analytics
GROUP BY product_name
HAVING SUM(sales_amount) > 0
ORDER BY profit_margin_pct ASC;


-- Top 10 products by total profit
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales_amount)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(
        SUM(profit)::numeric
        / NULLIF(SUM(sales_amount)::numeric, 0) * 100,
        2
    ) AS profit_margin_pct
FROM ecommerce_analytics
WHERE product_name IS NOT NULL
GROUP BY product_name
HAVING SUM(sales_amount) > 0
ORDER BY total_profit DESC
LIMIT 10;


-- Products with high sales volume but relatively low profit margins
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales_amount)::numeric, 2) AS total_revenue,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    ROUND(
        SUM(profit)::numeric
        / NULLIF(SUM(sales_amount)::numeric, 0) * 100,
        2
    ) AS profit_margin_pct
FROM ecommerce_analytics
WHERE product_name IS NOT NULL
GROUP BY product_name
HAVING SUM(sales_amount) > 0
ORDER BY total_quantity_sold DESC
LIMIT 10;


--Compare revenue, profit and profit margin
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct
FROM ecommerce_analytics
WHERE product_name IS NOT NULL
GROUP BY product_name
HAVING SUM(sales_amount) > 0
ORDER BY profit_margin_pct ASC
LIMIT 10;


--Why does Copy Paper Box have a relatively low profit margin despite having the highest sales volume among the products shown?
SELECT
    product_name,
    SUM(quantity) AS total_quantity_sold,

    ROUND(
        SUM(sales_amount) / NULLIF(SUM(quantity), 0),
        2
    ) AS avg_revenue_per_unit,

    ROUND(
        SUM(profit) / NULLIF(SUM(quantity), 0),
        2
    ) AS avg_profit_per_unit,

    ROUND(
        (SUM(sales_amount) - SUM(profit))
        / NULLIF(SUM(quantity), 0),
        2
    ) AS avg_cost_per_unit,

    ROUND(
        SUM(profit) / NULLIF(SUM(sales_amount), 0) * 100,
        2
    ) AS profit_margin_pct

FROM ecommerce_analytics

WHERE product_name IS NOT NULL
    AND quantity > 0

GROUP BY product_name

HAVING SUM(sales_amount) > 0

ORDER BY profit_margin_pct ASC

LIMIT 10;


SELECT * FROM ecommerce_analytics;

--Har region mein kaun se top 3 products sabse zyada total profit generate karte hain?
WITH product_profit AS (
    SELECT
        region,
        product_name,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE region IS NOT NULL
      AND profit IS NOT NULL
    GROUP BY region, product_name
),
ranked AS (
    SELECT
        region,
        product_name,
        total_profit,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY total_profit DESC) AS rank_in_region
    FROM product_profit
)
SELECT region, product_name, total_profit, rank_in_region
FROM ranked
WHERE rank_in_region <= 3
ORDER BY region, rank_in_region;


--Har region mein profit ke basis par top 3 products identify karo.
WITH product_profit AS (
    SELECT
        region,
        product_name,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE region IS NOT NULL
      AND profit IS NOT NULL
    GROUP BY region, product_name
),
ranked AS (
    SELECT
        region,
        product_name,
        total_profit,
        DENSE_RANK() OVER (PARTITION BY region ORDER BY total_profit DESC) AS profit_rank
    FROM product_profit
)
SELECT region, product_name, total_profit, profit_rank
FROM ranked
WHERE profit_rank <= 3
ORDER BY region, profit_rank, product_name;



--Har region mein kaun-se products ka profit us region ke average product profit se zyada hai?
WITH product_profit AS (
    SELECT
        region,
        product_name,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE region IS NOT NULL
      AND profit IS NOT NULL
    GROUP BY region, product_name
),
with_avg AS (
    SELECT
        region,
        product_name,
        total_profit,
        AVG(total_profit) OVER (PARTITION BY region) AS regional_avg_profit
    FROM product_profit
)
SELECT
    region,
    product_name,
    total_profit,
    regional_avg_profit
FROM with_avg
WHERE total_profit > regional_avg_profit
ORDER BY region, total_profit DESC;


--Har region mein products ko profit ke descending order mein arrange karke running total profit calculate karo.
WITH product_profit AS (
    SELECT
        region,
        product_name,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE region IS NOT NULL
      AND profit IS NOT NULL
    GROUP BY region, product_name
)
SELECT
    region,
    product_name,
    total_profit,
    SUM(total_profit) OVER (
        PARTITION BY region
        ORDER BY total_profit DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_profit
FROM product_profit
ORDER BY region, total_profit DESC;


--Har region ke total profit mein har product kitna percentage contribute karta hai?
WITH product_profit AS (
    SELECT
        region,
        product_name,
        SUM(profit) AS total_profit
    FROM ecommerce_analytics
    WHERE region IS NOT NULL
      AND profit IS NOT NULL
    GROUP BY region, product_name
),
with_region_total AS (
    SELECT
        region,
        product_name,
        total_profit,
        SUM(total_profit) OVER (PARTITION BY region) AS regional_total_profit
    FROM product_profit
)
SELECT
    region,
    product_name,
    total_profit,
    regional_total_profit,
    ROUND(100.0 * total_profit / NULLIF(regional_total_profit, 0), 2) AS contribution_pct
FROM with_region_total
ORDER BY region, contribution_pct DESC;



SELECT * FROM ecommerce_analytics;
--Har month ki sales ko previous month ki sales se compare karke percentage growth calculate karo.
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(sales_amount) AS monthly_sales
    FROM ecommerce_analytics
    WHERE order_date IS NOT NULL
      AND sales_amount IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
),
with_previous AS (
    SELECT
        sales_month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    monthly_sales,
    previous_month_sales,
    ROUND(
        100.0 * (monthly_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0),
        2
    ) AS growth_percentage
FROM with_previous
ORDER BY sales_month;


--Kaunse 3 months mein sabse zyada sales hui aur kaunse 3 months mein sabse kam?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS sales_month,
        SUM(sales_amount) AS monthly_sales
    FROM ecommerce_analytics
    WHERE order_date IS NOT NULL
      AND sales_amount IS NOT NULL
    GROUP BY DATE_TRUNC('month', order_date)
),
ranked AS (
    SELECT
        sales_month,
        monthly_sales,
        ROW_NUMBER() OVER (ORDER BY monthly_sales DESC) AS desc_rank,
        ROW_NUMBER() OVER (ORDER BY monthly_sales ASC) AS asc_rank
    FROM monthly_sales
)
SELECT
    sales_month,
    monthly_sales,
    CASE
        WHEN desc_rank <= 3 THEN 'Top 3'
        ELSE 'Bottom 3'
    END AS category
FROM ranked
WHERE desc_rank <= 3
   OR asc_rank <= 3
ORDER BY monthly_sales DESC;







