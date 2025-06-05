-- 000001_initial.down.sql

-- 1. Remover índices de event_logs
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_event_logs_app_id' AND object_id = OBJECT_ID('dbo.event_logs'))
    DROP INDEX IX_event_logs_app_id ON dbo.event_logs;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_event_logs_user_id' AND object_id = OBJECT_ID('dbo.event_logs'))
    DROP INDEX IX_event_logs_user_id ON dbo.event_logs;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_event_logs_event_time' AND object_id = OBJECT_ID('dbo.event_logs'))
    DROP INDEX IX_event_logs_event_time ON dbo.event_logs;

-- 2. Apagar tabela event_logs
DROP TABLE IF EXISTS dbo.event_logs;

-- 3. Remover índices de order_items
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_order_items_app_id' AND object_id = OBJECT_ID('dbo.order_items'))
    DROP INDEX IX_order_items_app_id ON dbo.order_items;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_order_items_order_id' AND object_id = OBJECT_ID('dbo.order_items'))
    DROP INDEX IX_order_items_order_id ON dbo.order_items;

-- 4. Apagar tabela order_items
DROP TABLE IF EXISTS dbo.order_items;

-- 5. Remover índices de orders
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_orders_app_id' AND object_id = OBJECT_ID('dbo.orders'))
    DROP INDEX IX_orders_app_id ON dbo.orders;

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_orders_customer_id' AND object_id = OBJECT_ID('dbo.orders'))
    DROP INDEX IX_orders_customer_id ON dbo.orders;

-- 6. Apagar tabela orders
DROP TABLE IF EXISTS dbo.orders;

-- 7. Remover índices de products
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_products_app_id' AND object_id = OBJECT_ID('dbo.products'))
    DROP INDEX IX_products_app_id ON dbo.products;

-- 8. Apagar tabela products
DROP TABLE IF EXISTS dbo.products;

-- 9. Remover índices de customers
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_customers_app_id' AND object_id = OBJECT_ID('dbo.customers'))
    DROP INDEX IX_customers_app_id ON dbo.customers;

-- 10. Apagar tabela customers
DROP TABLE IF EXISTS dbo.customers;

-- 11. Remover índices de users
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_users_app_id' AND object_id = OBJECT_ID('dbo.users'))
    DROP INDEX IX_users_app_id ON dbo.users;

-- 12. Apagar tabela users
DROP TABLE IF EXISTS dbo.users;

-- 13. Apagar tabela applications
DROP TABLE IF EXISTS dbo.applications;
