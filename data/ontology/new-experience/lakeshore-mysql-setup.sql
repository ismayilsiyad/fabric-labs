CREATE DATABASE IF NOT EXISTS lakeshore_retail;

USE lakeshore_retail;

CREATE TABLE dimlocations (
  LocationId VARCHAR(20) PRIMARY KEY,
  LocationType VARCHAR(10) NOT NULL,
  Name VARCHAR(100) NOT NULL,
  Region VARCHAR(20),
  City VARCHAR(60),
  StateProvince VARCHAR(10),
  Country VARCHAR(10),
  PriorityTier VARCHAR(10),
  OperatingStatus VARCHAR(10),
  SellingAreaSqFt INT,
  StorageCapacityPallets INT,
  Latitude DECIMAL(10,6),
  Longitude DECIMAL(10,6)
);

INSERT INTO dimlocations (LocationId, LocationType, Name, Region, City, StateProvince, Country, PriorityTier, OperatingStatus, SellingAreaSqFt, StorageCapacityPallets, Latitude, Longitude) VALUES
('S-SEA-01', 'STORE', 'Seattle Market', 'West', 'Seattle', 'WA', 'US', 'Tier 1', 'OPEN', '42000', NULL, '47.6062', '-122.3321'),
('S-PDX-01', 'STORE', 'Portland Market', 'West', 'Portland', 'OR', 'US', 'Tier 1', 'OPEN', '36000', NULL, '45.5152', '-122.6784'),
('S-SFO-01', 'STORE', 'San Francisco Market', 'West', 'San Francisco', 'CA', 'US', 'Tier 1', 'OPEN', '40000', NULL, '37.7749', '-122.4194'),
('S-DEN-01', 'STORE', 'Denver Market', 'Central', 'Denver', 'CO', 'US', 'Tier 2', 'OPEN', '33000', NULL, '39.7392', '-104.9903'),
('S-BOS-01', 'STORE', 'Boston Market', 'East', 'Boston', 'MA', 'US', 'Tier 1', 'OPEN', '39000', NULL, '42.3601', '-71.0589'),
('S-NYC-01', 'STORE', 'New York Market', 'East', 'New York', 'NY', 'US', 'Tier 2', 'OPEN', '46000', NULL, '40.7128', '-74.006'),
('DC-ONT-01', 'DC', 'Ontario Distribution Center', 'West', 'Ontario', 'CA', 'US', NULL, 'OPEN', NULL, '28000', '34.0633', '-117.6509'),
('DC-CHI-01', 'DC', 'Chicago Distribution Center', 'Central', 'Chicago', 'IL', 'US', NULL, 'OPEN', NULL, '32000', '41.8781', '-87.6298'),
('DC-NJ-01', 'DC', 'New Jersey Distribution Center', 'East', 'Newark', 'NJ', 'US', NULL, 'OPEN', NULL, '30000', '40.7357', '-74.1724');

CREATE TABLE dimproducts (
  ProductId VARCHAR(20) PRIMARY KEY,
  ProductName VARCHAR(100) NOT NULL,
  Brand VARCHAR(100),
  Category VARCHAR(30),
  Subcategory VARCHAR(50),
  StorageClass VARCHAR(20),
  MinimumStorageTempC DECIMAL(6,2),
  MaximumStorageTempC DECIMAL(6,2),
  ShelfLifeDays INT,
  SellByDateRequired BOOLEAN,
  SupplierId VARCHAR(20),
  StandardUnitPrice DECIMAL(10,2),
  StandardUnitCost DECIMAL(10,2)
);

INSERT INTO dimproducts (ProductId, ProductName, Brand, Category, Subcategory, StorageClass, MinimumStorageTempC, MaximumStorageTempC, ShelfLifeDays, SellByDateRequired, SupplierId, StandardUnitPrice, StandardUnitCost) VALUES
('P-FRZ-001', 'Vanilla Bean Ice Cream', 'Lakeshore Select', 'Frozen', 'Ice Cream', 'FROZEN', '-25.0', '-18.0', '180', TRUE, 'SUP-001', '6.99', '3.20'),
('P-FRZ-002', 'Four Cheese Pizza', 'Northstar Kitchen', 'Frozen', 'Pizza', 'FROZEN', '-25.0', '-18.0', '270', TRUE, 'SUP-001', '8.49', '4.10'),
('P-FRZ-003', 'Wild Blueberries', 'Cascade Valley', 'Frozen', 'Fruit', 'FROZEN', '-25.0', '-18.0', '365', TRUE, 'SUP-004', '5.79', '2.70'),
('P-PER-001', 'Organic Whole Milk', 'Cascade Dairy', 'Dairy', 'Milk', 'PERISHABLE', '1.0', '4.0', '14', TRUE, 'SUP-002', '4.29', '2.15'),
('P-PER-002', 'Garden Salad Kit', 'Cascade Fresh', 'Produce', 'Prepared Salad', 'PERISHABLE', '1.0', '5.0', '7', TRUE, 'SUP-002', '5.49', '2.60'),
('P-GEN-001', 'Premium Paper Towels', 'Harbor Home', 'Household', 'Paper Goods', 'AMBIENT', NULL, NULL, NULL, FALSE, 'SUP-003', '12.99', '7.25'),
('P-GEN-002', 'Medium Roast Coffee', 'Harbor Pantry', 'Grocery', 'Coffee', 'AMBIENT', NULL, NULL, '365', FALSE, 'SUP-003', '10.99', '5.40'),
('P-GEN-003', 'Honey Oat Cereal', 'Harbor Pantry', 'Grocery', 'Cereal', 'AMBIENT', NULL, NULL, '240', FALSE, 'SUP-003', '4.99', '2.20');

SELECT 'dimlocations' AS TableName, COUNT(*) AS RowCount FROM dimlocations
UNION ALL SELECT 'dimproducts', COUNT(*) FROM dimproducts;