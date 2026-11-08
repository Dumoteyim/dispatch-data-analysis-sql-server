/*
  Dispatch Data Analysis | SQL Server setup
  Run this once from master, then import the source CSV into dbo.Dispatch.
  If DispatchDB already exists, this script leaves it unchanged.
*/
USE [master];
GO

IF DB_ID(N'DispatchDB') IS NULL
BEGIN
    CREATE DATABASE [DispatchDB];
END;
GO

USE [DispatchDB];
GO

/*
  Import dbo.Dispatch with SSMS (Tasks > Import Flat File) or an approved
  bulk-load process. Verify names and types against docs/data-dictionary.md.
*/
SELECT TOP (10) *
FROM dbo.Dispatch;
GO
