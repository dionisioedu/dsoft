-- 000001_initial.up.sql

-- 1. Tabela “applications”
CREATE TABLE dbo.applications (
    id               UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    name             NVARCHAR(150)      NOT NULL UNIQUE,
    description      NVARCHAR(500)      NULL,
    api_key_hash     VARCHAR(100)       NOT NULL,
    api_key_salt     VARCHAR(50)        NOT NULL,
    created_at       DATETIME2          NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at       DATETIME2          NULL
);

-- 2. Tabela “users” (depende de applications)
CREATE TABLE dbo.users (
    id                  UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    application_id      UNIQUEIDENTIFIER  NOT NULL,
    name                NVARCHAR(100)      NOT NULL,
    email               NVARCHAR(150)      NOT NULL,
    password_hash       NVARCHAR(200)      NOT NULL,
    role                NVARCHAR(50)       NOT NULL,
    created_at          DATETIME2          NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2          NULL,
    CONSTRAINT FK_users_applications
        FOREIGN KEY(application_id) REFERENCES dbo.applications(id) ON DELETE CASCADE,
    CONSTRAINT UQ_users_email_per_app
        UNIQUE(application_id, email)
);
CREATE INDEX IX_users_app_id ON dbo.users(application_id);

-- 3. Tabela “customers” (depende de applications)
CREATE TABLE dbo.customers (
    id                  UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    application_id      UNIQUEIDENTIFIER  NOT NULL,
    name                NVARCHAR(150)      NOT NULL,
    cnpj_cpf            NVARCHAR(20)       NULL,
    email               NVARCHAR(150)      NULL,
    phone               NVARCHAR(20)       NULL,
    address             NVARCHAR(300)      NULL,
    created_at          DATETIME2          NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2          NULL,
    CONSTRAINT FK_customers_applications
        FOREIGN KEY(application_id) REFERENCES dbo.applications(id) ON DELETE CASCADE
);
CREATE INDEX IX_customers_app_id ON dbo.customers(application_id);

-- 4. Tabela “products” (depende de applications)
CREATE TABLE dbo.products (
    id                  UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    application_id      UNIQUEIDENTIFIER  NOT NULL,
    name                NVARCHAR(150)      NOT NULL,
    description         NVARCHAR(500)      NULL,
    price               DECIMAL(18,2)      NOT NULL,
    stock               INT                NOT NULL DEFAULT 0,
    active              BIT                NOT NULL DEFAULT 1,
    created_at          DATETIME2          NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2          NULL,
    CONSTRAINT FK_products_applications
        FOREIGN KEY(application_id) REFERENCES dbo.applications(id) ON DELETE CASCADE,
    CONSTRAINT UQ_products_name_per_app
        UNIQUE(application_id, name)
);
CREATE INDEX IX_products_app_id ON dbo.products(application_id);

-- 5. Tabela “orders” (depende de applications, customers e users)
CREATE TABLE dbo.orders (
    id                  UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    application_id      UNIQUEIDENTIFIER  NOT NULL,
    customer_id         UNIQUEIDENTIFIER  NOT NULL,
    user_id             UNIQUEIDENTIFIER  NOT NULL,
    order_date          DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    status              NVARCHAR(30)      NOT NULL DEFAULT 'Pendente',
    total_amount        DECIMAL(18,2)     NOT NULL,
    created_at          DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2         NULL,
    CONSTRAINT FK_orders_applications
        FOREIGN KEY(application_id) REFERENCES dbo.applications(id) ON DELETE CASCADE,
    CONSTRAINT FK_orders_customers
        FOREIGN KEY(customer_id) REFERENCES dbo.customers(id) ON DELETE NO ACTION,
    CONSTRAINT FK_orders_users
        FOREIGN KEY(user_id) REFERENCES dbo.users(id) ON DELETE NO ACTION
);
CREATE INDEX IX_orders_app_id ON dbo.orders(application_id);
CREATE INDEX IX_orders_customer_id ON dbo.orders(customer_id);

-- 6. Tabela “order_items” (depende de applications, orders e products)
CREATE TABLE dbo.order_items (
    id                  UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    application_id      UNIQUEIDENTIFIER  NOT NULL,
    order_id            UNIQUEIDENTIFIER  NOT NULL,
    product_id          UNIQUEIDENTIFIER  NOT NULL,
    quantity            INT               NOT NULL,
    unit_price          DECIMAL(18,2)     NOT NULL,
    total_price         DECIMAL(18,2)     NOT NULL,
    created_at          DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    updated_at          DATETIME2         NULL,
    CONSTRAINT FK_order_items_applications
        FOREIGN KEY(application_id) REFERENCES dbo.applications(id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_orders
        FOREIGN KEY(order_id) REFERENCES dbo.orders(id) ON DELETE NO ACTION,
    CONSTRAINT FK_order_items_products
        FOREIGN KEY(product_id) REFERENCES dbo.products(id) ON DELETE NO ACTION
);
CREATE INDEX IX_order_items_app_id ON dbo.order_items(application_id);
CREATE INDEX IX_order_items_order_id ON dbo.order_items(order_id);

-- 7. Tabela “event_logs” (depende de applications e users)
CREATE TABLE dbo.event_logs (
    id                  UNIQUEIDENTIFIER  NOT NULL PRIMARY KEY DEFAULT NEWID(),
    application_id      UNIQUEIDENTIFIER  NOT NULL,
    user_id             UNIQUEIDENTIFIER  NOT NULL,
    event_type          NVARCHAR(100)     NOT NULL,
    description         NVARCHAR(MAX)     NULL,
    metadata            NVARCHAR(MAX)     NULL,
    event_time          DATETIME2         NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_event_logs_applications
        FOREIGN KEY(application_id) REFERENCES dbo.applications(id) ON DELETE CASCADE,
    CONSTRAINT FK_event_logs_users
        FOREIGN KEY(user_id) REFERENCES dbo.users(id) ON DELETE NO ACTION
);
CREATE INDEX IX_event_logs_app_id ON dbo.event_logs(application_id);
CREATE INDEX IX_event_logs_user_id ON dbo.event_logs(user_id);
CREATE INDEX IX_event_logs_event_time ON dbo.event_logs(event_time);
