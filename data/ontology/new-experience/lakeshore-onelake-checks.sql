SELECT 'dimlocations' AS TableName, COUNT(*) AS [RowCount] FROM dbo.dimlocations
UNION ALL SELECT 'dimproducts', COUNT(*) FROM dbo.dimproducts
UNION ALL SELECT 'dimsuppliers', COUNT(*) FROM dbo.dimsuppliers
UNION ALL SELECT 'dim_refrigeration_units', COUNT(*) FROM dbo.dim_refrigeration_units
UNION ALL SELECT 'fact_inventory_positions', COUNT(*) FROM dbo.fact_inventory_positions
UNION ALL SELECT 'factshipments', COUNT(*) FROM dbo.factshipments;
SELECT COUNT(*) AS InventoryRows, COUNT(DISTINCT StoreId) AS Stores,
SUM(OnHandQuantity) AS OnHandUnits, SUM(InboundQuantity) AS InboundUnits,
SUM(CASE WHEN OnHandQuantity < ReorderPointQuantity THEN 1 ELSE 0 END) AS BelowReorderRows
FROM dbo.fact_inventory_positions;
SELECT StorageClass, COUNT(*) AS ProductCount FROM dbo.dimproducts
GROUP BY StorageClass ORDER BY StorageClass;
SELECT StoreId, ProductId, SnapshotDateTime, COUNT(*) AS DuplicateCount
FROM dbo.fact_inventory_positions GROUP BY StoreId, ProductId, SnapshotDateTime
HAVING COUNT(*) > 1;
