/*
  Build distinct lookup dimensions from dbo.Dispatch.
  Run in DispatchDB after importing and validating the source CSV.
  SELECT INTO inherits source data types. Inspect resulting types and key
  uniqueness before adding constraints to a production model.
*/
USE [DispatchDB];
GO

IF OBJECT_ID(N'dbo.Dispatch', N'U') IS NULL
    THROW 50001, 'dbo.Dispatch is missing. Import the CSV before building dimensions.', 1;
GO

DROP TABLE IF EXISTS dbo.DimProduct;
DROP TABLE IF EXISTS dbo.DimCustomer;
DROP TABLE IF EXISTS dbo.DimDate;
DROP TABLE IF EXISTS dbo.DimLocation;
GO

SELECT DISTINCT
    ProductID,
    ProductName
INTO dbo.DimProduct
FROM dbo.Dispatch;
GO

-- DISTINCT prevents repeated customer transactions from creating duplicate rows.
SELECT DISTINCT
    CustomerID,
    CustomerName
INTO dbo.DimCustomer
FROM dbo.Dispatch;
GO

SELECT DISTINCT
    CAST(Order_Date AS date) AS Order_Date,
    YEAR(Order_Date) AS [Year],
    MONTH(Order_Date) AS MonthNumber,
    DAY(Order_Date) AS DayNumber,
    LEFT(DATENAME(MONTH, Order_Date), 3) AS MonthName,
    LEFT(DATENAME(WEEKDAY, Order_Date), 3) AS DayName
INTO dbo.DimDate
FROM dbo.Dispatch
WHERE Order_Date IS NOT NULL;
GO

-- City and State together identify a location more safely than City alone.
SELECT DISTINCT
    City,
    State
INTO dbo.DimLocation
FROM dbo.Dispatch;
GO

/* Review candidate key uniqueness and NULLs before defining PK/FK constraints. */
SELECT 'DimProduct' AS DimensionName, COUNT_BIG(*) AS RowsTotal,
       COUNT_BIG(DISTINCT ProductID) AS DistinctIDs
FROM dbo.DimProduct
UNION ALL
SELECT 'DimCustomer', COUNT_BIG(*), COUNT_BIG(DISTINCT CustomerID)
FROM dbo.DimCustomer
UNION ALL
SELECT 'DimDate', COUNT_BIG(*), COUNT_BIG(DISTINCT Order_Date)
FROM dbo.DimDate;
GO

SELECT TOP (20) City, State, COUNT_BIG(*) AS DuplicatePairs
FROM dbo.DimLocation
GROUP BY City, State
HAVING COUNT_BIG(*) > 1;
GO
