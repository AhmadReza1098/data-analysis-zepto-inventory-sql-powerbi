# Zepto-E-Commerce-Inventory-Data-Cleaning-and-Business-Insights-with-SQL

## Project Overview
This SQL project analyzes a Zepto-style grocery inventory dataset (from Kaggle) that mimics a real e-commerce catalog with duplicate products, inconsistent values, and missing or incorrect information. The work is done end-to-end in MySQL: from schema creation and raw CSV import, through data cleaning and flagging, to business-driven analysis of inventory value, discount strategies, and stockouts.

## Project workflow

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
