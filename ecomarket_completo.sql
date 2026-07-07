-- ============================================================================
-- ECO MARKET RIWI S.A.S. - PROYECTO COMPLETO DE BASE DE DATOS
-- Desarrollador: Juan Maldonado
-- Clan: Hopper
-- ============================================================================

-- ============================================================================
-- 0. CREACIÓN Y SELECCIÓN DE LA BASE DE DATOS
-- ============================================================================
CREATE DATABASE IF NOT EXISTS bd_juan_maldonado_hopper CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bd_juan_maldonado_hopper;


-- ============================================================================
-- 1. ESTRUCTURA DDL (Tablas, Relaciones y Restricciones)
-- Archivo Original: script_ddl.sql
-- ============================================================================

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

-- 1.1. Distribution Centers Table
CREATE TABLE distribution_centers (
    center_id INT AUTO_INCREMENT PRIMARY KEY,
    center_name VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB;

-- 1.2. Cities Table
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL,
    center_id INT NOT NULL,
    CONSTRAINT fk_cities_center FOREIGN KEY (center_id) 
        REFERENCES distribution_centers(center_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.3. Clients Table
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    city_id INT NOT NULL,
    CONSTRAINT fk_clients_city FOREIGN KEY (city_id) 
        REFERENCES cities(city_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uq_client_city UNIQUE (client_name, city_id)
) ENGINE=InnoDB;

-- 1.4. Categories Table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
) ENGINE=InnoDB;

-- 1.5. Products Table
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

-- 1.6. Inventories Table (Composite Primary Key)
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

-- 1.7. Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    client_id INT NOT NULL,
    order_date DATE NOT NULL,
    CONSTRAINT fk_orders_client FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) 
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 1.8. Order Details Table
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
-- EXTRA POINTS: SQL Views & Stored Procedure Definitions
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

-- Stored Procedure: Get clients filter
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


-- ============================================================================
-- 2. CARGA DE DATOS (Transacción Masiva de Catálogos e Histórico)
-- Archivo Original: script_carga.sql
-- ============================================================================

START TRANSACTION;

-- 2.1. Insert Distribution Centers
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (1, 'Center North');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (2, 'Center West');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (3, 'Coast DC');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (4, 'Coffee DC');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (5, 'East Hub');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (6, 'South Hub');

-- 2.2. Insert Cities
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (1, 'Barranquilla', 3);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (2, 'Bogotá', 1);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (3, 'Bucaramanga', 5);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (4, 'Cali', 6);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (5, 'Cartagena', 3);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (6, 'Cúcuta', 5);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (7, 'Manizales', 4);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (8, 'Medellín', 2);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (9, 'Pereira', 4);

-- 2.3. Insert Clients
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (1, 'EcoStore', 5);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (2, 'FoodPlus', 7);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (3, 'FreshMart', 8);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (4, 'GreenBuy', 2);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (5, 'MarketOne', 3);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (6, 'MiniShop', 4);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (7, 'QuickFood', 6);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (8, 'RetailCo', 9);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (9, 'SuperMax', 1);

-- 2.4. Insert Categories
INSERT IGNORE INTO categories (category_id, category_name) VALUES (1, 'Dairy');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (2, 'Fruits');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (3, 'Grains');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (4, 'Meats');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (5, 'Oils');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (6, 'Vegetables');

-- 2.5. Insert Products
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (1, 'Bananas', 2, 1.2);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (2, 'Chicken Breast', 4, 6.5);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (3, 'Eggs x12', 1, 4.2);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (4, 'Gala Apple', 2, 2.5);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (5, 'Lettuce', 6, 1.1);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (6, 'Olive Oil', 5, 8.9);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (7, 'Pasta', 3, 2.3);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (8, 'Rice 1kg', 3, 2.0);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (9, 'Tomatoes', 6, 1.8);
INSERT IGNORE INTO products (product_id, product_name, category_id, unit_price) VALUES (10, 'Whole Milk', 1, 3.8);

-- 2.6. Insert Inventories
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (1, 4, 110);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (2, 1, 200);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (6, 10, 72);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (3, 2, 95);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (3, 8, 230);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (5, 6, 46);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (4, 3, 104);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (4, 9, 142);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (1, 5, 61);
INSERT IGNORE INTO inventories (center_id, product_id, stock) VALUES (5, 7, 159);

-- 2.7. Insert Orders
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1001', 9, '2026-05-01');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1002', 9, '2026-05-02');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1003', 3, '2026-05-02');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1004', 3, '2026-05-03');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1005', 6, '2026-05-04');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1006', 6, '2026-05-05');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1007', 9, '2026-05-06');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1008', 9, '2026-05-07');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1009', 1, '2026-05-08');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1010', 1, '2026-05-09');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1011', 5, '2026-05-10');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1012', 5, '2026-05-11');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1013', 8, '2026-05-12');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1014', 8, '2026-05-13');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1015', 2, '2026-05-14');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1016', 2, '2026-05-15');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1017', 4, '2026-05-16');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1018', 4, '2026-05-17');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1019', 7, '2026-05-18');
INSERT IGNORE INTO orders (order_id, client_id, order_date) VALUES ('O1020', 7, '2026-05-19');

-- 2.8. Insert Order Details
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (1, 'O1001', 4, 10, 2.5);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (2, 'O1002', 4, 5, 2.5);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (3, 'O1003', 1, 20, 1.2);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (4, 'O1004', 1, 15, 1.2);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (5, 'O1005', 10, 12, 3.8);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (6, 'O1006', 10, 8, 3.8);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (7, 'O1007', 2, 25, 6.5);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (8, 'O1008', 2, 10, 6.5);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (9, 'O1009', 8, 30, 2.0);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (10, 'O1010', 8, 18, 2.0);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (11, 'O1011', 6, 6, 8.9);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (12, 'O1012', 6, 4, 8.9);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (13, 'O1013', 3, 14, 4.2);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (14, 'O1014', 3, 9, 4.2);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (15, 'O1015', 9, 22, 1.8);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (16, 'O1016', 9, 16, 1.8);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (17, 'O1017', 5, 11, 1.1);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (18, 'O1018', 5, 7, 1.1);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (19, 'O1019', 7, 19, 2.3);
INSERT IGNORE INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (20, 'O1020', 7, 13, 2.3);

COMMIT;


-- ============================================================================
-- 3. PRUEBAS DML (Inserción, Modificación y Eliminación de Pruebas)
-- Archivo Original: script_dml.sql
-- ============================================================================

-- 3.1. Prueba de Inserción
START TRANSACTION;
INSERT INTO clients (client_name, city_id) VALUES ('Sabor Local', 1);
INSERT INTO orders (order_id, client_id, order_date) 
VALUES (
    'O2001', 
    (SELECT client_id FROM (SELECT client_id FROM clients WHERE client_name = 'Sabor Local' LIMIT 1) AS tmp), 
    '2026-06-01'
);
INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES ('O2001', 1, 15, 2.50);
UPDATE inventories SET stock = stock - 15 WHERE center_id = 1 AND product_id = 1;
COMMIT;

SELECT '=== 1. PRUEBA DE INSERCIÓN: REGISTRAR NUEVO CLIENTE (Sabor Local) ===' AS 'EVIDENCIA';
SELECT * FROM clients WHERE client_name = 'Sabor Local';
SELECT * FROM orders WHERE order_id = 'O2001';
SELECT * FROM order_details WHERE order_id = 'O2001';

-- 3.2. Prueba de Actualización
START TRANSACTION;
UPDATE distribution_centers SET center_name = 'Caribbean Logistics Hub' WHERE center_name = 'Coast DC';
COMMIT;

SELECT '=== 2. PRUEBA DE ACTUALIZACIÓN: MODIFICAR CENTRO DE DISTRIBUCIÓN (Coast DC -> Caribbean Logistics Hub) ===' AS 'EVIDENCIA';
SELECT * FROM distribution_centers;

-- 3.3. Prueba de Eliminación Permitida (Sin restricciones)
START TRANSACTION;
INSERT INTO products (product_name, category_id, unit_price) VALUES ('Temporary Test Mango', 1, 1.50);
SELECT '=== 3. PRUEBA DE INSERCIÓN PARA BORRADO: CREAR PRODUCTO TEMPORAL ===' AS 'EVIDENCIA';
SELECT * FROM products WHERE product_name = 'Temporary Test Mango';
DELETE FROM products WHERE product_name = 'Temporary Test Mango';
COMMIT;


-- ============================================================================
-- 4. CONSULTAS DE NEGOCIO (Reportes y Resultados Analíticos)
-- Archivo Original: consultas_sql.sql
-- ============================================================================

-- Consulta 4.1: Inventario disponible por producto
SELECT '=== CONSULTA 1: INVENTARIO DISPONIBLE POR PRODUCTO ===' AS 'REPORTE';
SELECT 
    p.product_name AS "Product Name", 
    SUM(i.stock) AS "Available Stock"
FROM 
    products p
JOIN 
    inventories i ON p.product_id = i.product_id
GROUP BY 
    p.product_name
ORDER BY 
    SUM(i.stock) DESC;

-- Consulta 4.2: Historial de pedidos por ciudad
SELECT '=== CONSULTA 2: HISTORIAL DE PEDIDOS POR CIUDAD ===' AS 'REPORTE';
SELECT 
    c.city_name AS "City", 
    COUNT(DISTINCT o.order_id) AS "Total Orders", 
    SUM(d.quantity * d.unit_price) AS "Total Sales Amount"
FROM 
    orders o
JOIN 
    clients cl ON o.client_id = cl.client_id
JOIN 
    cities c ON cl.city_id = c.city_id
JOIN 
    order_details d ON o.order_id = d.order_id
GROUP BY 
    c.city_name
ORDER BY 
    COUNT(DISTINCT o.order_id) DESC, SUM(d.quantity * d.unit_price) DESC;

-- Consulta 4.3: Total vendido por categoría
SELECT '=== CONSULTA 3: TOTAL VENDIDO POR CATEGORÍA ===' AS 'REPORTE';
SELECT 
    cat.category_name AS "Category Name", 
    SUM(d.quantity * d.unit_price) AS "Total Revenue"
FROM 
    order_details d
JOIN 
    products p ON d.product_id = p.product_id
JOIN 
    categories cat ON p.category_id = cat.category_id
GROUP BY 
    cat.category_name
ORDER BY 
    SUM(d.quantity * d.unit_price) DESC;

-- Consulta 4.4: Productos con menor inventario (< 50 unidades)
SELECT '=== CONSULTA 4: PRODUCTOS CON MENOR INVENTARIO (< 50 UNIDADES) ===' AS 'REPORTE';
SELECT 
    p.product_name AS "Product Name", 
    SUM(i.stock) AS "Total Stock Level"
FROM 
    products p
JOIN 
    inventories i ON p.product_id = i.product_id
GROUP BY 
    p.product_name
HAVING 
    SUM(i.stock) < 50
ORDER BY 
    SUM(i.stock) ASC;

-- Consulta 4.5: Clientes con mayor número de pedidos
SELECT '=== CONSULTA 5: CLIENTES CON MAYOR NÚMERO DE PEDIDOS ===' AS 'REPORTE';
SELECT 
    cl.client_name AS "Client Name", 
    COUNT(o.order_id) AS "Total Orders Placed"
FROM 
    orders o
JOIN 
    clients cl ON o.client_id = cl.client_id
GROUP BY 
    cl.client_name
ORDER BY 
    COUNT(o.order_id) DESC;

-- Consulta 4.6: Valor económico del inventario por centro de distribución
SELECT '=== CONSULTA 6: VALOR ECONÓMICO DEL INVENTARIO POR CENTRO ===' AS 'REPORTE';
SELECT 
    dc.center_name AS "Distribution Center", 
    SUM(i.stock * p.unit_price) AS "Inventory Financial Value"
FROM 
    inventories i
JOIN 
    distribution_centers dc ON i.center_id = dc.center_id
JOIN 
    products p ON i.product_id = p.product_id
GROUP BY 
    dc.center_name
ORDER BY 
    SUM(i.stock * p.unit_price) DESC;

-- ============================================================================
-- EXTRA: Ejecución y validación de Vistas y Procedimientos Almacenados
-- ============================================================================

-- Vista de ventas por ciudad
SELECT '=== EXTRA: VISTA DE VENTAS POR CIUDAD ===' AS 'REPORTE';
SELECT * FROM view_sales_summary_by_city;

-- Vista de valoración de stock
SELECT '=== EXTRA: VISTA DE VALORACIÓN DE STOCK ===' AS 'REPORTE';
SELECT * FROM view_product_stock_valuation LIMIT 5;

-- Procedimiento almacenado: Obtener todos los clientes (enviando NULL)
SELECT '=== EXTRA: PROCEDIMIENTO ALMACENADO CON PARÁMETRO NULL (TODOS LOS CLIENTES) ===' AS 'REPORTE';
CALL sp_get_clients(NULL);

-- Procedimiento almacenado: Obtener cliente específico (ID = 3)
SELECT '=== EXTRA: PROCEDIMIENTO ALMACENADO CON ID = 3 (UN CLIENTE) ===' AS 'REPORTE';
CALL sp_get_clients(3);
