-- EcoMarket Riwi S.A.S. - Data Manipulation Scripts (DML - MySQL)
-- This file contains SQL transactions for insertion, update, and deletion, validating constraints.

-- ============================================================================
-- 1. INSERTION CASE: Register a new client with an associated order
-- ============================================================================
START TRANSACTION;

-- Insert a new client (e.g. 'Sabor Local' in Bogotá (city_id = 1))
INSERT INTO clients (client_name, city_id) 
VALUES ('Sabor Local', 1);

-- Get the client ID and insert an order
INSERT INTO orders (order_id, client_id, order_date) 
VALUES (
    'O2001', 
    (SELECT client_id FROM (SELECT client_id FROM clients WHERE client_name = 'Sabor Local' LIMIT 1) AS tmp), 
    '2026-06-01'
);

-- Insert order details (e.g. 15 units of Gala Apple (product_id = 1) at price 2.50)
INSERT INTO order_details (order_id, product_id, quantity, unit_price) 
VALUES ('O2001', 1, 15, 2.50);

-- Update the inventory accordingly for Center North (center_id = 1, product_id = 1)
UPDATE inventories 
SET stock = stock - 15 
WHERE center_id = 1 AND product_id = 1;

COMMIT;

-- Verify insertion:
SELECT '=== 1. PRUEBA DE INSERCIÓN: REGISTRAR NUEVO CLIENTE (Sabor Local) ===' AS 'EVIDENCIA';
SELECT * FROM clients WHERE client_name = 'Sabor Local';
SELECT * FROM orders WHERE order_id = 'O2001';
SELECT * FROM order_details WHERE order_id = 'O2001';


-- ============================================================================
-- 2. UPDATE CASE: Modify information of a distribution center
-- ============================================================================
START TRANSACTION;

-- Update the name of 'Coast DC' to 'Caribbean Logistics Hub'
UPDATE distribution_centers 
SET center_name = 'Caribbean Logistics Hub' 
WHERE center_name = 'Coast DC';

COMMIT;

-- Verify update:
SELECT '=== 2. PRUEBA DE ACTUALIZACIÓN: MODIFICAR CENTRO DE DISTRIBUCIÓN (Coast DC -> Caribbean Logistics Hub) ===' AS 'EVIDENCIA';
SELECT * FROM distribution_centers;


-- ============================================================================
-- 3. DELETION CASE: Delete products (with and without constraints validation)
-- ============================================================================

-- A. Successful Delete: Delete a product with no associated orders
START TRANSACTION;

-- Create a temporary product for testing
INSERT INTO products (product_name, category_id, unit_price) 
VALUES ('Temporary Test Mango', 1, 1.50);

-- Verify it was created
SELECT '=== 3. PRUEBA DE INSERCIÓN PARA BORRADO: CREAR PRODUCTO TEMPORAL ===' AS 'EVIDENCIA';
SELECT * FROM products WHERE product_name = 'Temporary Test Mango';

-- Delete it (allowed since it has no orders)
DELETE FROM products 
WHERE product_name = 'Temporary Test Mango';

COMMIT;


-- B. Blocked Delete: Try to delete a product with active orders (Should fail!)
-- Gala Apple (product_id = 1) has orders (O1001, O1002, O2001)
-- Running the following statement will throw an integrity constraint violation error.
-- (This block is commented out so it doesn't break full script execution, but can be run to test the constraint).

/*
DELETE FROM products 
WHERE product_id = 1;
-- Expected Error: ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
*/
