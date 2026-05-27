-- SQL Script for Data Cleaning and Transformation
-- Project: Financial Performance & Profitability Intelligence Dashboard

-- 1. Create Clean Table Structure
CREATE TABLE IF NOT EXISTS financial_cleaned (
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Customer_Name VARCHAR(100),
    Customer_Segment VARCHAR(50),
    Country VARCHAR(100),
    Region VARCHAR(100),
    Product_Category VARCHAR(100),
    Product_Name VARCHAR(255),
    Quantity INT,
    Unit_Price DECIMAL(18, 2),
    Discount_Percent DECIMAL(5, 2),
    Total_Sales DECIMAL(18, 2),
    Shipping_Cost DECIMAL(18, 2),
    Profit DECIMAL(18, 2),
    Payment_Method VARCHAR(50)
);

-- 2. Data Cleaning Process
-- Remove duplicates and handle nulls while inserting into a clean view or table
CREATE OR REPLACE VIEW v_financial_cleaned AS
SELECT 
    DISTINCT
    Order_ID,
    CAST(Order_Date AS DATE) as Order_Date,
    COALESCE(Customer_Name, 'Unknown') as Customer_Name,
    UPPER(Customer_Segment) as Customer_Segment,
    Country,
    Region,
    UPPER(Product_Category) as Product_Category,
    Product_Name,
    CAST(COALESCE(Quantity, 0) AS INT) as Quantity,
    CAST(COALESCE(Unit_Price, 0) AS DECIMAL(18, 2)) as Unit_Price,
    CAST(COALESCE(Discount_Percent, 0) AS DECIMAL(5, 2)) as Discount_Percent,
    CAST(COALESCE(Total_Sales, 0) AS DECIMAL(18, 2)) as Total_Sales,
    CAST(COALESCE(Shipping_Cost, 0) AS DECIMAL(18, 2)) as Shipping_Cost,
    CAST(COALESCE(Profit, 0) AS DECIMAL(18, 2)) as Profit,
    Payment_Method
FROM raw_financial_data
WHERE Order_ID IS NOT NULL;

-- 3. Data Validation
-- Check for negative sales (should not exist normally)
SELECT * FROM v_financial_cleaned WHERE Total_Sales < 0;

-- Check for outliers in Profit
SELECT * FROM v_financial_cleaned WHERE Profit > 5000 OR Profit < -1000;
