-- EcoMarket Riwi S.A.S. - Database Schema DDL (MySQL)
-- Database: bd_nombre_apellido_clan (Template)

-- Disable foreign key checks to allow dropping tables in any order
SET FOREIGN_KEY_CHECKS = 0;

-- Drop views if exist
DROP VIEW IF EXISTS view_sales_summary_by_city;
DROP VIEW IF EXISTS view_product_stock_valuation;

-- Drop tables if exist
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS inventories;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS distribution_centers;

-- Drop procedure if exists
DROP PROCEDURE IF EXISTS sp_get_clients;

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Distribution Centers Table
CREATE TABLE distribution_centers (
    center_id INT AUTO_INCREMENT PRIMARY KEY,
    center_name VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB;

-- 2. Cities Table
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL,
    center_id INT NOT NULL,
    CONSTRAINT fk_cities_center FOREIGN KEY (center_id) 
        REFERENCES distribution_centers(center_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. Clients Table
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    city_id INT NOT NULL,
    CONSTRAINT fk_clients_city FOREIGN KEY (city_id) 
        REFERENCES cities(city_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_client_city UNIQUE (client_name, city_id)
) ENGINE=InnoDB;

-- 4. Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB;

-- 5. Products Table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) UNIQUE NOT NULL,
    category_id INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_products_category FOREIGN KEY (category_id) 
        REFERENCES categories(category_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0)
) ENGINE=InnoDB;

-- 6. Inventories Table (Composite Primary Key)
CREATE TABLE inventories (
    center_id INT NOT NULL,
    product_id INT NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    PRIMARY KEY (center_id, product_id),
    CONSTRAINT fk_inventories_center FOREIGN KEY (center_id) 
        REFERENCES distribution_centers(center_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_inventories_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_stock CHECK (stock >= 0)
) ENGINE=InnoDB;

-- 7. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    client_id INT NOT NULL,
    order_date DATE NOT NULL,
    CONSTRAINT fk_orders_client FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 8. Order Details Table
CREATE TABLE order_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_details_order FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_details_product FOREIGN KEY (product_id) 
        REFERENCES products(product_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_quantity CHECK (quantity > 0),
    CONSTRAINT chk_detail_unit_price CHECK (unit_price >= 0)
) ENGINE=InnoDB;


-- ============================================================================
-- EXTRA POINTS (+20 pts): SQL Views
-- ============================================================================

-- View 1: Commercial sales summary by city
CREATE OR REPLACE VIEW view_sales_summary_by_city AS
SELECT 
    c.city_name AS city, 
    COUNT(DISTINCT o.order_id) AS total_orders, 
    SUM(d.quantity * d.unit_price) AS total_sales
FROM 
    orders o
JOIN 
    clients cl ON o.client_id = cl.client_id
JOIN 
    cities c ON cl.city_id = c.city_id
JOIN 
    order_details d ON o.order_id = d.order_id
GROUP BY 
    c.city_name;

-- View 2: Product stock valuation
CREATE OR REPLACE VIEW view_product_stock_valuation AS
SELECT 
    p.product_name AS product,
    SUM(i.stock) AS total_stock,
    p.unit_price AS unit_price,
    SUM(i.stock * p.unit_price) AS total_value
FROM 
    products p
JOIN 
    inventories i ON p.product_id = i.product_id
GROUP BY 
    p.product_id, p.product_name, p.unit_price;


-- ============================================================================
-- EXTRA POINTS (+20 pts): Stored Procedure
-- ============================================================================
DROP PROCEDURE IF EXISTS sp_get_clients;

DELIMITER //

CREATE PROCEDURE sp_get_clients(IN p_client_id INT)
BEGIN
    IF p_client_id IS NULL THEN
        SELECT 
            c.client_id, 
            c.client_name, 
            ci.city_name 
        FROM 
            clients c
        JOIN 
            cities ci ON c.city_id = ci.city_id;
    ELSE
        SELECT 
            c.client_id, 
            c.client_name, 
            ci.city_name 
        FROM 
            clients c
        JOIN 
            cities ci ON c.city_id = ci.city_id
        WHERE 
            c.client_id = p_client_id;
    END IF;
END //

DELIMITER ;
