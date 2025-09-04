-- =====================================================
-- PERFORMANCE OPTIMIZATION FOR ONLINE BOOKSTORE
-- =====================================================
-- Indexes, performance analysis, and optimization demonstrations
-- =====================================================

USE bookstore;

-- =====================================================
-- ADDITIONAL INDEXES FOR PERFORMANCE
-- =====================================================

-- Composite index for order analysis queries
CREATE INDEX idx_orders_customer_date_status ON orders(customer_id, order_date, status);

-- Composite index for book sales analysis
CREATE INDEX idx_order_items_book_order ON order_items(book_id, order_id);

-- Composite index for customer order history
CREATE INDEX idx_orders_customer_status_amount ON orders(customer_id, status, total_amount);

-- Composite index for inventory management
CREATE INDEX idx_books_category_stock ON books(category_id, stock_quantity);

-- Composite index for review analysis
CREATE INDEX idx_reviews_book_rating_date ON book_reviews(book_id, rating, created_at);

-- Composite index for author book relationships
CREATE INDEX idx_book_authors_author_order ON book_authors(author_id, author_order);

-- Composite index for wishlist analysis
CREATE INDEX idx_wishlist_customer_priority ON wishlist(customer_id, priority);

-- Composite index for inventory transactions
CREATE INDEX idx_inventory_book_type_date ON inventory_transactions(book_id, transaction_type, created_at);

-- Full-text index for book search
CREATE FULLTEXT INDEX idx_books_title_description ON books(title, description);

-- Full-text index for author search
CREATE FULLTEXT INDEX idx_authors_name_bio ON authors(first_name, last_name, biography);

-- Composite index for order status and order id
CREATE INDEX idx_orders_status_order_id ON orders(status, order_id);

-- Composite index for order items book quantity and price
CREATE INDEX idx_order_items_book_quantity_price ON order_items(book_id, quantity, total_price);

-- Composite index for book reviews book rating
CREATE INDEX idx_book_reviews_book_rating ON book_reviews(book_id, rating);


-- Composite index for order items book order id quantity and price
CREATE INDEX idx_order_items_book_covering ON order_items(book_id, order_id, quantity, total_price);

-- Composite index for books stock quantity book id title category id
CREATE INDEX idx_books_covering ON books(stock_quantity, book_id, title, category_id);

-- Composite index for categories category id
CREATE INDEX idx_categories_id ON categories(category_id);

-- =====================================================
-- PERFORMANCE ANALYSIS QUERIES
-- =====================================================

-- Query 1: Customer Order History Analysis
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status IN ('Delivered', 'Shipped', 'Processing')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Query 2: Book Sales Performance Analysis
SELECT 
    b.book_id,
    b.title,
    c.name as category,
    COUNT(oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(br.rating) as avg_rating
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status IN ('Delivered', 'Shipped')
LEFT JOIN book_reviews br ON b.book_id = br.book_id
WHERE b.stock_quantity > 0
GROUP BY b.book_id, b.title, c.name
HAVING total_sales > 0
ORDER BY total_revenue DESC
LIMIT 1000;

-- Query 3: Monthly Sales Trend Analysis
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(oi.total_price) as total_revenue,
    ROUND(AVG(oi.total_price), 2) as avg_order_value
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('Delivered', 'Shipped', 'Processing')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 36 MONTH)
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- =====================================================
-- EXPLAIN ANALYSIS DEMONSTRATIONS
-- =====================================================

-- Run EXPLAIN on the customer order history query
EXPLAIN FORMAT=JSON
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status IN ('Delivered', 'Shipped', 'Processing')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- =====================================================
-- QUERY OPTIMIZATION TECHNIQUES
-- =====================================================

-- Optimized Query 1: Using covering index
-- This query uses the composite index idx_orders_customer_date_status
SELECT 
    o.customer_id,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value
FROM orders o
WHERE o.status IN ('Delivered', 'Shipped', 'Processing')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 24 MONTH)
GROUP BY o.customer_id
HAVING total_orders >= 3
ORDER BY total_spent DESC;

-- Optimized Query 2: Using proper index for book search
-- This query uses the full-text index for book search
SELECT 
    b.book_id,
    b.title,
    c.name as category,
    b.price,
    MATCH(b.title, b.description) AGAINST('fiction mystery' IN NATURAL LANGUAGE MODE) as relevance_score
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
WHERE MATCH(b.title, b.description) AGAINST('fiction mystery' IN NATURAL LANGUAGE MODE)
    AND b.stock_quantity > 0
ORDER BY relevance_score DESC;

-- Optimized Query 3: Using covering index for inventory analysis
SELECT 
    b.book_id,
    b.title,
    b.stock_quantity,
    b.min_stock_level,
    COUNT(oi.order_item_id) as recent_sales
FROM books b
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    AND o.status IN ('Delivered', 'Shipped')
WHERE b.stock_quantity <= b.min_stock_level
GROUP BY b.book_id, b.title, b.stock_quantity, b.min_stock_level
ORDER BY recent_sales DESC;

-- =====================================================
-- PERFORMANCE MONITORING QUERIES
-- =====================================================

-- Query to check index usage
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED,
    NULLABLE,
    INDEX_TYPE
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'bookstore'
    AND TABLE_NAME IN ('orders', 'order_items', 'books', 'customers')
ORDER BY TABLE_NAME, INDEX_NAME;

-- Query to check table sizes
SELECT 
    TABLE_NAME,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Size (MB)',
    TABLE_ROWS
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'bookstore'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- Query to check slow query log (if enabled)
-- Note: This requires slow query log to be enabled
-- SHOW VARIABLES LIKE 'slow_query_log';
-- SHOW VARIABLES LIKE 'long_query_time';