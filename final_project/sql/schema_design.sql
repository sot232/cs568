-- =====================================================
-- ONLINE BOOKSTORE MANAGEMENT SYSTEM - DATABASE SCHEMA
-- =====================================================
-- CS568 Final Project
-- Complete OLTP and OLAP schema for online bookstore
-- =====================================================

-- Create database
CREATE DATABASE IF NOT EXISTS bookstore;
USE bookstore;

-- =====================================================
-- OLTP SCHEMA - OPERATIONAL TABLES
-- =====================================================

-- 1. AUTHORS TABLE
-- Purpose: Store author information
-- Keys: author_id (PK)
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50),
    biography TEXT,
    website_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_author_name (last_name, first_name),
    INDEX idx_nationality (nationality)
);

-- 2. PUBLISHERS TABLE
-- Purpose: Store publisher information
-- Keys: publisher_id (PK)
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    address TEXT,
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    website_url VARCHAR(255),
    founded_year YEAR,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_publisher_name (name),
    INDEX idx_country (country)
);

-- 3. CATEGORIES TABLE
-- Purpose: Store book categories/genres
-- Keys: category_id (PK)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL,
    INDEX idx_category_name (name),
    INDEX idx_parent_category (parent_category_id)
);

-- 4. BOOKS TABLE (Enhanced from CSV)
-- Purpose: Store book information
-- Keys: book_id (PK), publisher_id (FK), category_id (FK)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher_id INT NOT NULL,
    category_id INT NOT NULL,
    publication_date DATE,
    edition VARCHAR(50),
    pages INT,
    language VARCHAR(50) DEFAULT 'English',
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    min_stock_level INT DEFAULT 10,
    book_url VARCHAR(500),
    cover_image_url VARCHAR(500),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT,
    INDEX idx_book_title (title),
    INDEX idx_isbn (isbn),
    INDEX idx_price (price),
    INDEX idx_stock (stock_quantity),
    INDEX idx_category (category_id),
    INDEX idx_publisher (publisher_id),
    INDEX idx_publication_date (publication_date)
);

-- 5. BOOK_AUTHORS TABLE (Many-to-Many)
-- Purpose: Link books to authors (books can have multiple authors)
-- Keys: book_id (FK), author_id (FK), composite PK
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,
    royalty_percentage DECIMAL(5,2) DEFAULT 0.00,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE,
    INDEX idx_author_order (author_order)
);

-- 6. CUSTOMERS TABLE
-- Purpose: Store customer information
-- Keys: customer_id (PK)
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other') DEFAULT 'Other',
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_email (email),
    INDEX idx_customer_name (last_name, first_name),
    INDEX idx_registration_date (registration_date),
    INDEX idx_total_spent (total_spent)
);

-- 7. ORDERS TABLE
-- Purpose: Store order information
-- Keys: order_id (PK), customer_id (FK)
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned') DEFAULT 'Pending',
    subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    shipping_cost DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (shipping_cost >= 0),
    discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash on Delivery') NOT NULL,
    payment_status ENUM('Pending', 'Paid', 'Failed', 'Refunded') DEFAULT 'Pending',
    shipping_address TEXT NOT NULL,
    billing_address TEXT,
    notes TEXT,
    shipped_date TIMESTAMP NULL,
    delivered_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    INDEX idx_order_date (order_date),
    INDEX idx_customer (customer_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_total_amount (total_amount)
);

-- 8. ORDER_ITEMS TABLE
-- Purpose: Store individual items in each order
-- Keys: order_item_id (PK), order_id (FK), book_id (FK)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    INDEX idx_order (order_id),
    INDEX idx_book (book_id),
    INDEX idx_quantity (quantity)
);

-- 9. BOOK_REVIEWS TABLE
-- Purpose: Store customer reviews for books
-- Keys: review_id (PK), customer_id (FK), book_id (FK)
CREATE TABLE book_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    book_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_votes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_book_review (customer_id, book_id),
    INDEX idx_book_rating (book_id, rating),
    INDEX idx_customer (customer_id),
    INDEX idx_created_at (created_at)
);

-- 10. INVENTORY_TRANSACTIONS TABLE
-- Purpose: Track inventory movements
-- Keys: transaction_id (PK), book_id (FK)
CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    transaction_type ENUM('Purchase', 'Sale', 'Return', 'Adjustment', 'Damaged', 'Lost') NOT NULL,
    quantity_change INT NOT NULL,
    reference_id INT NULL, -- Links to order_id for sales, purchase_order_id for purchases
    reference_type ENUM('Order', 'Purchase Order', 'Manual', 'System') DEFAULT 'Manual',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'System',
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    INDEX idx_book_transaction (book_id, transaction_type),
    INDEX idx_transaction_date (created_at),
    INDEX idx_reference (reference_id, reference_type)
);

-- =====================================================
-- OLAP SCHEMA - DATA WAREHOUSE TABLES
-- =====================================================

-- 11. DIM_DATE TABLE
-- Purpose: Date dimension for analytics
-- Keys: date_id (PK)
CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    week_of_year INT NOT NULL,
    day_of_year INT NOT NULL,
    day_of_month INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE,
    holiday_name VARCHAR(100),
    fiscal_year INT,
    fiscal_quarter INT,
    INDEX idx_full_date (full_date),
    INDEX idx_year_month (year, month),
    INDEX idx_quarter (quarter)
);

-- 12. DIM_CUSTOMER TABLE
-- Purpose: Customer dimension for analytics
-- Keys: customer_key (PK), customer_id (FK to OLTP)
CREATE TABLE dim_customer (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    age_group VARCHAR(20), -- '18-25', '26-35', '36-45', '46-55', '55+'
    gender ENUM('M', 'F', 'Other'),
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    customer_segment VARCHAR(50), -- 'New', 'Regular', 'VIP', 'Inactive'
    registration_year INT,
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0.00,
    avg_order_value DECIMAL(10,2) DEFAULT 0.00,
    last_order_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NULL,
    INDEX idx_customer_id (customer_id),
    INDEX idx_age_group (age_group),
    INDEX idx_segment (customer_segment),
    INDEX idx_location (country, state, city)
);

-- 13. DIM_BOOK TABLE
-- Purpose: Book dimension for analytics
-- Keys: book_key (PK), book_id (FK to OLTP)
CREATE TABLE dim_book (
    book_key INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(20),
    category_name VARCHAR(100) NOT NULL,
    publisher_name VARCHAR(200) NOT NULL,
    author_names TEXT, -- Concatenated author names
    publication_year INT,
    price_range VARCHAR(20), -- 'Under $10', '$10-25', '$25-50', 'Over $50'
    language VARCHAR(50),
    pages_range VARCHAR(20), -- 'Under 200', '200-400', '400-600', 'Over 600'
    is_bestseller BOOLEAN DEFAULT FALSE,
    avg_rating DECIMAL(3,2) DEFAULT 0.00,
    total_reviews INT DEFAULT 0,
    valid_from TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP NULL,
    INDEX idx_book_id (book_id),
    INDEX idx_category (category_name),
    INDEX idx_publisher (publisher_name),
    INDEX idx_price_range (price_range),
    INDEX idx_rating (avg_rating)
);

-- 14. FACT_SALES TABLE
-- Purpose: Sales fact table for analytics
-- Keys: sales_key (PK), multiple FKs to dimensions
-- One row represents one book sale transaction
CREATE TABLE fact_sales (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    date_id INT NOT NULL,
    customer_key INT NOT NULL,
    book_key INT NOT NULL,
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    quantity_sold INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_revenue DECIMAL(10,2) NOT NULL,
    cost_of_goods DECIMAL(10,2) NOT NULL,
    profit DECIMAL(10,2) NOT NULL,
    profit_margin DECIMAL(5,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    shipping_cost DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY (book_key) REFERENCES dim_book(book_key),
    INDEX idx_date (date_id),
    INDEX idx_customer (customer_key),
    INDEX idx_book (book_key),
    INDEX idx_order (order_id),
    INDEX idx_revenue (total_revenue),
    INDEX idx_profit (profit)
);

-- =====================================================
-- ADDITIONAL SUPPORTING TABLES
-- =====================================================

-- 15. DISCOUNT_CODES TABLE
-- Purpose: Store discount/promotional codes
-- Keys: discount_id (PK)
CREATE TABLE discount_codes (
    discount_id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(200),
    discount_type ENUM('Percentage', 'Fixed Amount') NOT NULL,
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2) DEFAULT 0.00,
    max_discount_amount DECIMAL(10,2) NULL,
    usage_limit INT NULL,
    used_count INT DEFAULT 0,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code),
    INDEX idx_valid_dates (valid_from, valid_to),
    INDEX idx_active (is_active)
);

-- 16. WISHLIST TABLE
-- Purpose: Store customer wishlists
-- Keys: wishlist_id (PK), customer_id (FK), book_id (FK)
CREATE TABLE wishlist (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    book_id INT NOT NULL,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    priority ENUM('Low', 'Medium', 'High') DEFAULT 'Medium',
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    UNIQUE KEY unique_customer_book_wishlist (customer_id, book_id),
    INDEX idx_customer (customer_id),
    INDEX idx_book (book_id),
    INDEX idx_priority (priority)
);

-- =====================================================
-- TRIGGERS FOR DATA INTEGRITY
-- =====================================================

-- Trigger to update stock quantity when order is placed
DELIMITER //
CREATE TRIGGER update_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE books 
    SET stock_quantity = stock_quantity - NEW.quantity,
        updated_at = CURRENT_TIMESTAMP
    WHERE book_id = NEW.book_id;
    
    -- Insert inventory transaction record
    INSERT INTO inventory_transactions (book_id, transaction_type, quantity_change, reference_id, reference_type, notes)
    VALUES (NEW.book_id, 'Sale', -NEW.quantity, NEW.order_id, 'Order', 'Stock reduced due to sale');
END//

-- Trigger to update customer statistics
CREATE TRIGGER update_customer_stats
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'Delivered' AND OLD.status != 'Delivered' THEN
        UPDATE customers 
        SET total_orders = total_orders + 1,
            total_spent = total_spent + NEW.total_amount,
            updated_at = CURRENT_TIMESTAMP
        WHERE customer_id = NEW.customer_id;
    END IF;
END//

DELIMITER ;

-- =====================================================
-- INITIAL DATA SETUP
-- =====================================================

-- Insert basic categories
INSERT INTO categories (name, description) VALUES
('Fiction', 'Imaginative literature including novels and short stories'),
('Non-Fiction', 'Factual and informative literature'),
('Mystery', 'Detective and crime fiction'),
('Romance', 'Love stories and romantic fiction'),
('Science Fiction', 'Futuristic and speculative fiction'),
('Fantasy', 'Magical and supernatural fiction'),
('Biography', 'Life stories of real people'),
('History', 'Historical accounts and analysis'),
('Business', 'Business and management literature'),
('Self-Help', 'Personal development and improvement'),
('Poetry', 'Poetic works and collections'),
('Young Adult', 'Literature for teenagers and young adults'),
('Children', 'Books for children'),
('Cooking', 'Culinary and recipe books'),
('Travel', 'Travel guides and memoirs'),
('Health', 'Health and wellness literature'),
('Technology', 'Technical and computer science books'),
('Art', 'Art and design literature'),
('Music', 'Music theory and history'),
('Sports', 'Sports and athletics literature');

-- Insert sample publishers
INSERT INTO publishers (name, city, state, country, founded_year) VALUES
('Penguin Random House', 'New York', 'NY', 'USA', 2013),
('HarperCollins', 'New York', 'NY', 'USA', 1917),
('Simon & Schuster', 'New York', 'NY', 'USA', 1924),
('Macmillan Publishers', 'New York', 'NY', 'USA', 1943),
('Hachette Book Group', 'New York', 'NY', 'USA', 2006),
('Scholastic Corporation', 'New York', 'NY', 'USA', 1920),
('Wiley', 'Hoboken', 'NJ', 'USA', 1907),
('Oxford University Press', 'Oxford', 'England', 'UK', 1986),
('Cambridge University Press', 'Cambridge', 'England', 'UK', 1934),
('MIT Press', 'Cambridge', 'MA', 'USA', 1962);

COMMIT;
