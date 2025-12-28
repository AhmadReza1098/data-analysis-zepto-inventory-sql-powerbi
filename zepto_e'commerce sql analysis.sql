DROP TABLE IF EXISTS zepto_inventory;

use zepto;

-- Create table in database
CREATE TABLE zepto_inventory (
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp DECIMAL(10 , 2 ),
    discountPercent DECIMAL(5 , 2 ),
    availableQuantity INT,
    discountedSellingPrice DECIMAL(10 , 2 ),
    weightInGms INT,
    outOfStock VARCHAR(50),
    quantity INT
);

-- Import dataset

ALTER TABLE zepto_inventory
ADD COLUMN sku_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

-- Quick check
select * from zepto_inventory
limit 10;

-- Check the Null

SELECT *
FROM
    zepto_inventory
WHERE
    name IS NULL OR category IS NULL
        OR mrp IS NULL
        OR discountPercent IS NULL
        OR availableQuantity IS NULL
        OR discountedSellingPrice IS NULL
        OR outOfStock IS NULL
        OR quantity IS NULL;
        
SELECT COUNT(*) AS null_rows
FROM zepto_inventory
WHERE name IS NULL
  AND category IS NULL
  AND mrp IS NULL
  AND discountPercent IS NULL
  AND availableQuantity IS NULL
  AND discountedSellingPrice IS NULL
  AND outOfStock IS NULL
  AND quantity IS NULL;

-- 2. Look at categories
SELECT DISTINCT
    category
FROM
    zepto_inventory
ORDER BY category;

-- Compared in-stock vs out-of-stock product counts
SELECT 
    outOfStock, COUNT(sku_id)
FROM
    zepto_inventory
GROUP BY outOfStock;

-- Detected products present multiple times, representing different SKUs
SELECT 
    name, COUNT(sku_id) AS number_of_SKUs
FROM
    zepto_inventory
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-- Converted mrp and discountedSellingPrice from paise to rupees for consistency and readability
UPDATE zepto_inventory 
SET 
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- DATA Cleaning
--  Negative & suspecius quantities 
SELECT 
    sku_id, name, category, availableQuantity
FROM
    zepto_inventory
WHERE
    availableQuantity IS NULL
        OR availableQuantity <= 0;
        
select * 
from zepto_inventory 
where mrp = 0 or discountedSellingPrice = 0;        
      
SELECT sku_id, name, category, mrp, availableQuantity, weightInGms, quantity
FROM zepto_inventory
WHERE quantity = 0;

-- Adding and set flags for bad data patterns 
-- 1) Flag zero/NULL stock
ALTER TABLE zepto_inventory
ADD COLUMN is_invalid_stock TINYINT(1) DEFAULT 0;

UPDATE zepto_inventory
SET is_invalid_stock = 1
WHERE availableQuantity = 0
   OR weightInGms = 0;
 
-- 2) Flag zero/NULL prices
alter table zepto_inventory 
add column is_invalid_price tinyint(1) default 0;

update zepto_inventory
set is_invalid_price = 1
where mrp is null
or mrp = 0
or discountedSellingPrice is null
or discountedSellingPrice = 0;  

-- 2) Flag negative or zero quantity per pack
alter table zepto_inventory
add column is_invalid_qty tinyint(1) default 0;

update zepto_inventory
set is_invalid_qty = 1
where quantity is null
or quantity <= 0;

-- Create a combined “valid row” flag
alter table zepto_inventory
add column is_invalid_raw tinyint(1) default 0;

alter table zepto_inventory
change column is_invalid_row is_valid_row tinyint(1) default 0;

-- Create a combined “valid row” flag
ALTER TABLE zepto_inventory
ADD COLUMN is_valid_row TINYINT(1) DEFAULT 1;

UPDATE zepto_inventory
SET is_valid_row = CASE
    WHEN is_invalid_stock = 1
      OR is_invalid_price = 1
      OR is_invalid_qty = 1
    THEN 0
    ELSE 1
END;


-- Basic business EDA on clean data 
SELECT 
    is_valid_row,
    COUNT(*) AS sku_count
FROM zepto_inventory
GROUP BY is_valid_row;

-- 2) Category-wise SKU count (valid only)
SELECT 
    category,
    COUNT(*) AS sku_count
FROM zepto_inventory
WHERE is_valid_row = 1
GROUP BY category
ORDER BY sku_count DESC;

-- 3) Price ranges by category (valid only)
SELECT 
    category,
    MIN(mrp) AS min_mrp,
    MAX(mrp) AS max_mrp,
    AVG(mrp) AS avg_mrp
FROM zepto_inventory
WHERE is_valid_row = 1
GROUP BY category
ORDER BY avg_mrp DESC;

-- BSUINESS INSIGHTS
-- 1.Stock availability and out of stock risk
select outOfStock, count(*) as SKUs_count
from zepto_inventory
where is_valid_row = 1
group by outOfStock;

-- 2.Inventory value by category
select category,
sum(discountedSellingPrice * availableQuantity) as total_inventory_value
from zepto_inventory
where is_valid_row = 1
and outOfStock = 'FALSE'
group by category
order by total_inventory_value;

-- 3.Top SKUs by potential revenue
select sku_id, name, category, discountedSellingPrice, availableQuantity,
(discountedSellingPrice * availableQuantity) as potential_revenue
from zepto_inventory
where is_valid_row = 1
and outOfStock = 'FALSE'
order by potential_revenue desc
limit 20;

-- 4.Category-wise discount behavior
select category,
count(*) as sku_count,
avg(discountPercent) as avg_discount_pct,
max(discountPercent) as max_discount_pct,
min(discountPercent) as min_discount_pct
from zepto_inventory
where is_valid_row = 1
group by category
order by avg_discount_pct desc;

-- 5. Top 10 best-value products by discount%
select name, mrp, discountPercent
 from zepto_inventory
where is_valid_row = 1
order by discountPercent desc
limit 10;

-- 6.High-MRP products that are out of stock
select distinct name, mrp
from zepto_inventory
where is_valid_row = 1
and outOfStock = 'TRUE'
and mrp > 300
order by mrp desc;

-- 6.1) How many out-of-stock SKUs in total?
SELECT outOfStock, COUNT(*) AS sku_count
FROM zepto_inventory
GROUP BY outOfStock;

-- 6.2) Out-of-stock rows and their validity flags
SELECT 
    outOfStock,
    is_valid_row,
    COUNT(*) AS sku_count
FROM zepto_inventory
GROUP BY outOfStock, is_valid_row;

SELECT DISTINCT 
    name,
    category,
    mrp
FROM zepto_inventory
WHERE outOfStock = 'TRUE'
  AND mrp > 300
ORDER BY mrp DESC;

-- 7.Expensive products (MRP > 500) with low discount
SELECT DISTINCT name, mrp, discountPercent
FROM zepto_inventory
WHERE is_valid_row = 1
  AND mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- 8.Top 5 categories by average discount
select category,
round(avg(discountPercent),2) as avg_discount
from zepto_inventory
group by category
order by avg_discount desc
limit 5;

-- 9.Price per gram (value for money)
select name , weightInGms, discountedSellingPrice,
round(discountedSellingPrice/weightInGms, 2) as price_per_gms
from zepto_inventory
where is_valid_row = 1
and weightInGms > 100
order by price_per_gms;

-- 10. Weight-based product buckets
select distinct name, weightInGms ,
case 
when weightInGms < 1000 then 'Low'
when weightInGms < 5000 then 'Medium'
else 'Bulk'
end as weight_category
from zepto_inventory
where is_valid_row = 1;

-- 11. Total inventory weight per category
select category,
sum(weightInGms * availableQuantity) as total_weight
from zepto_inventory
where is_valid_row = 1
group by category
order by total_weight desc;

