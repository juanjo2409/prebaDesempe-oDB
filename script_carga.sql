-- EcoMarket Riwi S.A.S. - Data Loading Script
-- Generated automatically from cleaned Excel data

START TRANSACTION;

-- 1. Insert Distribution Centers
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (1, 'Center North');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (2, 'Center West');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (3, 'Coast DC');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (4, 'Coffee DC');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (5, 'East Hub');
INSERT IGNORE INTO distribution_centers (center_id, center_name) VALUES (6, 'South Hub');

-- 2. Insert Cities
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (1, 'Barranquilla', 3);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (2, 'Bogotá', 1);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (3, 'Bucaramanga', 5);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (4, 'Cali', 6);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (5, 'Cartagena', 3);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (6, 'Cúcuta', 5);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (7, 'Manizales', 4);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (8, 'Medellín', 2);
INSERT IGNORE INTO cities (city_id, city_name, center_id) VALUES (9, 'Pereira', 4);

-- 3. Insert Clients
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (1, 'EcoStore', 5);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (2, 'FoodPlus', 7);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (3, 'FreshMart', 8);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (4, 'GreenBuy', 2);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (5, 'MarketOne', 3);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (6, 'MiniShop', 4);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (7, 'QuickFood', 6);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (8, 'RetailCo', 9);
INSERT IGNORE INTO clients (client_id, client_name, city_id) VALUES (9, 'SuperMax', 1);

-- 4. Insert Categories
INSERT IGNORE INTO categories (category_id, category_name) VALUES (1, 'Dairy');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (2, 'Fruits');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (3, 'Grains');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (4, 'Meats');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (5, 'Oils');
INSERT IGNORE INTO categories (category_id, category_name) VALUES (6, 'Vegetables');

-- 5. Insert Products
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

-- 6. Insert Inventories
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

-- 7. Insert Orders
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

-- 8. Insert Order Details
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
