-- EcoMarket Riwi S.A.S. - Analytical Business Queries
-- These queries resolve real-world business needs of the EcoMarket management.

-- ============================================================================
-- Consulta 1: Inventario disponible por producto
-- Necesidad: Como jefe de abastecimiento necesito conocer las existencias actuales 
-- para planificar nuevas compras.
-- ============================================================================
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


-- ============================================================================
-- Consulta 2: Historial de pedidos por ciudad
-- Necesidad: Como director comercial necesito conocer qué ciudades generan mayor 
-- volumen de pedidos e ingresos.
-- ============================================================================
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


-- ============================================================================
-- Consulta 3: Total vendido por categoría
-- Necesidad: Como gerente financiero necesito identificar qué categorías generan 
-- mayores ingresos para enfocar la inversión.
-- ============================================================================
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


-- ============================================================================
-- Consulta 4: Productos con menor inventario
-- Necesidad: Como coordinador logístico necesito conocer los productos próximos a 
-- agotarse (con un stock total menor a 50 unidades en toda la red).
-- ============================================================================
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


-- ============================================================================
-- Consulta 5: Clientes con mayor número de pedidos
-- Necesidad: Como director comercial necesito identificar los clientes más activos 
-- y con mayor frecuencia de compra para programas de fidelización.
-- ============================================================================
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


-- ============================================================================
-- Consulta 6: Valor económico del inventario por centro de distribución
-- Necesidad: Como gerente general necesito conocer el valor del inventario 
-- almacenado en cada centro logístico (stock * precio unitario estándar).
-- ============================================================================
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
-- EXTRA POINTS (+20 pts): Views & Stored Procedure Execution Tests
-- ============================================================================

-- 1. Test View 1: Commercial sales summary by city
SELECT '=== EXTRA: VISTA DE VENTAS POR CIUDAD ===' AS 'REPORTE';
SELECT * FROM view_sales_summary_by_city;

-- 2. Test View 2: Product stock valuation
SELECT '=== EXTRA: VISTA DE VALORACIÓN DE STOCK ===' AS 'REPORTE';
SELECT * FROM view_product_stock_valuation LIMIT 5;

-- 3. Test Stored Procedure: Query all clients (send NULL)
SELECT '=== EXTRA: PROCEDIMIENTO ALMACENADO CON PARÁMETRO NULL (TODOS LOS CLIENTES) ===' AS 'REPORTE';
CALL sp_get_clients(NULL);

-- 4. Test Stored Procedure: Query a specific client (send ID = 3)
SELECT '=== EXTRA: PROCEDIMIENTO ALMACENADO CON ID = 3 (UN CLIENTE) ===' AS 'REPORTE';
CALL sp_get_clients(3);
