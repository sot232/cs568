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

-- =====================================================
-- PERFORMANCE ANALYSIS QUERIES
-- =====================================================

-- Query 1: Customer Order History Analysis
-- This query will be used to demonstrate index effectiveness
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status IN ('Delivered', 'Shipped')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_orders >= 3
ORDER BY total_spent DESC
LIMIT 20;

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
LIMIT 15;

-- Query 3: Monthly Sales Trend Analysis
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(oi.total_price) as total_revenue,
    ROUND(AVG(oi.total_price), 2) as avg_order_value
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('Delivered', 'Shipped')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- =====================================================
-- EXPLAIN ANALYSIS DEMONSTRATIONS
-- =====================================================

-- Before optimization analysis
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
WHERE o.status IN ('Delivered', 'Shipped')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_orders >= 3
ORDER BY total_spent DESC
LIMIT 20;

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
WHERE o.status IN ('Delivered', 'Shipped')
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY o.customer_id
HAVING total_orders >= 3
ORDER BY total_spent DESC
LIMIT 20;

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
ORDER BY relevance_score DESC
LIMIT 10;

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
-- PARTITIONING STRATEGY (CONCEPTUAL)
-- =====================================================

-- Note: MySQL partitioning requires specific table structure
-- This is a conceptual example of how partitioning could be implemented

-- Example: Partition orders table by date (conceptual)
/*
CREATE TABLE orders_partitioned (
    order_id INT AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned') DEFAULT 'Pending',
    total_amount DECIMAL(10,2) NOT NULL,
    -- other columns...
    PRIMARY KEY (order_id, order_date)
) PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
*/

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

-- =====================================================
-- QUERY CACHING AND OPTIMIZATION
-- =====================================================

-- Enable query cache (if available in MySQL version)
-- SET GLOBAL query_cache_size = 268435456; -- 256MB
-- SET GLOBAL query_cache_type = ON;

-- Check query cache status
SHOW STATUS LIKE 'Qcache%';

-- =====================================================
-- STORED PROCEDURE FOR PERFORMANCE TESTING
-- =====================================================

DELIMITER //
CREATE PROCEDURE sp_performance_test(
    IN p_test_type VARCHAR(50),
    OUT p_execution_time DECIMAL(10,4),
    OUT p_rows_affected INT
)
BEGIN
    DECLARE v_start_time DECIMAL(20,6);
    DECLARE v_end_time DECIMAL(20,6);
    DECLARE v_row_count INT DEFAULT 0;
    
    -- Get start time
    SET v_start_time = UNIX_TIMESTAMP(NOW(6));
    
    -- Execute different test queries based on test type
    IF p_test_type = 'customer_analysis' THEN
        SELECT COUNT(*) INTO v_row_count
        FROM customers c
        INNER JOIN orders o ON c.customer_id = o.customer_id
        WHERE o.status IN ('Delivered', 'Shipped')
            AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH);
            
    ELSEIF p_test_type = 'book_sales' THEN
        SELECT COUNT(*) INTO v_row_count
        FROM books b
        INNER JOIN order_items oi ON b.book_id = oi.book_id
        INNER JOIN orders o ON oi.order_id = o.order_id
        WHERE o.status IN ('Delivered', 'Shipped')
            AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH);
            
    ELSEIF p_test_type = 'inventory_check' THEN
        SELECT COUNT(*) INTO v_row_count
        FROM books b
        WHERE b.stock_quantity <= b.min_stock_level;
        
    ELSE
        SET v_row_count = 0;
    END IF;
    
    -- Get end time
    SET v_end_time = UNIX_TIMESTAMP(NOW(6));
    
    -- Calculate execution time
    SET p_execution_time = v_end_time - v_start_time;
    SET p_rows_affected = v_row_count;
    
END//
DELIMITER ;

-- =====================================================
-- PERFORMANCE TESTING EXAMPLES
-- =====================================================

-- Test customer analysis performance
CALL sp_performance_test('customer_analysis', @exec_time, @row_count);
SELECT @exec_time as execution_time_seconds, @row_count as rows_processed;

-- Test book sales performance
CALL sp_performance_test('book_sales', @exec_time, @row_count);
SELECT @exec_time as execution_time_seconds, @row_count as rows_processed;

-- Test inventory check performance
CALL sp_performance_test('inventory_check', @exec_time, @row_count);
SELECT @exec_time as execution_time_seconds, @row_count as rows_processed;

-- =====================================================
-- INDEX MAINTENANCE
-- =====================================================

-- Analyze tables to update statistics
ANALYZE TABLE customers, orders, order_items, books, book_reviews, authors, publishers, categories;

-- Check for unused indexes (conceptual - requires monitoring over time)
-- This would typically be done through performance monitoring tools

-- =====================================================
-- CONCURRENCY AND LOCKING DEMONSTRATION
-- =====================================================

-- Example of using SELECT ... FOR UPDATE for inventory management
-- This prevents race conditions when multiple users try to purchase the same book

-- Session 1: Check and reserve inventory
START TRANSACTION;
SELECT stock_quantity FROM books WHERE book_id = 1 FOR UPDATE;

-- Session 2: This would wait for Session 1 to complete
-- START TRANSACTION;
-- SELECT stock_quantity FROM books WHERE book_id = 1 FOR UPDATE;

-- Session 1: Update inventory and commit
UPDATE books SET stock_quantity = stock_quantity - 1 WHERE book_id = 1;
COMMIT;

-- Session 2: Now this can proceed
-- SELECT stock_quantity FROM books WHERE book_id = 1 FOR UPDATE;
-- UPDATE books SET stock_quantity = stock_quantity - 1 WHERE book_id = 1;
-- COMMIT;

-- =====================================================
-- PERFORMANCE RECOMMENDATIONS
-- =====================================================

/*
PERFORMANCE OPTIMIZATION RECOMMENDATIONS:

1. INDEXING STRATEGY:
   - Use composite indexes for frequently queried column combinations
   - Implement covering indexes to avoid table lookups
   - Use full-text indexes for search functionality
   - Regularly analyze and maintain index statistics

2. QUERY OPTIMIZATION:
   - Use EXPLAIN to analyze query execution plans
   - Avoid SELECT * in production queries
   - Use appropriate JOIN types (INNER vs LEFT)
   - Implement proper WHERE clause filtering

3. SCHEMA OPTIMIZATION:
   - Use appropriate data types (avoid VARCHAR(255) for small data)
   - Implement proper normalization (3NF)
   - Consider denormalization for read-heavy operations
   - Use partitioning for large tables

4. CACHING STRATEGY:
   - Enable query cache for frequently executed queries
   - Implement application-level caching
   - Use materialized views for complex aggregations
   - Consider read replicas for reporting queries

5. MONITORING:
   - Monitor slow query log
   - Track index usage statistics
   - Monitor table sizes and growth
   - Implement performance testing procedures

6. CONCURRENCY:
   - Use appropriate transaction isolation levels
   - Implement proper locking strategies
   - Avoid long-running transactions
   - Use SELECT ... FOR UPDATE for inventory management
*/
