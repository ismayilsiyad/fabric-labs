-- Assignment 3. Run once in a NEW Warehouse, one statement at a time.
-- Source lakehouse is the correctly loaded Assignment 2 LakeshoreStaticDataLH.
-- CTAS creates staging dimensions; explicit-schema model dimensions have NOT NULL keys.
CREATE TABLE dbo.DimStore AS SELECT CAST(ROW_NUMBER() OVER(ORDER BY LocationId) AS int) AS StoreKey, LocationId AS StoreId, Name AS StoreName, Region, City, PriorityTier FROM LakeshoreStaticDataLH.dbo.dimlocations WHERE LocationType='STORE';
CREATE TABLE dbo.DimProduct AS SELECT CAST(ROW_NUMBER() OVER(ORDER BY ProductId) AS int) AS ProductKey, ProductId, ProductName, Category, StorageClass, StandardUnitCost FROM LakeshoreStaticDataLH.dbo.dimproducts;
CREATE TABLE dbo.DimDate AS SELECT DISTINCT CAST(CONVERT(char(8),CAST(SnapshotDateTime AS date),112) AS int) AS DateKey, CAST(SnapshotDateTime AS date) AS SnapshotDate FROM LakeshoreStaticDataLH.dbo.fact_inventory_positions;
CREATE TABLE dbo.DimStoreModel (StoreKey int NOT NULL, StoreId varchar(50), StoreName varchar(100), Region varchar(50), City varchar(50), PriorityTier varchar(20));
INSERT INTO dbo.DimStoreModel SELECT * FROM dbo.DimStore;
CREATE TABLE dbo.DimProductModel (ProductKey int NOT NULL, ProductId varchar(50), ProductName varchar(100), Category varchar(50), StorageClass varchar(20), StandardUnitCost float);
INSERT INTO dbo.DimProductModel SELECT * FROM dbo.DimProduct;
CREATE TABLE dbo.DimDateModel (DateKey int NOT NULL, SnapshotDate date);
INSERT INTO dbo.DimDateModel SELECT * FROM dbo.DimDate;
-- Fixed sample has exactly one snapshot date, 2026-08-28. Validate before this CTAS.
CREATE TABLE dbo.FactInventorySnapshot AS SELECT s.StoreKey,p.ProductKey,20260828 AS DateKey,f.* FROM LakeshoreStaticDataLH.dbo.fact_inventory_positions f JOIN dbo.DimStore s ON f.StoreId=s.StoreId JOIN dbo.DimProduct p ON f.ProductId=p.ProductId;
ALTER TABLE dbo.DimStoreModel ADD CONSTRAINT PK_StoreModel PRIMARY KEY NONCLUSTERED (StoreKey) NOT ENFORCED;
ALTER TABLE dbo.DimProductModel ADD CONSTRAINT PK_ProductModel PRIMARY KEY NONCLUSTERED (ProductKey) NOT ENFORCED;
ALTER TABLE dbo.DimDateModel ADD CONSTRAINT PK_DateModel PRIMARY KEY NONCLUSTERED (DateKey) NOT ENFORCED;
ALTER TABLE dbo.FactInventorySnapshot ADD CONSTRAINT FK_StoreModel FOREIGN KEY (StoreKey) REFERENCES dbo.DimStoreModel(StoreKey) NOT ENFORCED;
ALTER TABLE dbo.FactInventorySnapshot ADD CONSTRAINT FK_ProductModel FOREIGN KEY (ProductKey) REFERENCES dbo.DimProductModel(ProductKey) NOT ENFORCED;
ALTER TABLE dbo.FactInventorySnapshot ADD CONSTRAINT FK_DateModel FOREIGN KEY (DateKey) REFERENCES dbo.DimDateModel(DateKey) NOT ENFORCED;
SELECT name,type_desc FROM sys.objects WHERE type IN ('PK','F');
SELECT COUNT(*) AS Positions,SUM(OnHandQuantity) AS OnHandUnits FROM dbo.FactInventorySnapshot;
SELECT p.StorageClass,COUNT(*) AS Positions,SUM(f.OnHandQuantity) AS Units FROM dbo.FactInventorySnapshot f JOIN dbo.DimProductModel p ON f.ProductKey=p.ProductKey GROUP BY p.StorageClass;
SELECT COUNT(*) AS DuplicateGroups FROM (SELECT StoreKey,ProductKey,DateKey FROM dbo.FactInventorySnapshot GROUP BY StoreKey,ProductKey,DateKey HAVING COUNT(*)>1) d;
SELECT COUNT(*) AS ProductOrphans FROM dbo.FactInventorySnapshot f LEFT JOIN dbo.DimProductModel p ON f.ProductKey=p.ProductKey WHERE p.ProductKey IS NULL;
-- Repeat orphan checks for StoreKey and DateKey against their model dimensions.
-- SCD PRACTICE ONLY: does not change canonical dimensions or reassign historical facts.
CREATE TABLE dbo.DimStoreSCDPractice AS SELECT StoreKey,StoreId,StoreName,PriorityTier,CAST('2026-08-28' AS date) AS ValidFrom,CAST('9999-12-31' AS date) AS ValidTo,1 AS IsCurrent FROM dbo.DimStoreModel;
-- Type 1 correction: overwrite an attribute, no prior-value history.
UPDATE dbo.DimStoreSCDPractice SET StoreName=CONCAT(StoreName,' - corrected') WHERE StoreKey=1;
-- Type 2: expire old version and insert a new surrogate key.
UPDATE dbo.DimStoreSCDPractice SET ValidTo='2026-08-28',IsCurrent=0 WHERE StoreKey=1;
INSERT dbo.DimStoreSCDPractice SELECT 101,StoreId,StoreName,'Tier 2',CAST('2026-08-29' AS date),CAST('9999-12-31' AS date),1 FROM dbo.DimStoreSCDPractice WHERE StoreKey=1;
SELECT StoreKey,StoreId,PriorityTier,ValidFrom,ValidTo,IsCurrent FROM dbo.DimStoreSCDPractice WHERE StoreKey IN (1,101);
-- Inclusive valid-date intervals. Production loads must resolve the fact key as of snapshot time.
-- ROW_NUMBER keys are deterministic only for this fixed source, not an incremental key allocator.
-- Inventory units are additive across store/product for one snapshot, NOT across dates.
SELECT COUNT(*) AS StoreOrphans FROM dbo.FactInventorySnapshot f LEFT JOIN dbo.DimStoreModel s ON f.StoreKey=s.StoreKey WHERE s.StoreKey IS NULL;
SELECT COUNT(*) AS DateOrphans FROM dbo.FactInventorySnapshot f LEFT JOIN dbo.DimDateModel d ON f.DateKey=d.DateKey WHERE d.DateKey IS NULL;
