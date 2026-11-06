-- =====================================================
-- Q1. What are the total sales, total profit, total
-- orders, total quantity and overall profit margin?
-- =====================================================

SELECT
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    SUM(Quantity) AS Total_Quantity,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin
FROM retail_orders;


-- =====================================================
-- Q2. Which product categories and sub-categories
-- generate the highest sales and profit?
-- =====================================================

SELECT
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM retail_orders
GROUP BY Category, `Sub-Category`
ORDER BY Total_Sales DESC;


-- =====================================================
-- Q3. How do sales and profits vary month over month?
-- =====================================================

SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Year,
    MONTH(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) AS Month,
    ROUND(SUM(Sales), 2) AS Monthly_Sales,
    ROUND(SUM(Profit), 2) AS Monthly_Profit
FROM retail_orders
GROUP BY Year, Month
ORDER BY Year, Month;


-- =====================================================
-- Q4. How do different discount levels impact sales
-- and profitability?
-- =====================================================

SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.10 THEN '1-10%'
        WHEN Discount <= 0.20 THEN '11-20%'
        WHEN Discount <= 0.30 THEN '21-30%'
        WHEN Discount <= 0.40 THEN '31-40%'
        ELSE 'Above 40%'
    END AS Discount_Band,

    COUNT(*) AS Total_Transactions,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(Profit), 2) AS Average_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin

FROM retail_orders
GROUP BY Discount_Band
ORDER BY MIN(Discount);


-- =====================================================
-- Q5. Which products and sub-categories are generating
-- the highest losses?
-- =====================================================

SELECT
    Category,
    `Sub-Category`,
    `Product Name`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_orders
GROUP BY
    Category,
    `Sub-Category`,
    `Product Name`
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC
LIMIT 10;


-- =====================================================
-- Q6. Which regions and states contribute the most
-- to sales and profit?
-- =====================================================

SELECT
    Region,
    State,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin
FROM retail_orders
GROUP BY Region, State
ORDER BY Total_Sales DESC;


-- =====================================================
-- Q7. Which customer segments generate the highest
-- revenue and profitability?
-- =====================================================

SELECT
    Segment,
    COUNT(DISTINCT `Customer ID`) AS Total_Customers,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(AVG(Sales), 2) AS Average_Line_Sales
FROM retail_orders
GROUP BY Segment
ORDER BY Total_Sales DESC;


-- =====================================================
-- Q8. Who are the top 10 customers based on total sales?
-- =====================================================

SELECT
    `Customer ID`,
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_orders
GROUP BY
    `Customer ID`,
    `Customer Name`
ORDER BY Total_Sales DESC
LIMIT 10;


-- =====================================================
-- Q9. Which shipping modes have the longest average
-- delivery time?
-- =====================================================

SELECT
    `Ship Mode`,
    COUNT(DISTINCT `Order ID`) AS Total_Orders,

    ROUND(
        AVG(
            DATEDIFF(
                STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),
                STR_TO_DATE(`Order Date`, '%m/%d/%Y')
            )
        ), 2
    ) AS Average_Shipping_Days,

    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit

FROM retail_orders
GROUP BY `Ship Mode`
ORDER BY Average_Shipping_Days;


-- =====================================================
-- Q10. What are the top 3 most profitable products
-- within each product category?
-- =====================================================

WITH Product_Profit AS (
    SELECT
        Category,
        `Sub-Category`,
        `Product Name`,
        ROUND(SUM(Sales), 2) AS Total_Sales,
        ROUND(SUM(Profit), 2) AS Total_Profit
    FROM retail_orders
    GROUP BY
        Category,
        `Sub-Category`,
        `Product Name`
),

Ranked_Products AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Profit DESC
        ) AS Product_Rank
    FROM Product_Profit
)

SELECT *
FROM Ranked_Products
WHERE Product_Rank <= 3
ORDER BY Category, Product_Rank;
