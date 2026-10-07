USE lakeshore_retail;
-- 1. WHERE: frozen products (3 rows)
SELECT ProductId, ProductName, StandardUnitPrice FROM dimproducts WHERE StorageClass = 'FROZEN';
-- 2. ORDER BY: stores by name (6 rows)
SELECT LocationId, Name, Region FROM dimlocations WHERE LocationType = 'STORE' ORDER BY Name;
-- 3. LIKE: products containing Cheese (1 row)
SELECT ProductId, ProductName FROM dimproducts WHERE ProductName LIKE '%Cheese%';
-- 4. IN: frozen or perishable products (5 rows)
SELECT ProductId, ProductName, StorageClass FROM dimproducts WHERE StorageClass IN ('FROZEN', 'PERISHABLE');
-- 5. BETWEEN: prices from 4 to 8 inclusive (5 rows)
SELECT ProductId, ProductName, StandardUnitPrice FROM dimproducts WHERE StandardUnitPrice BETWEEN 4 AND 8 ORDER BY StandardUnitPrice;
-- 6. DISTINCT: storage classes (3 rows)
SELECT DISTINCT StorageClass FROM dimproducts ORDER BY StorageClass;
-- 7. IS NOT NULL: products with assigned suppliers (8 rows)
SELECT ProductId, SupplierId FROM dimproducts WHERE SupplierId IS NOT NULL;
-- 8. COUNT: operational stores (6)
SELECT COUNT(*) AS StoreCount FROM dimlocations WHERE LocationType = 'STORE';
-- 9. Structure check
DESCRIBE dimlocations;
DESCRIBE dimproducts;
