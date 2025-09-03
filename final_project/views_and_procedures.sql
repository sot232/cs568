-- =====================================================
-- VIEWS AND STORED PROCEDURES FOR ONLINE BOOKSTORE
-- =====================================================
-- Regular views and stored procedures with transaction handling
-- =====================================================

USE bookstore;

-- =====================================================
-- REGULAR VIEWS
-- =====================================================

-- VIEW 1: CUSTOMER ORDER SUMMARY VIEW
-- Purpose: Simplify customer order analysis for reporting
CREATE OR REPLACE VIEW v_customer_order_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.registration_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE 0 END) as total_spent,
    AVG(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE NULL END) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) as days_since_last_order,
    COUNT(DISTINCT br.review_id) as total_reviews,
    AVG(br.rating) as avg_review_rating
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN book_reviews br ON c.customer_id = br.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.registration_date;

-- VIEW 2: BOOK SALES PERFORMANCE VIEW
-- Purpose: Comprehensive book performance metrics for inventory management
CREATE OR REPLACE VIEW v_book_sales_performance AS
SELECT 
    b.book_id,
    b.title,
    c.name as category,
    p.name as publisher,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') as authors,
    b.price,
    b.cost,
    ROUND((b.price - b.cost) / b.price * 100, 2) as profit_margin,
    b.stock_quantity,
    b.min_stock_level,
    COUNT(DISTINCT oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(br.rating) as avg_rating,
    COUNT(br.review_id) as review_count,
    CASE 
        WHEN b.stock_quantity = 0 THEN 'OUT OF STOCK'
        WHEN b.stock_quantity <= b.min_stock_level THEN 'LOW STOCK'
        WHEN b.stock_quantity <= (b.min_stock_level * 2) THEN 'MEDIUM STOCK'
        ELSE 'GOOD STOCK'
    END as stock_status
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN book_authors ba ON b.book_id = ba.book_id
LEFT JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status IN ('Delivered', 'Shipped')
LEFT JOIN book_reviews br ON b.book_id = br.book_id
GROUP BY b.book_id, b.title, c.name, p.name, b.price, b.cost, b.stock_quantity, b.min_stock_level;

-- VIEW 3: MONTHLY SALES DASHBOARD VIEW
-- Purpose: Monthly sales metrics for executive reporting
CREATE OR REPLACE VIEW v_monthly_sales_dashboard AS
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
    YEAR(o.order_date) as sales_year,
    MONTH(o.order_date) as sales_month_num,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    COUNT(oi.order_item_id) as total_items_sold,
    SUM(oi.total_price) as total_revenue,
    ROUND(AVG(oi.total_price), 2) as avg_order_value,
    ROUND(SUM(oi.total_price) / COUNT(DISTINCT o.customer_id), 2) as revenue_per_customer,
    COUNT(DISTINCT CASE WHEN o.status = 'Delivered' THEN o.order_id END) as delivered_orders,
    COUNT(DISTINCT CASE WHEN o.status = 'Cancelled' THEN o.order_id END) as cancelled_orders,
    ROUND((COUNT(DISTINCT CASE WHEN o.status = 'Delivered' THEN o.order_id END) / 
           COUNT(DISTINCT o.order_id)) * 100, 2) as delivery_success_rate
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m'), YEAR(o.order_date), MONTH(o.order_date)
ORDER BY sales_month;

-- VIEW 4: TOP CUSTOMERS VIEW
-- Purpose: Identify high-value customers for VIP programs
CREATE OR REPLACE VIEW v_top_customers AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.city,
    c.state,
    c.registration_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE 0 END) as total_spent,
    AVG(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE NULL END) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    COUNT(DISTINCT br.review_id) as total_reviews,
    AVG(br.rating) as avg_review_rating,
    COUNT(DISTINCT w.wishlist_id) as wishlist_items,
    CASE 
        WHEN SUM(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE 0 END) >= 1000 THEN 'VIP'
        WHEN SUM(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE 0 END) >= 500 THEN 'Premium'
        WHEN SUM(CASE WHEN o.status = 'Delivered' THEN o.total_amount ELSE 0 END) >= 200 THEN 'Regular'
        ELSE 'Standard'
    END as customer_tier
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN book_reviews br ON c.customer_id = br.customer_id
LEFT JOIN wishlist w ON c.customer_id = w.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city, c.state, c.registration_date
HAVING total_orders > 0
ORDER BY total_spent DESC;

-- =====================================================
-- STORED PROCEDURES WITH TRANSACTION HANDLING
-- =====================================================

-- PROCEDURE 1: PLACE ORDER WITH INVENTORY CHECK
-- Purpose: Handle order placement with proper inventory validation and transaction management
DELIMITER //
CREATE PROCEDURE sp_place_order(
    IN p_customer_id INT,
    IN p_book_id INT,
    IN p_quantity INT,
    IN p_shipping_address TEXT,
    IN p_payment_method VARCHAR(50),
    OUT p_order_id INT,
    OUT p_status VARCHAR(100),
    OUT p_message TEXT
)
BEGIN
    DECLARE v_current_stock INT DEFAULT 0;
    DECLARE v_book_price DECIMAL(10,2) DEFAULT 0;
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tax_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_shipping_cost DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_amount DECIMAL(10,2) DEFAULT 0;
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error_occurred = TRUE;
        ROLLBACK;
        SET p_status = 'ERROR';
        SET p_message = 'An error occurred during order processing';
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Check if customer exists
    IF NOT EXISTS (SELECT 1 FROM customers WHERE customer_id = p_customer_id) THEN
        SET p_status = 'ERROR';
        SET p_message = 'Customer not found';
        ROLLBACK;
    ELSE
        -- Get current stock and price
        SELECT stock_quantity, price INTO v_current_stock, v_book_price
        FROM books 
        WHERE book_id = p_book_id;
        
        -- Check if book exists
        IF v_book_price = 0 THEN
            SET p_status = 'ERROR';
            SET p_message = 'Book not found';
            ROLLBACK;
        ELSEIF v_current_stock < p_quantity THEN
            SET p_status = 'ERROR';
            SET p_message = CONCAT('Insufficient stock. Available: ', v_current_stock, ', Requested: ', p_quantity);
            ROLLBACK;
        ELSE
            -- Calculate order amounts
            SET v_subtotal = v_book_price * p_quantity;
            SET v_tax_amount = ROUND(v_subtotal * 0.08, 2); -- 8% tax
            SET v_shipping_cost = CASE WHEN v_subtotal >= 50 THEN 0 ELSE 5.99 END;
            SET v_total_amount = v_subtotal + v_tax_amount + v_shipping_cost;
            
            -- Create order
            INSERT INTO orders (
                customer_id, subtotal, tax_amount, shipping_cost, total_amount,
                payment_method, shipping_address, status
            ) VALUES (
                p_customer_id, v_subtotal, v_tax_amount, v_shipping_cost, v_total_amount,
                p_payment_method, p_shipping_address, 'Pending'
            );
            
            SET p_order_id = LAST_INSERT_ID();
            
            -- Create order item
            INSERT INTO order_items (
                order_id, book_id, quantity, unit_price, total_price
            ) VALUES (
                p_order_id, p_book_id, p_quantity, v_book_price, v_subtotal
            );
            
            -- Update stock (this will trigger the stock update trigger)
            UPDATE books 
            SET stock_quantity = stock_quantity - p_quantity
            WHERE book_id = p_book_id;
            
            -- Insert inventory transaction
            INSERT INTO inventory_transactions (
                book_id, transaction_type, quantity_change, reference_id, reference_type, notes
            ) VALUES (
                p_book_id, 'Sale', -p_quantity, p_order_id, 'Order', 'Stock reduced due to sale'
            );
            
            IF v_error_occurred = FALSE THEN
                COMMIT;
                SET p_status = 'SUCCESS';
                SET p_message = CONCAT('Order placed successfully. Order ID: ', p_order_id, ', Total: $', v_total_amount);
            END IF;
        END IF;
    END IF;
END//
DELIMITER ;

-- PROCEDURE 2: PROCESS ORDER FULFILLMENT
-- Purpose: Handle order status updates with proper validation
DELIMITER //
CREATE PROCEDURE sp_process_order_fulfillment(
    IN p_order_id INT,
    IN p_new_status VARCHAR(50),
    IN p_processed_by VARCHAR(100),
    OUT p_status VARCHAR(100),
    OUT p_message TEXT
)
BEGIN
    DECLARE v_current_status VARCHAR(50);
    DECLARE v_customer_id INT;
    DECLARE v_total_amount DECIMAL(10,2);
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error_occurred = TRUE;
        ROLLBACK;
        SET p_status = 'ERROR';
        SET p_message = 'An error occurred during order processing';
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get current order information
    SELECT status, customer_id, total_amount 
    INTO v_current_status, v_customer_id, v_total_amount
    FROM orders 
    WHERE order_id = p_order_id;
    
    -- Check if order exists
    IF v_current_status IS NULL THEN
        SET p_status = 'ERROR';
        SET p_message = 'Order not found';
        ROLLBACK;
    ELSE
        -- Validate status transition
        IF (v_current_status = 'Pending' AND p_new_status IN ('Processing', 'Cancelled')) OR
           (v_current_status = 'Processing' AND p_new_status IN ('Shipped', 'Cancelled')) OR
           (v_current_status = 'Shipped' AND p_new_status IN ('Delivered', 'Returned')) OR
           (v_current_status = 'Delivered' AND p_new_status = 'Returned') OR
           (v_current_status = 'Cancelled' AND p_new_status = 'Pending') THEN
            
            -- Update order status
            UPDATE orders 
            SET status = p_new_status,
                updated_at = CURRENT_TIMESTAMP
            WHERE order_id = p_order_id;
            
            -- Handle specific status updates
            IF p_new_status = 'Shipped' THEN
                UPDATE orders 
                SET shipped_date = CURRENT_TIMESTAMP
                WHERE order_id = p_order_id;
            ELSEIF p_new_status = 'Delivered' THEN
                UPDATE orders 
                SET delivered_date = CURRENT_TIMESTAMP
                WHERE order_id = p_order_id;
            ELSEIF p_new_status = 'Cancelled' THEN
                -- Restore stock for cancelled orders
                UPDATE books b
                INNER JOIN order_items oi ON b.book_id = oi.book_id
                SET b.stock_quantity = b.stock_quantity + oi.quantity
                WHERE oi.order_id = p_order_id;
                
                -- Insert inventory transaction for stock restoration
                INSERT INTO inventory_transactions (
                    book_id, transaction_type, quantity_change, reference_id, reference_type, notes, created_by
                )
                SELECT 
                    oi.book_id, 'Return', oi.quantity, p_order_id, 'Order', 
                    'Stock restored due to order cancellation', p_processed_by
                FROM order_items oi
                WHERE oi.order_id = p_order_id;
            END IF;
            
            IF v_error_occurred = FALSE THEN
                COMMIT;
                SET p_status = 'SUCCESS';
                SET p_message = CONCAT('Order status updated to: ', p_new_status);
            END IF;
        ELSE
            SET p_status = 'ERROR';
            SET p_message = CONCAT('Invalid status transition from ', v_current_status, ' to ', p_new_status);
            ROLLBACK;
        END IF;
    END IF;
END//
DELIMITER ;

-- PROCEDURE 3: INVENTORY RESTOCK PROCEDURE
-- Purpose: Handle inventory restocking with proper validation
DELIMITER //
CREATE PROCEDURE sp_restock_inventory(
    IN p_book_id INT,
    IN p_quantity INT,
    IN p_cost_per_unit DECIMAL(10,2),
    IN p_restocked_by VARCHAR(100),
    OUT p_status VARCHAR(100),
    OUT p_message TEXT
)
BEGIN
    DECLARE v_current_stock INT DEFAULT 0;
    DECLARE v_book_title VARCHAR(500);
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error_occurred = TRUE;
        ROLLBACK;
        SET p_status = 'ERROR';
        SET p_message = 'An error occurred during restocking';
    END;
    
    -- Start transaction
    START TRANSACTION;
    
    -- Get current book information
    SELECT stock_quantity, title INTO v_current_stock, v_book_title
    FROM books 
    WHERE book_id = p_book_id;
    
    -- Check if book exists
    IF v_book_title IS NULL THEN
        SET p_status = 'ERROR';
        SET p_message = 'Book not found';
        ROLLBACK;
    ELSEIF p_quantity <= 0 THEN
        SET p_status = 'ERROR';
        SET p_message = 'Restock quantity must be greater than 0';
        ROLLBACK;
    ELSEIF p_cost_per_unit <= 0 THEN
        SET p_status = 'ERROR';
        SET p_message = 'Cost per unit must be greater than 0';
        ROLLBACK;
    ELSE
        -- Update book stock and cost
        UPDATE books 
        SET stock_quantity = stock_quantity + p_quantity,
            cost = p_cost_per_unit,
            updated_at = CURRENT_TIMESTAMP
        WHERE book_id = p_book_id;
        
        -- Insert inventory transaction
        INSERT INTO inventory_transactions (
            book_id, transaction_type, quantity_change, reference_type, notes, created_by
        ) VALUES (
            p_book_id, 'Purchase', p_quantity, 'Manual', 
            CONCAT('Restocked ', p_quantity, ' units at $', p_cost_per_unit, ' per unit'), 
            p_restocked_by
        );
        
        IF v_error_occurred = FALSE THEN
            COMMIT;
            SET p_status = 'SUCCESS';
            SET p_message = CONCAT('Successfully restocked ', p_quantity, ' units of "', v_book_title, '"');
        END IF;
    END IF;
END//
DELIMITER ;

-- PROCEDURE 4: CUSTOMER ANALYTICS PROCEDURE
-- Purpose: Generate comprehensive customer analytics
DELIMITER //
CREATE PROCEDURE sp_generate_customer_analytics(
    IN p_customer_id INT,
    OUT p_status VARCHAR(100),
    OUT p_message TEXT
)
BEGIN
    DECLARE v_customer_exists BOOLEAN DEFAULT FALSE;
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error_occurred = TRUE;
        SET p_status = 'ERROR';
        SET p_message = 'An error occurred during analytics generation';
    END;
    
    -- Check if customer exists
    SELECT EXISTS(SELECT 1 FROM customers WHERE customer_id = p_customer_id) INTO v_customer_exists;
    
    IF NOT v_customer_exists THEN
        SET p_status = 'ERROR';
        SET p_message = 'Customer not found';
    ELSE
        -- This procedure would typically generate and store analytics
        -- For demonstration, we'll just return success
        SET p_status = 'SUCCESS';
        SET p_message = 'Customer analytics generated successfully';
    END IF;
END//
DELIMITER ;

-- =====================================================
-- MATERIALIZED VIEW SIMULATION
-- =====================================================

-- Create a table to simulate materialized view
CREATE TABLE IF NOT EXISTS mv_monthly_sales_summary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    sales_month VARCHAR(7) NOT NULL,
    total_orders INT NOT NULL,
    total_revenue DECIMAL(12,2) NOT NULL,
    total_customers INT NOT NULL,
    avg_order_value DECIMAL(10,2) NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_month (sales_month)
);

-- Stored procedure to refresh materialized view
DELIMITER //
CREATE PROCEDURE sp_refresh_monthly_sales_summary()
BEGIN
    DECLARE v_error_occurred BOOLEAN DEFAULT FALSE;
    
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET v_error_occurred = TRUE;
        ROLLBACK;
    END;
    
    START TRANSACTION;
    
    -- Clear existing data
    TRUNCATE TABLE mv_monthly_sales_summary;
    
    -- Insert fresh data
    INSERT INTO mv_monthly_sales_summary (sales_month, total_orders, total_revenue, total_customers, avg_order_value)
    SELECT 
        DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(oi.total_price) as total_revenue,
        COUNT(DISTINCT o.customer_id) as total_customers,
        ROUND(AVG(oi.total_price), 2) as avg_order_value
    FROM orders o
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status IN ('Delivered', 'Shipped')
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
    ORDER BY sales_month;
    
    IF v_error_occurred = FALSE THEN
        COMMIT;
    ELSE
        ROLLBACK;
    END IF;
END//
DELIMITER ;

-- =====================================================
-- EVENT SCHEDULER FOR MATERIALIZED VIEW REFRESH
-- =====================================================

-- Create event to refresh materialized view daily at 2 AM
CREATE EVENT IF NOT EXISTS ev_refresh_monthly_sales_summary
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURDATE() + INTERVAL 1 DAY, '02:00:00')
DO
  CALL sp_refresh_monthly_sales_summary();

-- Enable event scheduler
SET GLOBAL event_scheduler = ON;

-- =====================================================
-- USAGE EXAMPLES AND TESTING
-- =====================================================

-- Example usage of views:
-- SELECT * FROM v_customer_order_summary WHERE total_spent > 500;
-- SELECT * FROM v_book_sales_performance WHERE stock_status = 'LOW STOCK';
-- SELECT * FROM v_monthly_sales_dashboard ORDER BY sales_month DESC LIMIT 6;

-- Example usage of stored procedures:
-- CALL sp_place_order(1, 1, 2, '123 Main St, City, State 12345', 'Credit Card', @order_id, @status, @message);
-- SELECT @order_id, @status, @message;

-- CALL sp_process_order_fulfillment(1, 'Processing', 'admin', @status, @message);
-- SELECT @status, @message;

-- CALL sp_restock_inventory(1, 50, 15.99, 'admin', @status, @message);
-- SELECT @status, @message;

-- CALL sp_refresh_monthly_sales_summary();
-- SELECT * FROM mv_monthly_sales_summary ORDER BY sales_month DESC;
