# EcoMarket Riwi S.A.S. - Relational Database Migration Project

This repository contains the database schema design, normalization documentation, ETL automation, and analytical SQL scripts for migrating the fresh food distribution operational data of EcoMarket Riwi S.A.S. from a legacy Excel spreadsheet into a normalized relational database.

---

## 1. Project Description
EcoMarket Riwi S.A.S. is a company dedicated to the commercialization and distribution of fresh foods for supermarkets, restaurants, and specialized stores. As the company grew, its legacy Excel-based tracking system began causing severe operational issues, including duplicated clients, inconsistent city spelling, redundant data, and inaccurate inventory records.

This project implements a professional, 3rd Normal Form (3NF) relational database model in MySQL to guarantee data consistency, referential integrity, and efficient business reporting.

---

## 2. Technologies
* **Database Engine**: MySQL (v8.x+).
* **ETL Scripting**: Python 3.x (using standard libraries `zipfile`, `xml.etree.ElementTree`, and `csv` to guarantee zero-dependency execution).
* **Data Interchange**: Standard RFC 4180 CSV files.
* **Documentation**: Markdown, Vector SVG for the Entity-Relationship Diagram (ERD).

---

## 3. Database Engine
The primary database engine selected for this project is **MySQL**, due to its widespread industry adoption, excellent indexing performance, robust InnoDB transactional support, and strict referential integrity.

---

## 4. Normalization Process
To remove data redundancies and avoid insertion, update, and deletion anomalies, the flat Excel dataset was normalized:

1. **First Normal Form (1NF)**: Removed repeating groups and ensured all column values are atomic. Primary keys (`` prefixed) were defined for all entities.
2. **Second Normal Form (2NF)**: Removed partial dependencies. Entities like `clients`, `products`, and `distribution_centers` were extracted into separate master tables because their attributes do not depend on the specific transaction (order ID).
3. **Third Normal Form (3NF)**: Removed transitive dependencies. We identified that the logisitics relationship `DistributionCenter` depends on the `City` rather than the order or client. Thus, we linked cities directly to their regional distribution center (`cities.center_id`), removing redundant logging.

---

## 5. Database Schema

All table names and column names are in English and start with the mandatory prefix ``.

### Tables and Columns:
* **`distribution_centers`**: Regional logistics hubs.
* **`cities`**: Urban locations served, linked to their hub.
* **`clients`**: Cleaned, unique client profiles.
* **`categories`**: Product classifications (Fruits, Dairy, Meats, Grains, Oils, Vegetables).
* **`products`**: Core catalog with standard prices.
* **`inventories`**: Stock level per product per logistics hub.
* **`orders`**: Header table representing order placements.
* **`order_details`**: Line items per order capturing historical sale prices and quantities.

---

## 6. Entity Relationship Diagram (ERD)
The physical database diagram showing entities, primary/foreign keys, and cardinalities is saved in the repository as a high-quality SVG image:
* **ERD File**: [modelo_entidad_relacion.svg](modelo_entidad_relacion.svg)

---

## 7. Database Creation Instructions

To create the database, run the DDL schema script in your terminal using the MySQL CLI:

```bash
# 1. Create the database (replace placeholder with your actual developer name)
mysql -u root -p -e "CREATE DATABASE bd_nombre_apellido_clan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. Run the schema creation DDL
mysql -u root -p bd_nombre_apellido_clan < script_ddl.sql
```

---

## 8. Data Loading Instructions

Data loading can be performed using either the automatic SQL transaction script or the exported CSV files located in the `exports/` folder.

### Option A: Using the SQL Transaction Script (Recommended)
This script runs inside a single database transaction, inserting all homologated and cleaned master catalogs and transactional history:

```bash
mysql -u root -p bd_nombre_apellido_clan < script_carga.sql
```

### Option B: Importing via CSV Files
If using an Import Wizard (like MySQL Workbench or DBeaver), import the CSV files in `exports/` in the following strict order to respect foreign key constraints:
1. `distribution_centers.csv`
2. `cities.csv`
3. `clients.csv`
4. `categories.csv`
5. `products.csv`
6. `inventories.csv`
7. `orders.csv`
8. `order_details.csv`

---

## 9. SQL Query Explanation

Six analytical SQL queries have been written in `consultas_sql.sql` to resolve key business questions:

1. **Available Stock by Product**: Sums up product quantities across all centers to help the procurement manager plan purchases.
2. **Order Volume and Revenue by City**: Details which cities generate the highest sales volume for market expansion analysis.
3. **Total Sales by Category**: Informs the CFO which food categories generate the most revenue.
4. **Low Inventory Alerts**: Lists products with less than 50 units remaining in stock to prevent stockouts.
5. **Most Active Clients**: Ranks client purchase frequency for loyalty campaigns.
6. **Financial Inventory Value per Hub**: Multiplies current stock by product unit prices to evaluate the financial asset value stored in each logistics warehouse.

---

## 10. Developer Information
* **Developer Name**: Juan
* **Developer Surname**: Maldonado
* **Clan**: Hopper
* **Course**: Data Analytics & Databases - Riwi
* **GitHub Repository**: [juanjo2409/prebaDesempe-oDB](https://github.com/juanjo2409/prebaDesempe-oDB)
