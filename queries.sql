CREATE TABLE Sales (
    Sale_date DATE,
    Country VARCHAR(50),
    Category VARCHAR(50),
    Product VARCHAR(50),
    Sales INT
);

INSERT INTO Sales (Sale_date, Country, Category, Product, Sales)
VALUES 
    ('2021-01-01', 'USA', 'Retail', 'UUID1', 10000),
    ('2021-01-01', 'USA', 'Healthcare', 'UUID2', 2000),
    ('2021-01-01', 'Canada', 'Retail', 'UUID3', 30000),
    ('2021-01-01', 'Canada', 'Hospitality', 'UUID4', 5000),
    ('2021-02-01', 'USA', 'Retail', 'UUID5', 10000),
    ('2021-02-01', 'USA', 'Healthcare', 'UUID6', 2000),
    ('2021-02-01', 'Canada', 'Retail', 'UUID7', 30000),
    ('2021-02-01', 'Canada', 'Hospitality', 'UUID8', 5000);
--------------------------------------------------------------------------------
WITH SalesSummary AS (
    SELECT 
        Country,
        Category,
        SUM(Sales) AS Total_Sales
    FROM 
        Sales
    WHERE 
        EXTRACT(YEAR FROM Sale_date) = 2021
    GROUP BY 
        Country, Category
),
RankedSales AS (
    SELECT 
        Country,
        Category,
        Total_Sales,
        RANK() OVER (PARTITION BY Country ORDER BY Total_Sales DESC) AS Rank
    FROM 
        SalesSummary
)
SELECT 
    Country,
    Category,
    Total_Sales
FROM 
    RankedSales
WHERE 
    Rank <= 3
ORDER BY 
    Country, Total_Sales DESC;
--------------------------------------------------------------------------------
WITH JanSales AS (
    SELECT Product, Sales
    FROM Sales
    WHERE EXTRACT(MONTH FROM Sale_date) = 1 AND EXTRACT(YEAR FROM Sale_date) = 2021
),
FebSales AS (
    SELECT Product, Sales
    FROM Sales
    WHERE EXTRACT(MONTH FROM Sale_date) = 2 AND EXTRACT(YEAR FROM Sale_date) = 2021
),
BothJanFeb AS (
    SELECT COALESCE(JanSales.Product, FebSales.Product) AS Product,
           COALESCE(JanSales.Sales, 0) + COALESCE(FebSales.Sales, 0) AS Sales
    FROM JanSales
    INNER JOIN FebSales ON JanSales.Product = FebSales.Product
),
OnlyJan AS (
    SELECT SUM(Sales) AS jan_sales
    FROM JanSales
    WHERE Product NOT IN (SELECT Product FROM FebSales)
),
OnlyFeb AS (
    SELECT SUM(Sales) AS feb_sales
    FROM FebSales
    WHERE Product NOT IN (SELECT Product FROM JanSales)
),
BothSales AS (
    SELECT SUM(Sales) AS jan_feb_sales
    FROM BothJanFeb
)

SELECT 
    COALESCE(BothSales.jan_feb_sales, 0) AS jan_feb_sales,
    COALESCE(OnlyJan.jan_sales, 0) AS jan_sales,
    COALESCE(OnlyFeb.feb_sales, 0) AS feb_sales
FROM 
    BothSales, OnlyJan, OnlyFeb;
--------------------------------------------------------------------------------
