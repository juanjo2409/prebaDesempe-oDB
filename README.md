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

## 7. Database Creation & Execution Instructions

To set up the database and run everything (DDL, Data Loading, DML Tests, and Business Queries), execute the single consolidated script using the MySQL CLI:

```bash
# Execute the complete project SQL file
mysql -u root -p < ecomarket_completo.sql
```

Alternatively, open **`ecomarket_completo.sql`** in **MySQL Workbench** and click the lightning bolt icon to execute the entire script.

---

## 8. Database Structure and Normalization
This database implements a professional, 3rd Normal Form (3NF) relational database model in MySQL.
The consolidated script `ecomarket_completo.sql` is structured into 5 sequential sections:
1. **0. CREACIÓN Y SELECCIÓN DE LA BASE DE DATOS**: Automatically creates the database `bd_juan_maldonado_hopper` and selects it.
2. **1. ESTRUCTURA DDL**: Creates all 8 tables, relationships, constraints, views, and the stored procedure.
3. **2. CARGA DE DATOS**: Loads the cleaned master catalogs and transaction history inside a single transaction.
4. **3. PRUEBAS DML**: Verifies insertion, update, and deletion constraints.
5. **4. CONSULTAS DE NEGOCIO**: Runs the 6 analytical queries and tests the views and stored procedure.

---

## 9. SQL Query Explanation

The 6 analytical SQL queries included in Section 4 of `ecomarket_completo.sql` solve key business questions:

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
