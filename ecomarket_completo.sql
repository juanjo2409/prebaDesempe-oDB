-- ============================================================================
-- ECO MARKET RIWI S.A.S. - PROYECTO COMPLETO DE BASE DE DATOS
-- Desarrollador: Juan Maldonado
-- Clan: Hopper
-- ============================================================================

-- ============================================================================
-- 0. CREACIÓN DE LA BASE DE DATOS
-- ============================================================================
DROP DATABASE IF EXISTS bd_juan_maldonado_hopper;
CREATE DATABASE bd_juan_maldonado_hopper;
USE bd_juan_maldonado_hopper;


-- ============================================================================
-- 1. CREACIÓN DE TABLAS (DDL)
-- ============================================================================

-- 1. Centros de Distribución
CREATE TABLE distribution_centers (
    center_id INT AUTO_INCREMENT PRIMARY KEY,
    center_name VARCHAR(100) UNIQUE NOT NULL
);

-- 2. Ciudades
CREATE TABLE cities (
    city_id INT AUTO_INCREMENT PRIMARY KEY,
    city_name VARCHAR(100) UNIQUE NOT NULL,
    center_id INT,
    FOREIGN KEY (center_id) REFERENCES distribution_centers(center_id)
);

-- 3. Clientes
CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(150) NOT NULL,
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

-- 4. Categorías de Productos
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE NOT NULL
);

-- 5. Productos
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) UNIQUE NOT NULL,
    category_id INT,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 6. Inventarios (Stock por Bodega)
CREATE TABLE inventories (
    center_id INT,
    product_id INT,
    stock INT DEFAULT 0,
    PRIMARY KEY (center_id, product_id),
    FOREIGN KEY (center_id) REFERENCES distribution_centers(center_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 7. Pedidos (Cabecera)
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    client_id INT,
    order_date DATE,
    FOREIGN KEY (client_id) REFERENCES clients(client_id)
);

-- 8. Detalles del Pedido
CREATE TABLE order_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);


-- ============================================================================
-- VISTAS SQL (Puntos Extra)
-- ============================================================================

-- Vista 1: Resumen de ventas por ciudad
CREATE VIEW view_sales_summary_by_city AS
SELECT 
    c.city_name AS ciudad, 
    COUNT(DISTINCT o.order_id) AS total_pedidos, 
    SUM(d.quantity * d.unit_price) AS total_ventas
FROM 
    orders o
JOIN clients cl ON o.client_id = cl.client_id
JOIN cities c ON cl.city_id = c.city_id
JOIN order_details d ON o.order_id = d.order_id
GROUP BY 
    c.city_name;

-- Vista 2: Valoración del inventario actual
CREATE VIEW view_product_stock_valuation AS
SELECT 
    p.product_name AS producto,
    SUM(i.stock) AS stock_total,
    p.unit_price AS precio_unitario,
    SUM(i.stock * p.unit_price) AS valor_total
FROM 
    products p
JOIN inventories i ON p.product_id = i.product_id
GROUP BY 
    p.product_id, p.product_name, p.unit_price;


-- ============================================================================
-- PROCEDIMIENTO ALMACENADO (Puntos Extra)
-- ============================================================================
DELIMITER //

CREATE PROCEDURE sp_get_clients(IN p_client_id INT)
BEGIN
    IF p_client_id IS NULL THEN
        -- Si es NULL, muestra todos los clientes
        SELECT 
            c.client_id, 
            c.client_name, 
            ci.city_name 
        FROM clients c
        JOIN cities ci ON c.city_id = ci.city_id;
    ELSE
        -- Si se pasa un ID, filtra por ese cliente
        SELECT 
            c.client_id, 
            c.client_name, 
            ci.city_name 
        FROM clients c
        JOIN cities ci ON c.city_id = ci.city_id
        WHERE c.client_id = p_client_id;
    END IF;
END //

DELIMITER ;


-- ============================================================================
-- 2. CARGA DE DATOS (INSERT)
-- ============================================================================

-- 2.1. Centros de Distribución
INSERT INTO distribution_centers (center_id, center_name) VALUES (1, 'Center North');
INSERT INTO distribution_centers (center_id, center_name) VALUES (2, 'Center West');
INSERT INTO distribution_centers (center_id, center_name) VALUES (3, 'Coast DC');
INSERT INTO distribution_centers (center_id, center_name) VALUES (4, 'Coffee DC');
INSERT INTO distribution_centers (center_id, center_name) VALUES (5, 'East Hub');
INSERT INTO distribution_centers (center_id, center_name) VALUES (6, 'South Hub');

-- 2.2. Ciudades
INSERT INTO cities (city_id, city_name, center_id) VALUES (1, 'Barranquilla', 3);
INSERT INTO cities (city_id, city_name, center_id) VALUES (2, 'Bogotá', 1);
INSERT INTO cities (city_id, city_name, center_id) VALUES (3, 'Bucaramanga', 5);
INSERT INTO cities (city_id, city_name, center_id) VALUES (4, 'Cali', 6);
INSERT INTO cities (city_id, city_name, center_id) VALUES (5, 'Cartagena', 3);
INSERT INTO cities (city_id, city_name, center_id) VALUES (6, 'Cúcuta', 5);
INSERT INTO cities (city_id, city_name, center_id) VALUES (7, 'Manizales', 4);
INSERT INTO cities (city_id, city_name, center_id) VALUES (8, 'Medellín', 2);
INSERT INTO cities (city_id, city_name, center_id) VALUES (9, 'Pereira', 4);

-- 2.3. Clientes
INSERT INTO clients (client_id, client_name, city_id) VALUES (1, 'EcoStore', 5);
INSERT INTO clients (client_id, client_name, city_id) VALUES (2, 'FoodPlus', 7);
INSERT INTO clients (client_id, client_name, city_id) VALUES (3, 'FreshMart', 8);
INSERT INTO clients (client_id, client_name, city_id) VALUES (4, 'GreenBuy', 2);
INSERT INTO clients (client_id, client_name, city_id) VALUES (5, 'MarketOne', 3);
INSERT INTO clients (client_id, client_name, city_id) VALUES (6, 'MiniShop', 4);
INSERT INTO clients (client_id, client_name, city_id) VALUES (7, 'QuickFood', 6);
INSERT INTO clients (client_id, client_name, city_id) VALUES (8, 'RetailCo', 9);
INSERT INTO clients (client_id, client_name, city_id) VALUES (9, 'SuperMax', 1);

-- 2.4. Categorías
INSERT INTO categories (category_id, category_name) VALUES (1, 'Dairy');
INSERT INTO categories (category_id, category_name) VALUES (2, 'Fruits');
INSERT INTO categories (category_id, category_name) VALUES (3, 'Grains');
INSERT INTO categories (category_id, category_name) VALUES (4, 'Meats');
INSERT INTO categories (category_id, category_name) VALUES (5, 'Oils');
INSERT INTO categories (category_id, category_name) VALUES (6, 'Vegetables');

-- 2.5. Productos
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (1, 'Bananas', 2, 1.20);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (2, 'Chicken Breast', 4, 6.50);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (3, 'Eggs x12', 1, 4.20);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (4, 'Gala Apple', 2, 2.50);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (5, 'Lettuce', 6, 1.10);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (6, 'Olive Oil', 5, 8.90);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (7, 'Pasta', 3, 2.30);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (8, 'Rice 1kg', 3, 2.00);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (9, 'Tomatoes', 6, 1.80);
INSERT INTO products (product_id, product_name, category_id, unit_price) VALUES (10, 'Whole Milk', 1, 3.80);

-- 2.6. Inventarios
INSERT INTO inventories (center_id, product_id, stock) VALUES (1, 4, 110);
INSERT INTO inventories (center_id, product_id, stock) VALUES (2, 1, 200);
INSERT INTO inventories (center_id, product_id, stock) VALUES (6, 10, 72);
INSERT INTO inventories (center_id, product_id, stock) VALUES (3, 2, 95);
INSERT INTO inventories (center_id, product_id, stock) VALUES (3, 8, 230);
INSERT INTO inventories (center_id, product_id, stock) VALUES (5, 6, 46);
INSERT INTO inventories (center_id, product_id, stock) VALUES (4, 3, 104);
INSERT INTO inventories (center_id, product_id, stock) VALUES (4, 9, 142);
INSERT INTO inventories (center_id, product_id, stock) VALUES (1, 5, 61);
INSERT INTO inventories (center_id, product_id, stock) VALUES (5, 7, 159);

-- 2.7. Pedidos
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1001', 9, '2026-05-01');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1002', 9, '2026-05-02');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1003', 3, '2026-05-02');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1004', 3, '2026-05-03');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1005', 6, '2026-05-04');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1006', 6, '2026-05-05');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1007', 9, '2026-05-06');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1008', 9, '2026-05-07');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1009', 1, '2026-05-08');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1010', 1, '2026-05-09');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1011', 5, '2026-05-10');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1012', 5, '2026-05-11');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1013', 8, '2026-05-12');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1014', 8, '2026-05-13');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1015', 2, '2026-05-14');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1016', 2, '2026-05-15');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1017', 4, '2026-05-16');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1018', 4, '2026-05-17');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1019', 7, '2026-05-18');
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O1020', 7, '2026-05-19');

-- 2.8. Detalles de Pedidos
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (1, 'O1001', 4, 10, 2.50);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (2, 'O1002', 4, 5, 2.50);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (3, 'O1003', 1, 20, 1.20);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (4, 'O1004', 1, 15, 1.20);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (5, 'O1005', 10, 12, 3.80);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (6, 'O1006', 10, 8, 3.80);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (7, 'O1007', 2, 25, 6.50);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (8, 'O1008', 2, 10, 6.50);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (9, 'O1009', 8, 30, 2.00);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (10, 'O1010', 8, 18, 2.00);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (11, 'O1011', 6, 6, 8.90);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (12, 'O1012', 6, 4, 8.90);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (13, 'O1013', 3, 14, 4.20);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (14, 'O1014', 3, 9, 4.20);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (15, 'O1015', 9, 22, 1.80);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (16, 'O1016', 9, 16, 1.80);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (17, 'O1017', 5, 11, 1.10);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (18, 'O1018', 5, 7, 1.10);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (19, 'O1019', 7, 19, 2.30);
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (20, 'O1020', 7, 13, 2.30);


-- ============================================================================
-- 3. PRUEBAS DML (Inserción, Actualización y Eliminación de Prueba)
-- ============================================================================

-- 3.1. Registrar nuevo cliente con un pedido y actualizar inventario
INSERT INTO clients (client_id, client_name, city_id) VALUES (10, 'Sabor Local', 1);
INSERT INTO orders (order_id, client_id, order_date) VALUES ('O2001', 10, '2026-06-01');
INSERT INTO order_details (detail_id, order_id, product_id, quantity, unit_price) VALUES (21, 'O2001', 1, 15, 2.50);
UPDATE inventories SET stock = stock - 15 WHERE center_id = 1 AND product_id = 1;

-- Verificar inserción
SELECT '=== 1. PRUEBA DE INSERCIÓN: REGISTRAR NUEVO CLIENTE (Sabor Local) ===' AS 'EVIDENCIA';
SELECT * FROM clients WHERE client_name = 'Sabor Local';
SELECT * FROM orders WHERE order_id = 'O2001';
SELECT * FROM order_details WHERE order_id = 'O2001';

-- 3.2. Actualizar el nombre de un Centro de Distribución
UPDATE distribution_centers SET center_name = 'Caribbean Logistics Hub' WHERE center_name = 'Coast DC';

-- Verificar actualización
SELECT '=== 2. PRUEBA DE ACTUALIZACIÓN: MODIFICAR CENTRO DE DISTRIBUCIÓN (Coast DC -> Caribbean Logistics Hub) ===' AS 'EVIDENCIA';
SELECT * FROM distribution_centers;

-- 3.3. Eliminar un producto sin dependencias (temporal de prueba)
INSERT INTO products (product_name, category_id, unit_price) VALUES ('Temporary Test Mango', 1, 1.50);
SELECT '=== 3. PRUEBA DE INSERCIÓN PARA BORRADO: CREAR PRODUCTO TEMPORAL ===' AS 'EVIDENCIA';
SELECT * FROM products WHERE product_name = 'Temporary Test Mango';
DELETE FROM products WHERE product_name = 'Temporary Test Mango';


-- ============================================================================
-- 4. CONSULTAS DE NEGOCIO (Reportes Analíticos)
-- ============================================================================

-- Consulta 1: Inventario disponible por producto
SELECT '=== CONSULTA 1: INVENTARIO DISPONIBLE POR PRODUCTO ===' AS 'REPORTE';
SELECT 
    p.product_name AS "Producto", 
    SUM(i.stock) AS "Stock Disponible"
FROM products p
JOIN inventories i ON p.product_id = i.product_id
GROUP BY p.product_name
ORDER BY SUM(i.stock) DESC;

-- Consulta 2: Historial de pedidos por ciudad
SELECT '=== CONSULTA 2: HISTORIAL DE PEDIDOS POR CIUDAD ===' AS 'REPORTE';
SELECT 
    c.city_name AS "Ciudad", 
    COUNT(DISTINCT o.order_id) AS "Total Pedidos", 
    SUM(d.quantity * d.unit_price) AS "Ventas Totales"
FROM orders o
JOIN clients cl ON o.client_id = cl.client_id
JOIN cities c ON cl.city_id = c.city_id
JOIN order_details d ON o.order_id = d.order_id
GROUP BY c.city_name
ORDER BY COUNT(DISTINCT o.order_id) DESC;

-- Consulta 3: Total vendido por categoría
SELECT '=== CONSULTA 3: TOTAL VENDIDO POR CATEGORÍA ===' AS 'REPORTE';
SELECT 
    cat.category_name AS "Categoría", 
    SUM(d.quantity * d.unit_price) AS "Ventas Totales"
FROM order_details d
JOIN products p ON d.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
GROUP BY cat.category_name
ORDER BY SUM(d.quantity * d.unit_price) DESC;

-- Consulta 4: Productos con bajo inventario (< 50 unidades)
SELECT '=== CONSULTA 4: PRODUCTOS CON MENOR INVENTARIO (< 50 UNIDADES) ===' AS 'REPORTE';
SELECT 
    p.product_name AS "Producto", 
    SUM(i.stock) AS "Stock Total"
FROM products p
JOIN inventories i ON p.product_id = i.product_id
GROUP BY p.product_name
HAVING SUM(i.stock) < 50;

-- Consulta 5: Clientes más activos (por cantidad de pedidos)
SELECT '=== CONSULTA 5: CLIENTES CON MAYOR NÚMERO DE PEDIDOS ===' AS 'REPORTE';
SELECT 
    cl.client_name AS "Cliente", 
    COUNT(o.order_id) AS "Total Pedidos"
FROM orders o
JOIN clients cl ON o.client_id = cl.client_id
GROUP BY cl.client_name
ORDER BY COUNT(o.order_id) DESC;

-- Consulta 6: Valor total de inventario por centro logístico
SELECT '=== CONSULTA 6: VALOR ECONÓMICO DEL INVENTARIO POR CENTRO ===' AS 'REPORTE';
SELECT 
    dc.center_name AS "Centro de Distribución", 
    SUM(i.stock * p.unit_price) AS "Valor Financiero"
FROM inventories i
JOIN distribution_centers dc ON i.center_id = dc.center_id
JOIN products p ON i.product_id = p.product_id
GROUP BY dc.center_name
ORDER BY SUM(i.stock * p.unit_price) DESC;


-- ============================================================================
-- 5. PRUEBA DE VISTAS Y PROCEDIMIENTOS ALMACENADOS
-- ============================================================================

-- Probar Vista 1
SELECT '=== EXTRA: VISTA DE VENTAS POR CIUDAD ===' AS 'REPORTE';
SELECT * FROM view_sales_summary_by_city;

-- Probar Vista 2
SELECT '=== EXTRA: VISTA DE VALORACIÓN DE STOCK ===' AS 'REPORTE';
SELECT * FROM view_product_stock_valuation LIMIT 5;

-- Probar Procedimiento (Mostrar todos)
SELECT '=== EXTRA: PROCEDIMIENTO ALMACENADO CON PARÁMETRO NULL (TODOS LOS CLIENTES) ===' AS 'REPORTE';
CALL sp_get_clients(NULL);

-- Probar Procedimiento (Filtrar cliente con ID = 3)
SELECT '=== EXTRA: PROCEDIMIENTO ALMACENADO CON ID = 3 (UN CLIENTE) ===' AS 'REPORTE';
CALL sp_get_clients(3);
