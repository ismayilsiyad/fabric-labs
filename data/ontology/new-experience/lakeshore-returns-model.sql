-- Task 1. Run in LakeshoreInventoryDW after the three returns tables are loaded into LakeshoreStaticDataLH.
-- Uses the Assignment 3 model dimensions DimStoreModel and DimProductModel.
CREATE TABLE dbo.DimReasonModel (ReasonKey int NOT NULL, ReasonCode varchar(20), ReasonDescription varchar(100), ReasonGroup varchar(30));
INSERT INTO dbo.DimReasonModel SELECT CAST(ROW_NUMBER() OVER(ORDER BY ReasonCode) AS int), ReasonCode, ReasonDescription, ReasonGroup FROM LakeshoreStaticDataLH.dbo.dim_return_reasons;
CREATE TABLE dbo.FactReturns AS SELECT s.StoreKey, p.ProductKey, r.ReasonKey, CAST(CONVERT(char(8),CAST(f.ReturnDateTime AS date),112) AS int) AS DateKey, f.ReturnId, f.ReturnQuantity, f.RefundAmountUSD FROM LakeshoreStaticDataLH.dbo.fact_store_returns f JOIN dbo.DimStoreModel s ON f.StoreId=s.StoreId JOIN dbo.DimProductModel p ON f.ProductId=p.ProductId JOIN dbo.DimReasonModel r ON f.ReasonCode=r.ReasonCode;
CREATE TABLE dbo.FactStoreSalesWeekly AS SELECT s.StoreKey, p.ProductKey, f.WeekStartDate, f.UnitsSold FROM LakeshoreStaticDataLH.dbo.fact_store_sales f JOIN dbo.DimStoreModel s ON f.StoreId=s.StoreId JOIN dbo.DimProductModel p ON f.ProductId=p.ProductId;
ALTER TABLE dbo.DimReasonModel ADD CONSTRAINT PK_ReasonModel PRIMARY KEY NONCLUSTERED (ReasonKey) NOT ENFORCED;
ALTER TABLE dbo.FactReturns ADD CONSTRAINT FK_Returns_Store FOREIGN KEY (StoreKey) REFERENCES dbo.DimStoreModel(StoreKey) NOT ENFORCED;
ALTER TABLE dbo.FactReturns ADD CONSTRAINT FK_Returns_Product FOREIGN KEY (ProductKey) REFERENCES dbo.DimProductModel(ProductKey) NOT ENFORCED;
ALTER TABLE dbo.FactReturns ADD CONSTRAINT FK_Returns_Reason FOREIGN KEY (ReasonKey) REFERENCES dbo.DimReasonModel(ReasonKey) NOT ENFORCED;
ALTER TABLE dbo.FactStoreSalesWeekly ADD CONSTRAINT FK_Sales_Store FOREIGN KEY (StoreKey) REFERENCES dbo.DimStoreModel(StoreKey) NOT ENFORCED;
ALTER TABLE dbo.FactStoreSalesWeekly ADD CONSTRAINT FK_Sales_Product FOREIGN KEY (ProductKey) REFERENCES dbo.DimProductModel(ProductKey) NOT ENFORCED;
-- Checks: row counts should be 252, 192, 6 (no rows lost in the joins).
SELECT (SELECT COUNT(*) FROM dbo.FactReturns) AS ReturnRows, (SELECT COUNT(*) FROM dbo.FactStoreSalesWeekly) AS SalesRows, (SELECT COUNT(*) FROM dbo.DimReasonModel) AS ReasonRows;
-- Grain check: one row per ReturnId.
SELECT COUNT(*) AS DuplicateReturnIds FROM (SELECT ReturnId FROM dbo.FactReturns GROUP BY ReturnId HAVING COUNT(*)>1) d;
-- Answer: return rate by store (returned units divided by units sold).
SELECT s.StoreId, s.City, SUM(f.UnitsSold) AS UnitsSold, MAX(r.RetUnits) AS ReturnedUnits, MAX(r.Refund) AS RefundUSD, CAST(100.0*MAX(r.RetUnits)/SUM(f.UnitsSold) AS decimal(5,2)) AS ReturnRatePct FROM dbo.FactStoreSalesWeekly f JOIN dbo.DimStoreModel s ON s.StoreKey=f.StoreKey JOIN (SELECT StoreKey, SUM(ReturnQuantity) AS RetUnits, SUM(RefundAmountUSD) AS Refund FROM dbo.FactReturns GROUP BY StoreKey) r ON r.StoreKey=f.StoreKey GROUP BY s.StoreId, s.City ORDER BY ReturnRatePct DESC;
