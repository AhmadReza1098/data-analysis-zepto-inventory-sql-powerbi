# Zepto-E-Commerce-Inventory-Data-Cleaning-and-Business-Insights-with-SQL

## Project Overview
This SQL project analyzes a Zepto-style grocery inventory dataset (from Kaggle) that mimics a real e-commerce catalog with duplicate products, inconsistent values, and missing or incorrect information. The work is done end-to-end in MySQL: from schema creation and raw CSV import, through data cleaning and flagging, to business-driven analysis of inventory value, discount strategies, and stockouts.

1. **Data loading and schema setup**  
   - Created the `zepto_inventory` table in MySQL and added a synthetic `sku_id` primary key.  
   - Imported the raw Zepto inventory CSV and fixed import issues (booleans as text, type mismatches, blank rows).

2. **Exploratory Data Analysis (EDA)**  
   - Inspected sample rows and total SKU counts.  
   - Listed distinct categories and checked in-stock vs out-of-stock distribution.  
   - Reviewed basic price and discount statistics to spot anomalies.

3. **Data cleaning and quality flags**  
   - Identified SKUs with zero/NULL prices, zero/negative quantities, and zero stock or weight.  
   - Created `is_invalid_stock`, `is_invalid_price`, and `is_invalid_qty` flags.  
   - Built a combined `is_valid_row` flag and standardized prices from paise to rupees.

4. **Business-focused analysis**  
   - Calculated inventory value by category and ranked top revenue-driving SKUs.  
   - Analyzed discount patterns by category and highlighted heavily discounted and premium products.  
   - Computed price-per-gram, weight buckets, and stockout patterns for high-MRP items.
  
## 🔧 Step-by-Step Project Workflow

### 1. Database & Table Creation

We start by creating a SQL table with appropriate data types:

```sql
CREATE TABLE zepto_inventory (
  sku_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  category VARCHAR(120),
  name VARCHAR(150) NOT NULL,
  mrp DECIMAL(10,2),
  discountPercent DECIMAL(5,2),
  availableQuantity INT,
  discountedSellingPrice DECIMAL(10,2),
  weightInGms INT,
  outOfStock VARCHAR(50),
  quantity INT
);

### 2. Quick Checks
```sql
-- Sample rows
SELECT *
FROM zepto_inventory
LIMIT 10;

-- Total rows
SELECT COUNT(*) AS total_rows
FROM zepto_inventory;

-- Distinct categories
SELECT DISTINCT category
FROM zepto_inventory
ORDER BY category;

-- In-stock vs out-of-stock counts
SELECT outOfStock, COUNT(sku_id) AS sku_count
FROM zepto_inventory
GROUP BY outOfStock;

-- Products appearing as multiple SKUs
SELECT
    name,
    COUNT(sku_id) AS number_of_SKUs
FROM zepto_inventory
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY number_of_SKUs DESC;

-- Convert prices from paise to rupees
UPDATE zepto_inventory
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- Flag invalid stock
ALTER TABLE zepto_inventory
ADD COLUMN is_invalid_stock TINYINT(1) DEFAULT 0;

UPDATE zepto_inventory
SET is_invalid_stock = 1
WHERE availableQuantity = 0
   OR weightInGms = 0;

-- Flag invalid price
ALTER TABLE zepto_inventory
ADD COLUMN is_invalid_price TINYINT(1) DEFAULT 0;

UPDATE zepto_inventory
SET is_invalid_price = 1
WHERE mrp IS NULL
   OR mrp = 0
   OR discountedSellingPrice IS NULL
   OR discountedSellingPrice = 0;

-- Flag invalid quantity
ALTER TABLE zepto_inventory
ADD COLUMN is_invalid_qty TINYINT(1) DEFAULT 0;

UPDATE zepto_inventory
SET is_invalid_qty = 1
WHERE quantity IS NULL
   OR quantity <= 0;

-- Combined valid-row flag
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

-- Valid vs invalid SKUs
SELECT
    is_valid_row,
    COUNT(*) AS sku_count
FROM zepto_inventory
GROUP BY is_valid_row;

-- Category-wise SKU count (valid only)
SELECT
    category,
    COUNT(*) AS sku_count
FROM zepto_inventory
WHERE is_valid_row = 1
GROUP BY category
ORDER BY sku_count DESC;

-- Price ranges by category (valid only)
SELECT
    category,
    MIN(mrp) AS min_mrp,
    MAX(mrp) AS max_mrp,
    AVG(mrp) AS avg_mrp
FROM zepto_inventory
WHERE is_valid_row = 1
GROUP BY category
ORDER BY avg_mrp DESC;

-- Stock availability on clean data
SELECT outOfStock, COUNT(*) AS SKUs_count
FROM zepto_inventory
WHERE is_valid_row = 1
GROUP BY outOfStock;

-- Inventory value by category (clean + in stock)
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_inventory_value
FROM zepto_inventory
WHERE is_valid_row = 1
  AND outOfStock = 'FALSE'
GROUP BY category
ORDER BY total_inventory_value DESC;

-- Top SKUs by potential revenue (clean + in stock)
SELECT
    sku_id,
    name,
    category,
    discountedSellingPrice,
    availableQuantity,
    (discountedSellingPrice * availableQuantity) AS potential_revenue
FROM zepto_inventory
WHERE is_valid_row = 1
  AND outOfStock = 'FALSE'
ORDER BY potential_revenue DESC
LIMIT 20;

-- Top 10 best-value products by discount%
SELECT
    name,
    mrp,
    discountPercent
FROM zepto_inventory
WHERE is_valid_row = 1
ORDER BY discountPercent DESC
LIMIT 10;

