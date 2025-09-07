-- =====================================================
-- CONCURRENCY DEMONSTRATION FOR ONLINE BOOKSTORE
-- =====================================================
-- Demonstrates SELECT FOR UPDATE, transaction isolation, and race condition prevention
-- =====================================================

USE bookstore;

-- =====================================================
-- DEMO 1: SELECT FOR UPDATE - INVENTORY RACE CONDITION
-- =====================================================
-- Business Scenario: Two customers trying to buy the last copy of a book simultaneously
-- Demonstrates: Row-level locking to prevent overselling

-- Session 1: Customer A tries to buy book_id = 1
-- Run this in one MySQL session

-- SESSION 1 - Customer A
USE bookstore;

START TRANSACTION;

-- Lock the book row for update
SELECT book_id, title, stock_quantity, price 
FROM books 
WHERE book_id = 1 
FOR UPDATE;

-- Simulate processing time
DO SLEEP(1);

-- Attempt to update stock (will fail if stock becomes 0)
UPDATE books 
SET stock_quantity = stock_quantity - 1 
WHERE book_id = 1 AND stock_quantity >= 1;

-- Check if the update affected any rows
SELECT ROW_COUNT() as rows_affected;

-- If ROW_COUNT() = 1, proceed with order creation
-- If ROW_COUNT() = 0, the book was out of stock

-- For demonstration, let's assume it succeeded and create the order
INSERT INTO orders (customer_id, subtotal, tax_amount, shipping_cost, total_amount, payment_method, shipping_address, status)
SELECT 1, 29.99, 2.40, 5.99, 38.38, 'Credit Card', '123 Main St', 'Pending'
WHERE (SELECT ROW_COUNT()) = 1;

-- Get the order ID if order was created
SET @order_id = LAST_INSERT_ID();

-- Insert order item only if order was created
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price)
SELECT @order_id, 1, 1, 29.99, 29.99
WHERE @order_id > 0;

COMMIT;

-- Check results
SELECT 
    CASE 
        WHEN @order_id > 0 THEN CONCAT('Order placed successfully. Order ID: ', @order_id)
        ELSE 'Book out of stock or order failed'
    END as result;


-- Session 2: Customer B tries to buy the same book simultaneously
-- Run this in another MySQL session/terminal (while Session 1 is running)

-- SESSION 2 - Customer B
USE bookstore;

START TRANSACTION;

-- This will wait for Session 1 to release the lock
SELECT book_id, title, stock_quantity, price 
FROM books 
WHERE book_id = 1 
FOR UPDATE;

-- Simulate processing time
DO SLEEP(1);

-- Attempt to update stock (will fail if stock becomes 0)
UPDATE books 
SET stock_quantity = stock_quantity - 1 
WHERE book_id = 1 AND stock_quantity >= 1;

-- Check if the update affected any rows
SELECT ROW_COUNT() as rows_affected;

-- If ROW_COUNT() = 1, proceed with order creation
-- If ROW_COUNT() = 0, the book was out of stock

-- For demonstration, let's assume it succeeded and create the order
INSERT INTO orders (customer_id, subtotal, tax_amount, shipping_cost, total_amount, payment_method, shipping_address, status)
SELECT 2, 29.99, 2.40, 5.99, 38.38, 'Credit Card', '456 Oak Ave', 'Pending'
WHERE (SELECT ROW_COUNT()) = 1;

-- Get the order ID if order was created
SET @order_id = LAST_INSERT_ID();

-- Insert order item only if order was created
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price)
SELECT @order_id, 1, 1, 29.99, 29.99
WHERE @order_id > 0;

COMMIT;

-- Check results
SELECT 
    CASE 
        WHEN @order_id > 0 THEN CONCAT('Order placed successfully. Order ID: ', @order_id)
        ELSE 'Book out of stock or order failed'
    END as result;


-- =====================================================
-- CLEANUP AND VERIFICATION
-- =====================================================

-- Reset data for clean demo state
UPDATE books SET stock_quantity = 10 WHERE book_id = 1;
UPDATE books SET stock_quantity = 10 WHERE book_id = 2;

-- Check current lock status
SELECT 
    r.trx_id,
    r.trx_state,
    r.trx_started,
    r.trx_requested_lock_id,
    r.trx_wait_started,
    r.trx_mysql_thread_id,
    r.trx_query
FROM information_schema.innodb_trx r;

-- Check current locks
SELECT 
    l.lock_id,
    l.lock_trx_id,
    l.lock_mode,
    l.lock_type,
    l.lock_table,
    l.lock_index,
    l.lock_space,
    l.lock_page,
    l.lock_rec,
    l.lock_data
FROM information_schema.innodb_locks l;

-- =====================================================
-- BUSINESS LOGIC EXPLANATION
-- =====================================================

/*
CONCURRENCY CONTROL IN ONLINE BOOKSTORE:

1. INVENTORY MANAGEMENT:
   - SELECT FOR UPDATE prevents overselling
   - Row-level locking ensures data consistency
   - Proper transaction boundaries prevent partial updates
*/
