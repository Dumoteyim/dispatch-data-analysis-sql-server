/*
  Dispatch Data Analysis | Exploration and business analysis
  Run in DispatchDB after dbo.Dispatch and the dimensions exist.
  No output values are hard-coded; results depend on your source CSV.
*/
USE [DispatchDB];
GO

/* 1. Inspect the imported transaction table. */
SELECT TOP (100) *
FROM dbo.Dispatch
ORDER BY DispatchID;

SELECT COUNT_BIG(*) AS DispatchRows
FROM dbo.Dispatch;
GO

/* 2. Report-style filters. Adjust the thresholds to match the question. */
SELECT * FROM dbo.DimProduct WHERE ProductID > 103;
SELECT * FROM dbo.Dispatch WHERE SalesAmount > 30000;
SELECT * FROM dbo.Dispatch WHERE Quantity >= 2;
SELECT * FROM dbo.DimLocation WHERE State = N'Lagos';
SELECT * FROM dbo.Dispatch WHERE State = N'Lagos';
GO

/* 3. Ordered customer and product lists. TOP requires ORDER BY for stability. */
SELECT CustomerID, CustomerName
FROM dbo.DimCustomer
ORDER BY CustomerName ASC;

SELECT CustomerID, CustomerName
FROM dbo.DimCustomer
ORDER BY CustomerName DESC;

SELECT TOP (5) CustomerID, CustomerName
FROM dbo.DimCustomer
ORDER BY CustomerName ASC, CustomerID ASC;

SELECT ProductID, ProductName
FROM dbo.DimProduct
ORDER BY ProductName ASC;

SELECT ProductID, ProductName
FROM dbo.DimProduct
ORDER BY ProductID DESC;
GO

/* 4. Transaction-level product performance and Laptop Stand detail. */
SELECT D.DispatchID, P.ProductID, P.ProductName, D.Quantity, D.SalesAmount
FROM dbo.Dispatch AS D
INNER JOIN dbo.DimProduct AS P
    ON D.ProductID = P.ProductID;

SELECT D.DispatchID, P.ProductID, P.ProductName, D.Quantity, D.SalesAmount
FROM dbo.Dispatch AS D
INNER JOIN dbo.DimProduct AS P
    ON D.ProductID = P.ProductID
WHERE P.ProductName = N'Laptop Stand';
GO

/* 5. Aggregate measures by product, customer, and location. */
SELECT P.ProductID, P.ProductName,
       SUM(CONVERT(decimal(19, 4), D.SalesAmount)) AS TotalSales,
       SUM(CONVERT(bigint, D.Quantity)) AS UnitsSold,
       COUNT_BIG(*) AS DispatchCount
FROM dbo.Dispatch AS D
INNER JOIN dbo.DimProduct AS P ON P.ProductID = D.ProductID
GROUP BY P.ProductID, P.ProductName
ORDER BY TotalSales DESC;

SELECT C.CustomerID, C.CustomerName,
       SUM(CONVERT(decimal(19, 4), D.SalesAmount)) AS TotalSales,
       COUNT_BIG(*) AS DispatchCount
FROM dbo.Dispatch AS D
INNER JOIN dbo.DimCustomer AS C ON C.CustomerID = D.CustomerID
GROUP BY C.CustomerID, C.CustomerName
ORDER BY TotalSales DESC;

-- Match both columns to avoid cross-state city-name collisions.
SELECT L.State, L.City,
       SUM(CONVERT(decimal(19, 4), D.SalesAmount)) AS TotalSales,
       COUNT_BIG(*) AS DispatchCount
FROM dbo.Dispatch AS D
INNER JOIN dbo.DimLocation AS L
    ON L.City = D.City AND L.State = D.State
GROUP BY L.State, L.City
ORDER BY TotalSales DESC;
GO

/* 6. Monthly trend. MonthNumber keeps calendar ordering chronological. */
SELECT YEAR(Order_Date) AS [Year],
       MONTH(Order_Date) AS MonthNumber,
       DATENAME(MONTH, Order_Date) AS MonthName,
       SUM(CONVERT(decimal(19, 4), SalesAmount)) AS TotalSales,
       COUNT_BIG(*) AS DispatchCount
FROM dbo.Dispatch
WHERE Order_Date IS NOT NULL
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATENAME(MONTH, Order_Date)
ORDER BY [Year], MonthNumber;
GO

/* 7. Referential and null checks before enforcing constraints. */
SELECT
    SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS NullProductID,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS NullCustomerID,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS NullOrderDate,
    SUM(CASE WHEN City IS NULL OR State IS NULL THEN 1 ELSE 0 END) AS IncompleteLocation
FROM dbo.Dispatch;

SELECT D.ProductID, COUNT_BIG(*) AS UnmatchedRows
FROM dbo.Dispatch AS D
LEFT JOIN dbo.DimProduct AS P ON P.ProductID = D.ProductID
WHERE D.ProductID IS NOT NULL AND P.ProductID IS NULL
GROUP BY D.ProductID;

SELECT D.CustomerID, COUNT_BIG(*) AS UnmatchedRows
FROM dbo.Dispatch AS D
LEFT JOIN dbo.DimCustomer AS C ON C.CustomerID = D.CustomerID
WHERE D.CustomerID IS NOT NULL AND C.CustomerID IS NULL
GROUP BY D.CustomerID;

SELECT D.Order_Date, COUNT_BIG(*) AS UnmatchedRows
FROM dbo.Dispatch AS D
LEFT JOIN dbo.DimDate AS DD ON DD.Order_Date = CAST(D.Order_Date AS date)
WHERE D.Order_Date IS NOT NULL AND DD.Order_Date IS NULL
GROUP BY D.Order_Date;
GO
