/*
ORDER TRACKING SYSTEM - MySQL schema (26 tables)
Target: MySQL 8.0.16+ / MySQL 8.4, InnoDB, utf8mb4.
Select an EMPTY database first. For online playgrounds, use their current schema.
No CREATE DATABASE / USE statements are required in online playgrounds.

- This is MySQL, not SQL Server, PostgreSQL, MariaDB, or MySQL 5.7.
- No DROP, no IF NOT EXISTS: existing tables cause an error.
- MySQL DDL commits implicitly; the entire file CANNOT be rolled back together.
  If execution fails halfway, earlier CREATE TABLE statements may remain.
- UUIDs are VARCHAR(36), default UUID(); application-generated UUIDs are supported.
  UUID columns use case-sensitive ASCII; use canonical lowercase UUID strings.
- All connections must use UTC (time_zone = '+00:00').
- updated_at updates automatically when another stored value changes.
- created_by / updated_by allow NULL for system actions, with no FK.
- row_version is a BIGINT for application-managed optimistic locking (@Version);
  it is NOT an automatically maintained SQL Server ROWVERSION.
- Active-only UNIQUE rules use generated nullable markers.
  MySQL allows multiple NULLs in a UNIQUE index.
- Nonunique filtered indexes / INCLUDE were replaced with MySQL composite indexes.
- Foreign keys do not enforce soft deletion, roles, or allowed status transitions.
- Backend transactions must validate item totals, discounts, seller consistency,
  currency, required order children, and notification-to-order consistency.
- Hash access/reset tokens before storage; use bcrypt/Argon2 for passwords.
- Write status, timeline, delivery attempt and notification in one transaction.
*/

SET NAMES utf8mb4;
SET SESSION time_zone = '+00:00';

-- 01. All accounts; role membership is stored in user_roles.
CREATE TABLE `users`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    email VARCHAR(254) NOT NULL,
    username VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NULL,
    status VARCHAR(20) NOT NULL DEFAULT ('ACTIVE'),
    email_verified_at DATETIME(3) NULL,
    active_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT CK_users_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'LOCKED')),
    CONSTRAINT CK_users_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_users_email (email, active_unique_marker),
    UNIQUE KEY UX_users_username (username, active_unique_marker)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 02. Roles such as BUYER, SELLER, WAREHOUSE, SHIPPER and ADMIN.
CREATE TABLE `roles`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    PRIMARY KEY (id),
    CONSTRAINT CK_roles_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_roles_code (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 03. Application permission catalogue.
CREATE TABLE `permissions`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    code VARCHAR(100) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description VARCHAR(500) NULL,
    PRIMARY KEY (id),
    CONSTRAINT CK_permissions_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_permissions_code (code)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 04. User-to-role assignments.
CREATE TABLE `user_roles`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    user_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    role_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    active_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT FK_user_roles_user FOREIGN KEY (user_id) REFERENCES `users`(id),
    CONSTRAINT FK_user_roles_role FOREIGN KEY (role_id) REFERENCES `roles`(id),
    CONSTRAINT CK_user_roles_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_user_roles_active (user_id, role_id, active_unique_marker),
    KEY IX_user_roles_role (role_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 05. Role-to-permission assignments.
CREATE TABLE `role_permissions`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    role_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    permission_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    active_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT FK_role_permissions_role FOREIGN KEY (role_id) REFERENCES `roles`(id),
    CONSTRAINT FK_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES `permissions`(id),
    CONSTRAINT CK_role_permissions_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_role_permissions_active (role_id, permission_id, active_unique_marker),
    KEY IX_role_permissions_permission (permission_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 06. Access token denylist. Store a SHA-256 hash, never the raw token.
CREATE TABLE `invalidated_tokens`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    user_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    expires_at DATETIME(3) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_invalidated_tokens_user FOREIGN KEY (user_id) REFERENCES `users`(id),
    CONSTRAINT UQ_invalidated_tokens_hash UNIQUE (token_hash),
    CONSTRAINT CK_invalidated_tokens_expiry CHECK (expires_at > created_at),
    CONSTRAINT CK_invalidated_tokens_booleans CHECK (deleted IN (0, 1)),
    KEY IX_invalidated_tokens_expiry (expires_at),
    KEY IX_invalidated_tokens_user (user_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 07. One-time password reset tokens. Store SHA-256 hashes.
CREATE TABLE `password_reset_tokens`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    user_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    expires_at DATETIME(3) NOT NULL,
    used_at DATETIME(3) NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_password_reset_tokens_user FOREIGN KEY (user_id) REFERENCES `users`(id),
    CONSTRAINT UQ_password_reset_tokens_hash UNIQUE (token_hash),
    CONSTRAINT CK_password_reset_tokens_expiry CHECK (expires_at > created_at),
    CONSTRAINT CK_password_reset_tokens_used CHECK (used_at IS NULL OR (used_at >= created_at AND used_at <= expires_at)),
    CONSTRAINT CK_password_reset_tokens_booleans CHECK (deleted IN (0, 1)),
    KEY IX_password_reset_tokens_user (user_id, deleted, expires_at),
    KEY IX_password_reset_tokens_expiry (expires_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 08. Editable address book; orders use their own address snapshot.
CREATE TABLE `user_addresses`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    user_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    label VARCHAR(50) NULL,
    recipient_name VARCHAR(150) NOT NULL,
    recipient_phone VARCHAR(30) NOT NULL,
    address_line VARCHAR(500) NOT NULL,
    ward VARCHAR(150) NULL,
    district VARCHAR(150) NULL,
    province VARCHAR(150) NOT NULL,
    country_code CHAR(2) NOT NULL DEFAULT ('VN'),
    postal_code VARCHAR(20) NULL,
    is_default TINYINT(1) NOT NULL DEFAULT (0),
    default_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 AND is_default = 1 THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT FK_user_addresses_user FOREIGN KEY (user_id) REFERENCES `users`(id),
    CONSTRAINT CK_user_addresses_booleans CHECK (deleted IN (0, 1) AND is_default IN (0, 1)),
    KEY IX_user_addresses_user (user_id, deleted),
    UNIQUE KEY UX_user_addresses_default (user_id, default_unique_marker)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 09. Each product belongs to one seller.
CREATE TABLE `products`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    seller_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    name VARCHAR(255) NOT NULL,
    description LONGTEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT ('DRAFT'),
    PRIMARY KEY (id),
    CONSTRAINT FK_products_seller FOREIGN KEY (seller_id) REFERENCES `users`(id),
    CONSTRAINT CK_products_status CHECK (status IN ('DRAFT', 'ACTIVE', 'INACTIVE')),
    CONSTRAINT CK_products_booleans CHECK (deleted IN (0, 1)),
    KEY IX_products_seller (seller_id, deleted, status)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 10. Simple colour/size variants. Weight in grams.
CREATE TABLE `product_variants`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    product_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    sku VARCHAR(100) NOT NULL,
    name VARCHAR(255) NULL,
    color VARCHAR(100) NULL,
    size VARCHAR(100) NULL,
    price DECIMAL(19,2) NOT NULL,
    weight_grams DECIMAL(12,3) NOT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT (1),
    PRIMARY KEY (id),
    CONSTRAINT FK_product_variants_product FOREIGN KEY (product_id) REFERENCES `products`(id),
    CONSTRAINT UQ_product_variants_sku UNIQUE (sku),
    CONSTRAINT UQ_product_variants_product_id UNIQUE (product_id, id),
    CONSTRAINT CK_product_variants_price CHECK (price >= 0),
    CONSTRAINT CK_product_variants_weight CHECK (weight_grams > 0),
    CONSTRAINT CK_product_variants_booleans CHECK (deleted IN (0, 1) AND is_active IN (0, 1)),
    KEY IX_product_variants_product (product_id, deleted)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 11. Optional variant must belong to the same product.
CREATE TABLE `product_images`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    product_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    product_variant_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    image_url VARCHAR(2048) NOT NULL,
    alt_text VARCHAR(255) NULL,
    sort_order INT NOT NULL DEFAULT (0),
    is_primary TINYINT(1) NOT NULL DEFAULT (0),
    PRIMARY KEY (id),
    CONSTRAINT FK_product_images_product FOREIGN KEY (product_id) REFERENCES `products`(id),
    CONSTRAINT FK_product_images_variant FOREIGN KEY (product_id, product_variant_id) REFERENCES `product_variants`(product_id, id),
    CONSTRAINT CK_product_images_sort CHECK (sort_order >= 0),
    CONSTRAINT CK_product_images_booleans CHECK (deleted IN (0, 1) AND is_primary IN (0, 1)),
    KEY IX_product_images_product (product_id, deleted, sort_order),
    KEY IX_product_images_variant (product_id, product_variant_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 12. Single stock pool per variant. Available = on_hand - reserved.
CREATE TABLE `inventories`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    product_variant_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    quantity_on_hand INT NOT NULL DEFAULT (0),
    quantity_reserved INT NOT NULL DEFAULT (0),
    row_version BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT FK_inventories_variant FOREIGN KEY (product_variant_id) REFERENCES `product_variants`(id),
    CONSTRAINT UQ_inventories_variant UNIQUE (product_variant_id),
    CONSTRAINT CK_inventories_quantities CHECK (quantity_on_hand >= 0 AND quantity_reserved >= 0 AND quantity_reserved <= quantity_on_hand),
    CONSTRAINT CK_inventories_booleans CHECK (deleted IN (0, 1))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 13. At most one active, non-deleted cart per user.
CREATE TABLE `carts`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    user_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT ('ACTIVE'),
    active_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 AND status = 'ACTIVE' THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT FK_carts_user FOREIGN KEY (user_id) REFERENCES `users`(id),
    CONSTRAINT CK_carts_status CHECK (status IN ('ACTIVE', 'CHECKED_OUT', 'ABANDONED')),
    CONSTRAINT CK_carts_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_carts_active_user (user_id, active_unique_marker)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 14. A variant appears once per active cart item.
CREATE TABLE `cart_items`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    cart_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    product_variant_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    quantity INT NOT NULL,
    active_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT FK_cart_items_cart FOREIGN KEY (cart_id) REFERENCES `carts`(id),
    CONSTRAINT FK_cart_items_variant FOREIGN KEY (product_variant_id) REFERENCES `product_variants`(id),
    CONSTRAINT CK_cart_items_quantity CHECK (quantity > 0),
    CONSTRAINT CK_cart_items_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_cart_items_active (cart_id, product_variant_id, active_unique_marker),
    KEY IX_cart_items_variant (product_variant_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 15. One seller per order. Monetary amounts are checkout snapshots.
CREATE TABLE `orders`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    order_number VARCHAR(50) NOT NULL,
    buyer_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    seller_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT ('PENDING'),
    payment_status VARCHAR(30) NOT NULL DEFAULT ('UNPAID'),
    currency CHAR(3) NOT NULL DEFAULT ('VND'),
    subtotal DECIMAL(19,2) NOT NULL,
    discount_total DECIMAL(19,2) NOT NULL DEFAULT (0),
    shipping_fee DECIMAL(19,2) NOT NULL DEFAULT (0),
    grand_total DECIMAL(19,2) NOT NULL,
    customer_note VARCHAR(1000) NULL,
    recipient_name VARCHAR(150) NOT NULL,
    recipient_phone VARCHAR(30) NOT NULL,
    shipping_address_line VARCHAR(500) NOT NULL,
    shipping_ward VARCHAR(150) NULL,
    shipping_district VARCHAR(150) NULL,
    shipping_province VARCHAR(150) NOT NULL,
    shipping_country_code CHAR(2) NOT NULL DEFAULT ('VN'),
    shipping_postal_code VARCHAR(20) NULL,
    placed_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    confirmed_at DATETIME(3) NULL,
    cancelled_at DATETIME(3) NULL,
    cancellation_reason VARCHAR(1000) NULL,
    payment_due_at DATETIME(3) NULL,
    row_version BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT FK_orders_buyer FOREIGN KEY (buyer_id) REFERENCES `users`(id),
    CONSTRAINT FK_orders_seller FOREIGN KEY (seller_id) REFERENCES `users`(id),
    CONSTRAINT UQ_orders_number UNIQUE (order_number),
    CONSTRAINT CK_orders_status CHECK (status IN ('AWAITING_PAYMENT', 'PENDING', 'CONFIRMED', 'PROCESSING', 'COMPLETED', 'CANCELLED')),
    CONSTRAINT CK_orders_payment_status CHECK (payment_status IN ('UNPAID', 'PENDING', 'PAID', 'FAILED', 'PARTIALLY_REFUNDED', 'REFUNDED')),
    CONSTRAINT CK_orders_amounts CHECK (subtotal >= 0 AND discount_total >= 0 AND discount_total <= subtotal AND shipping_fee >= 0 AND grand_total = subtotal - discount_total + shipping_fee),
    CONSTRAINT CK_orders_booleans CHECK (deleted IN (0, 1)),
    KEY IX_orders_buyer (buyer_id, deleted, placed_at DESC),
    KEY IX_orders_seller (seller_id, deleted, status, placed_at DESC),
    KEY IX_orders_payment_due (status, deleted, payment_due_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 16. Historical item snapshot. Prices/discounts are independent of later catalogue changes.
CREATE TABLE `order_items`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    order_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    product_variant_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(255) NULL,
    sku VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(19,2) NOT NULL,
    weight_grams DECIMAL(12,3) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_order_items_order FOREIGN KEY (order_id) REFERENCES `orders`(id),
    CONSTRAINT FK_order_items_variant FOREIGN KEY (product_variant_id) REFERENCES `product_variants`(id),
    CONSTRAINT CK_order_items_values CHECK (quantity > 0 AND unit_price >= 0 AND weight_grams > 0),
    CONSTRAINT CK_order_items_booleans CHECK (deleted IN (0, 1)),
    KEY IX_order_items_order (order_id),
    KEY IX_order_items_variant (product_variant_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 17. Order-level merchandise discounts only; no shipping discount in this model.
CREATE TABLE `discounts`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description VARCHAR(1000) NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(19,2) NOT NULL,
    max_discount_amount DECIMAL(19,2) NULL,
    min_order_amount DECIMAL(19,2) NOT NULL DEFAULT (0),
    starts_at DATETIME(3) NOT NULL,
    ends_at DATETIME(3) NOT NULL,
    usage_limit INT NULL,
    per_user_limit INT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT (1),
    PRIMARY KEY (id),
    CONSTRAINT UQ_discounts_code UNIQUE (code),
    CONSTRAINT CK_discounts_type CHECK (discount_type IN ('PERCENT', 'FIXED')),
    CONSTRAINT CK_discounts_value CHECK (discount_value > 0 AND (discount_type <> 'PERCENT' OR discount_value <= 100)),
    CONSTRAINT CK_discounts_limits CHECK (min_order_amount >= 0 AND (max_discount_amount IS NULL OR max_discount_amount > 0) AND (usage_limit IS NULL OR usage_limit > 0) AND (per_user_limit IS NULL OR per_user_limit > 0)),
    CONSTRAINT CK_discounts_dates CHECK (ends_at > starts_at),
    CONSTRAINT CK_discounts_booleans CHECK (deleted IN (0, 1) AND is_active IN (0, 1)),
    KEY IX_discounts_validity (is_active, deleted, starts_at, ends_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 18. Snapshot of each discount actually applied.
CREATE TABLE `order_discounts`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    order_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    discount_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    discount_code VARCHAR(50) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(19,2) NOT NULL,
    discount_amount DECIMAL(19,2) NOT NULL,
    active_unique_marker TINYINT GENERATED ALWAYS AS (CASE WHEN deleted = 0 THEN 1 ELSE NULL END) STORED,
    PRIMARY KEY (id),
    CONSTRAINT FK_order_discounts_order FOREIGN KEY (order_id) REFERENCES `orders`(id),
    CONSTRAINT FK_order_discounts_discount FOREIGN KEY (discount_id) REFERENCES `discounts`(id),
    CONSTRAINT CK_order_discounts_type CHECK (discount_type IN ('PERCENT', 'FIXED')),
    CONSTRAINT CK_order_discounts_values CHECK (discount_amount > 0 AND discount_value > 0 AND (discount_type <> 'PERCENT' OR discount_value <= 100)),
    CONSTRAINT CK_order_discounts_booleans CHECK (deleted IN (0, 1)),
    UNIQUE KEY UX_order_discounts_active (order_id, discount_id, active_unique_marker),
    KEY IX_order_discounts_discount (discount_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 19. Payment methods selectable during checkout.
CREATE TABLE `payment_types`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    code VARCHAR(30) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500) NULL,
    is_online TINYINT(1) NOT NULL DEFAULT (0),
    is_active TINYINT(1) NOT NULL DEFAULT (1),
    sort_order INT NOT NULL DEFAULT (0),
    PRIMARY KEY (id),
    CONSTRAINT UQ_payment_types_code UNIQUE (code),
    CONSTRAINT CK_payment_types_booleans CHECK (deleted IN (0, 1) AND is_online IN (0, 1) AND is_active IN (0, 1))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 20. One record per payment attempt. Verify provider signatures in the application.
CREATE TABLE `payments`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    order_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    payment_type_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    payment_reference VARCHAR(100) NOT NULL,
    provider_transaction_id VARCHAR(150) NULL,
    idempotency_key VARCHAR(100) NOT NULL,
    amount DECIMAL(19,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT ('VND'),
    status VARCHAR(30) NOT NULL DEFAULT ('PENDING'),
    paid_at DATETIME(3) NULL,
    expires_at DATETIME(3) NULL,
    failure_reason VARCHAR(1000) NULL,
    row_version BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT FK_payments_order FOREIGN KEY (order_id) REFERENCES `orders`(id),
    CONSTRAINT FK_payments_type FOREIGN KEY (payment_type_id) REFERENCES `payment_types`(id),
    CONSTRAINT UQ_payments_reference UNIQUE (payment_reference),
    CONSTRAINT UQ_payments_idempotency UNIQUE (idempotency_key),
    CONSTRAINT CK_payments_amount CHECK (amount >= 0),
    CONSTRAINT CK_payments_status CHECK (status IN ('PENDING', 'SUCCEEDED', 'FAILED', 'CANCELLED', 'EXPIRED')),
    CONSTRAINT CK_payments_paid CHECK ((status = 'SUCCEEDED' AND paid_at IS NOT NULL) OR (status <> 'SUCCEEDED' AND paid_at IS NULL)),
    CONSTRAINT CK_payments_booleans CHECK (deleted IN (0, 1)),
    KEY IX_payments_order (order_id, created_at DESC),
    UNIQUE KEY UX_payments_provider_transaction (payment_type_id, provider_transaction_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 21. Carrier catalogue. Keep credentials outside this database script.
CREATE TABLE `carriers`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(150) NOT NULL,
    contact_phone VARCHAR(30) NULL,
    contact_email VARCHAR(254) NULL,
    tracking_url_template VARCHAR(2048) NULL,
    is_active TINYINT(1) NOT NULL DEFAULT (1),
    PRIMARY KEY (id),
    CONSTRAINT UQ_carriers_code UNIQUE (code),
    CONSTRAINT CK_carriers_booleans CHECK (deleted IN (0, 1) AND is_active IN (0, 1))
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 22. A tracking number is unique within its carrier. Multiple parcels per order are allowed.
CREATE TABLE `shipments`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    order_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    carrier_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    tracking_number VARCHAR(100) NOT NULL,
    shipper_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    status VARCHAR(30) NOT NULL DEFAULT ('PENDING'),
    weight_grams DECIMAL(12,3) NOT NULL,
    estimated_delivery_at DATETIME(3) NULL,
    picked_up_at DATETIME(3) NULL,
    delivered_at DATETIME(3) NULL,
    returned_at DATETIME(3) NULL,
    cancelled_at DATETIME(3) NULL,
    cancellation_reason VARCHAR(1000) NULL,
    row_version BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT FK_shipments_order FOREIGN KEY (order_id) REFERENCES `orders`(id),
    CONSTRAINT FK_shipments_carrier FOREIGN KEY (carrier_id) REFERENCES `carriers`(id),
    CONSTRAINT FK_shipments_shipper FOREIGN KEY (shipper_id) REFERENCES `users`(id),
    CONSTRAINT UQ_shipments_tracking UNIQUE (carrier_id, tracking_number),
    CONSTRAINT CK_shipments_status CHECK (status IN ('PENDING', 'CONFIRMED', 'PICKING', 'SHIPPING', 'DELIVERED', 'FAILED', 'REATTEMPT', 'RETURNING', 'RETURNED')),
    CONSTRAINT CK_shipments_weight CHECK (weight_grams > 0),
    CONSTRAINT CK_shipments_completion CHECK ((status <> 'DELIVERED' OR delivered_at IS NOT NULL) AND (status <> 'RETURNED' OR returned_at IS NOT NULL)),
    CONSTRAINT CK_shipments_booleans CHECK (deleted IN (0, 1)),
    KEY IX_shipments_order (order_id, deleted),
    KEY IX_shipments_carrier_status (carrier_id, deleted, status),
    KEY IX_shipments_shipper_status (shipper_id, deleted, status),
    KEY IX_shipments_status_eta (status, deleted, estimated_delivery_at)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 23. Append-only timeline. Initial event may have NULL from_status.
CREATE TABLE `tracking_logs`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    shipment_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    actor_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    from_status VARCHAR(30) NULL,
    to_status VARCHAR(30) NOT NULL,
    event_time DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    location VARCHAR(500) NULL,
    latitude DECIMAL(9,6) NULL,
    longitude DECIMAL(9,6) NULL,
    note VARCHAR(2000) NULL,
    source VARCHAR(20) NOT NULL,
    external_event_id VARCHAR(150) NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_tracking_logs_shipment FOREIGN KEY (shipment_id) REFERENCES `shipments`(id),
    CONSTRAINT FK_tracking_logs_actor FOREIGN KEY (actor_id) REFERENCES `users`(id),
    CONSTRAINT CK_tracking_logs_source CHECK (source IN ('STAFF', 'SHIPPER', 'SYSTEM', 'CARRIER')),
    CONSTRAINT CK_tracking_logs_from CHECK (from_status IS NULL OR from_status IN ('PENDING', 'CONFIRMED', 'PICKING', 'SHIPPING', 'DELIVERED', 'FAILED', 'REATTEMPT', 'RETURNING', 'RETURNED')),
    CONSTRAINT CK_tracking_logs_to CHECK (to_status IN ('PENDING', 'CONFIRMED', 'PICKING', 'SHIPPING', 'DELIVERED', 'FAILED', 'REATTEMPT', 'RETURNING', 'RETURNED')),
    CONSTRAINT CK_tracking_logs_coordinates CHECK ((latitude IS NULL AND longitude IS NULL) OR (latitude IS NOT NULL AND longitude IS NOT NULL AND latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)),
    CONSTRAINT CK_tracking_logs_booleans CHECK (deleted IN (0, 1)),
    KEY IX_tracking_logs_timeline (shipment_id, deleted, event_time, created_at),
    KEY IX_tracking_logs_actor (actor_id, event_time DESC),
    UNIQUE KEY UX_tracking_logs_external_event (shipment_id, source, external_event_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 24. Each attempted delivery, including failed attempts.
CREATE TABLE `delivery_attempts`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    shipment_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    attempt_number INT NOT NULL,
    shipper_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    attempted_at DATETIME(3) NOT NULL,
    result VARCHAR(20) NOT NULL,
    failure_reason VARCHAR(1000) NULL,
    note VARCHAR(2000) NULL,
    next_attempt_at DATETIME(3) NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_delivery_attempts_shipment FOREIGN KEY (shipment_id) REFERENCES `shipments`(id),
    CONSTRAINT FK_delivery_attempts_shipper FOREIGN KEY (shipper_id) REFERENCES `users`(id),
    CONSTRAINT UQ_delivery_attempts_number UNIQUE (shipment_id, attempt_number),
    CONSTRAINT CK_delivery_attempts_number CHECK (attempt_number > 0),
    CONSTRAINT CK_delivery_attempts_result CHECK (result IN ('DELIVERED', 'FAILED')),
    CONSTRAINT CK_delivery_attempts_failure CHECK (result <> 'FAILED' OR NULLIF(LTRIM(RTRIM(failure_reason)), '') IS NOT NULL),
    CONSTRAINT CK_delivery_attempts_next CHECK (next_attempt_at IS NULL OR (result = 'FAILED' AND next_attempt_at > attempted_at)),
    CONSTRAINT CK_delivery_attempts_booleans CHECK (deleted IN (0, 1)),
    KEY IX_delivery_attempts_shipper (shipper_id, attempted_at DESC)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 25. Database outbox processed by a scheduled job. Lease supports crash recovery.
CREATE TABLE `notifications`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    order_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    tracking_log_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    event_key VARCHAR(200) NOT NULL,
    channel VARCHAR(10) NOT NULL,
    recipient VARCHAR(320) NOT NULL,
    subject VARCHAR(255) NULL,
    content LONGTEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT ('PENDING'),
    retry_count INT NOT NULL DEFAULT (0),
    max_attempts INT NOT NULL DEFAULT (5),
    next_retry_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    locked_until DATETIME(3) NULL,
    locked_by VARCHAR(100) NULL,
    sent_at DATETIME(3) NULL,
    last_error VARCHAR(2000) NULL,
    PRIMARY KEY (id),
    CONSTRAINT FK_notifications_order FOREIGN KEY (order_id) REFERENCES `orders`(id),
    CONSTRAINT FK_notifications_log FOREIGN KEY (tracking_log_id) REFERENCES `tracking_logs`(id),
    CONSTRAINT UQ_notifications_event UNIQUE (event_key),
    CONSTRAINT CK_notifications_channel CHECK (channel IN ('EMAIL', 'SMS')),
    CONSTRAINT CK_notifications_status CHECK (status IN ('PENDING', 'PROCESSING', 'SENT', 'FAILED')),
    CONSTRAINT CK_notifications_attempts CHECK (retry_count >= 0 AND max_attempts > 0),
    CONSTRAINT CK_notifications_sent CHECK ((status = 'SENT' AND sent_at IS NOT NULL) OR (status <> 'SENT' AND sent_at IS NULL)),
    CONSTRAINT CK_notifications_lock CHECK ((locked_by IS NULL AND locked_until IS NULL) OR (locked_by IS NOT NULL AND locked_until IS NOT NULL)),
    CONSTRAINT CK_notifications_booleans CHECK (deleted IN (0, 1)),
    KEY IX_notifications_pending (status, deleted, next_retry_at, created_at),
    KEY IX_notifications_processing (status, deleted, locked_until),
    KEY IX_notifications_order (order_id, created_at DESC),
    KEY IX_notifications_log (tracking_log_id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- 26. Application audit trail; entity_id is polymorphic and intentionally has no FK.
CREATE TABLE `audit_logs`
(
    id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT (UUID()),
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    created_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
    updated_by VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    deleted TINYINT(1) NOT NULL DEFAULT 0,
    actor_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100) NOT NULL,
    entity_id VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent VARCHAR(1000) NULL,
    correlation_id VARCHAR(100) NULL,
    occurred_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT FK_audit_logs_actor FOREIGN KEY (actor_id) REFERENCES `users`(id),
    CONSTRAINT CK_audit_logs_booleans CHECK (deleted IN (0, 1)),
    KEY IX_audit_logs_entity (entity_type, entity_id, occurred_at DESC),
    KEY IX_audit_logs_actor (actor_id, occurred_at DESC)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- Enable online providers only after their integration is configured.
INSERT INTO `payment_types`
    (code, name, is_online, is_active, sort_order)
VALUES
    ('COD', 'Thanh toán khi nhận hàng', 0, 1, 1),
    ('VNPAY', 'Thanh toán qua VNPay', 1, 0, 2),
    ('MOMO', 'Thanh toán qua MoMo', 1, 0, 3),
    ('VietQR', 'Thanh toán qua VietQR', 1, 0, 4);

