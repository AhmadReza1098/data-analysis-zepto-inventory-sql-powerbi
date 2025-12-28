# 🛒 data-analysis-zepto-inventory-sql

Analyzing Zepto-style inventory data using **SQL** to uncover pricing, discount, and stock insights for real-world e‑commerce decision-making.

---

## 📌 Table of Contents

- [Overview](#overview)  
- [Business Problem](#business-problem)  
- [Dataset](#dataset)  
- [Tools & Technologies](#tools--technologies)  
- [Project Structure](#project-structure)  
- [Data Cleaning & Preparation](#data-cleaning--preparation)  
- [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)  
- [Research Questions & Key Findings](#research-questions--key-findings)  
- [How to Run This Project](#how-to-run-this-project)  
- [Future Enhancements](#future-enhancements)  
- [Author & Contact](#author--contact)  

---

## Overview

This project performs end-to-end **SQL analysis on Zepto inventory data**, focusing on product pricing, discounts, stock availability, and potential revenue. The goal is to simulate how a data analyst works with a real e‑commerce inventory table to generate business-ready insights.

---

## Business Problem

Retail inventory teams need to understand:

- Which products and categories drive **maximum value**.  
- Where **discounts** and **stock levels** are not aligned (e.g., high price but out of stock).  
- How much **revenue is locked** in current inventory.  

This project aims to:

- Identify best-value products based on **discountPercent**.  
- Detect **high-MRP products** that are out of stock.
- Estimate **potential revenue** using price and availableQuantity.
- Analyze **price-per-gram** and weight-based segmentation to find value products.

---

## Dataset

- Source: Zepto inventory–style CSV (one row per SKU). 
- Table used: `zepto_inventory` (created in MySQL).  

Key columns (example):

- `sku_id` – Synthetic primary key for each SKU. 
- `name` – Product name from the app.
- `category` – Category such as Fruits, Snacks, Beverages, etc.
- `mrp` – Maximum Retail Price (stored in rupees after conversion).
- `discountPercent` – Discount applied on MRP. 
- `availableQuantity` – Current stock units in inventory.
- `discountedSellingPrice` – Effective selling price after discount. 
- `weightInGms` – Product weight in grams.
- `outOfStock` – Flag indicating whether the SKU is out of stock.  
- `quantity` – Units per pack (for multi-pack products).

---

## Tools & Technologies

- **SQL / MySQL** – Database, data cleaning, and analysis queries. 
- **GitHub** – Version control and project documentation.
- (Optional) **Power BI / Excel** – For building dashboards from SQL outputs.

---

## Project Structure

Suggested folder layout for this project:

```
data-analysis-zepto-inventory-sql/
│
├── README.md                    
├── zepto_inventory.sql           
│
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_eda_queries.sql
│   └── 04_business_insights.sql
│
└── exports/
    └── query_results.csv        
```

This structure follows common patterns used in Zepto inventory SQL portfolio projects.

## Data Cleaning & Preparation

Main cleaning and preparation steps performed in SQL:

- Converted `mrp` and `discountedSellingPrice` from **paise to rupees** by dividing by 100. 
- Flagged rows with **invalid stock** (availableQuantity = 0 or weightInGms = 0). 
- Flagged **invalid prices** (mrp or discountedSellingPrice = 0 or NULL).  
- Flagged **invalid quantity** (quantity <= 0 or NULL).  
- Created an `is_valid_row` indicator to keep only clean records for analysis.

These steps ensure all later EDA and insights use reliable inventory data.

---

## Exploratory Data Analysis (EDA)

Using only valid rows (`is_valid_row = 1`), the EDA explores:

- **Row counts**: total SKUs vs valid SKUs.  
- **Category coverage**: number of SKUs per category.  
- **Price ranges**: min, max, and average MRP by category.  
- **Stock status**: in‑stock vs out‑of‑stock distribution.  

The SQL queries analyze distinct categories, duplicate product names with multiple SKUs, and overall stock volume per category.

---

## Research Questions & Key Findings

Typical business questions answered:

- Which products have the **highest discountPercent** (top 10 best-value items)?
- Which high‑MRP products are **currently out of stock** (missed sales opportunities)?  
- What is the **estimated inventory value** by category (discountedSellingPrice × availableQuantity)? 
- Which categories provide the **highest average discounts** to customers?  
- How does **price per gram** vary across SKUs to identify best value? 

These insights help identify value products, risky stockouts, and pricing strategies.

---

## How to Run This Project

1. **Set up database**

   - Create a new MySQL database (for example: `zepto`).   
   - Run the table creation script from `zepto_inventory.sql` to create `zepto_inventory`. 

2. **Load data**

   - Import the Zepto CSV into `zepto_inventory` using MySQL Workbench / CLI import.  

3. **Run cleaning queries**

   - Execute the **Data Cleaning** section in `zepto_inventory.sql` to set flags and convert prices.  

4. **Run EDA & insight queries**

   - Run EDA queries to check counts, categories, and distributions.   
   - Run business insight queries to get discount, revenue, and price-per-gram analysis.

5. **(Optional) Build dashboard**

   - Connect Power BI / Excel to the MySQL database.   
   - Use cleaned tables or SQL views as data sources to create visuals like category revenue, stock status, and discount analysis. 

---

## Future Enhancements

- Add **SQL views** (e.g., `vw_clean_inventory`, `vw_category_summary`) for easier reporting.  
- Build a **Power BI dashboard** to visualize inventory value, discount patterns, and stockouts.   
- Extend analysis to **time-based trends** if timestamp data is added.

---

## Author & Contact

**Your Name**  
Aspiring Data Analyst – SQL & BI  

- 📧 Email: ahmadreza6122@gmail.com  
- 🔗 LinkedIn: www.linkedin.com/in/ahmad-reza-econ  
- 🔗 https://github.com/AhmadReza1098  

Feel free to use or adapt this project as part of your analytics portfolio.




