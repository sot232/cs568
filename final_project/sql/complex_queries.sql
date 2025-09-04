-- =====================================================
-- COMPLEX QUERIES FOR ONLINE BOOKSTORE MANAGEMENT
-- =====================================================
-- 10+ complex queries demonstrating JOINs, aggregations, subqueries, and CTEs
-- =====================================================

USE bookstore;

-- =====================================================
-- QUERY 1: TOP-SELLING BOOKS WITH AUTHOR INFORMATION
-- =====================================================
-- Business Purpose: Identify best-selling books to optimize inventory and marketing
-- Demonstrates: Multi-table JOINs, aggregations, ORDER BY
SELECT 
    b.title,
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') as authors,
    c.name as category,
    p.name as publisher,
    COUNT(oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(br.rating) as avg_rating,
    COUNT(br.review_id) as review_count
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN book_reviews br ON b.book_id = br.book_id
GROUP BY b.book_id, b.title, c.name, p.name
HAVING total_sales > 0
ORDER BY total_quantity_sold DESC, total_revenue DESC
LIMIT 20;

-- =====================================================
-- QUERY 2: CUSTOMER PURCHASE ANALYSIS WITH CTE
-- =====================================================
-- Business Purpose: Analyze customer behavior and identify high-value customers
-- Demonstrates: CTE, window functions, CASE statements
WITH customer_purchase_stats AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) as customer_name,
        c.email,
        COUNT(DISTINCT o.order_id) as total_orders,
        SUM(o.total_amount) as total_spent,
        AVG(o.total_amount) as avg_order_value,
        MAX(o.order_date) as last_order_date,
        DATEDIFF(CURDATE(), MAX(o.order_date)) as days_since_last_order
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email
),
customer_segments AS (
    SELECT 
        *,
        CASE 
            WHEN total_spent >= 1000 THEN 'VIP'
            WHEN total_spent >= 500 THEN 'Premium'
            WHEN total_spent >= 200 THEN 'Regular'
            WHEN total_spent > 0 THEN 'New'
            ELSE 'Inactive'
        END as customer_segment,
        CASE 
            WHEN days_since_last_order <= 30 THEN 'Active'
            WHEN days_since_last_order <= 90 THEN 'At Risk'
            WHEN days_since_last_order <= 180 THEN 'Inactive'
            ELSE 'Lost'
        END as activity_status
    FROM customer_purchase_stats
)
SELECT 
    customer_segment,
    activity_status,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent), 2) as avg_total_spent,
    ROUND(AVG(total_orders), 1) as avg_orders,
    ROUND(AVG(avg_order_value), 2) as avg_order_value
FROM customer_segments
GROUP BY customer_segment, activity_status
ORDER BY customer_segment, activity_status;

-- =====================================================
-- QUERY 3: MONTHLY SALES TREND WITH ROLLING AVERAGES
-- =====================================================
-- Business Purpose: Track sales performance and identify trends
-- Demonstrates: Date functions, window functions, aggregations
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') as sales_month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(oi.order_item_id) as total_items_sold,
    SUM(oi.total_price) as monthly_revenue,
    ROUND(AVG(oi.total_price), 2) as avg_order_value,
    ROUND(AVG(SUM(oi.total_price)) OVER (
        ORDER BY DATE_FORMAT(o.order_date, '%Y-%m') 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as three_month_rolling_avg
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('Delivered', 'Shipped')
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;

-- =====================================================
-- QUERY 4: CATEGORY PERFORMANCE ANALYSIS
-- =====================================================
-- Business Purpose: Analyze which book categories generate most revenue
-- Demonstrates: Complex JOINs, subqueries, aggregations
SELECT 
    c.name as category,
    COUNT(DISTINCT b.book_id) as total_books,
    COUNT(DISTINCT oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    ROUND(AVG(b.price), 2) as avg_book_price,
    ROUND(SUM(oi.total_price) / COUNT(DISTINCT b.book_id), 2) as revenue_per_book,
    ROUND((SUM(oi.total_price) / (SELECT SUM(total_price) FROM order_items)) * 100, 2) as revenue_percentage
FROM categories c
LEFT JOIN books b ON c.category_id = b.category_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status IN ('Delivered', 'Shipped')
GROUP BY c.category_id, c.name
ORDER BY total_revenue DESC;

-- =====================================================
-- QUERY 5: AUTHOR PERFORMANCE WITH SUBQUERY
-- =====================================================
-- Business Purpose: Identify top-performing authors for contract negotiations
-- Demonstrates: Subqueries, complex aggregations, string functions
SELECT 
    a.author_id,
    CONCAT(a.first_name, ' ', a.last_name) as author_name,
    a.nationality,
    COUNT(DISTINCT ba.book_id) as books_published,
    COUNT(DISTINCT oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_books_sold,
    SUM(oi.total_price) as total_revenue,
    ROUND(AVG(br.rating), 2) as avg_rating,
    ROUND(SUM(oi.total_price) / COUNT(DISTINCT ba.book_id), 2) as revenue_per_book,
    ROUND((SUM(oi.total_price) / (SELECT SUM(total_price) FROM order_items)) * 100, 2) as market_share
FROM authors a
INNER JOIN book_authors ba ON a.author_id = ba.author_id
INNER JOIN books b ON ba.book_id = b.book_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status IN ('Delivered', 'Shipped')
LEFT JOIN book_reviews br ON b.book_id = br.book_id
GROUP BY a.author_id, a.first_name, a.last_name, a.nationality
HAVING total_sales > 0
ORDER BY total_revenue DESC, avg_rating DESC
LIMIT 15;

-- =====================================================
-- QUERY 6: INVENTORY ANALYSIS WITH STOCK ALERTS
-- =====================================================
-- Business Purpose: Monitor inventory levels and identify restocking needs
-- Demonstrates: CASE statements, aggregations, complex WHERE conditions
SELECT 
    b.title,
    c.name as category,
    p.name as publisher,
    b.stock_quantity,
    b.min_stock_level,
    b.price,
    b.cost,
    ROUND((b.price - b.cost) / b.price * 100, 2) as profit_margin,
    COUNT(oi.order_item_id) as recent_sales,
    SUM(oi.quantity) as recent_quantity_sold,
    CASE 
        WHEN b.stock_quantity = 0 THEN 'OUT OF STOCK'
        WHEN b.stock_quantity <= b.min_stock_level THEN 'LOW STOCK'
        WHEN b.stock_quantity <= (b.min_stock_level * 2) THEN 'MEDIUM STOCK'
        ELSE 'GOOD STOCK'
    END as stock_status,
    CASE 
        WHEN b.stock_quantity = 0 THEN 'URGENT - Restock immediately'
        WHEN b.stock_quantity <= b.min_stock_level THEN 'HIGH - Consider restocking'
        WHEN b.stock_quantity <= (b.min_stock_level * 2) THEN 'MEDIUM - Monitor closely'
        ELSE 'LOW - Stock is adequate'
    END as action_required
FROM books b
INNER JOIN categories c ON b.category_id = c.category_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.order_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    AND o.status IN ('Delivered', 'Shipped')
GROUP BY b.book_id, b.title, c.name, p.name, b.stock_quantity, b.min_stock_level, b.price, b.cost
ORDER BY 
    CASE 
        WHEN b.stock_quantity = 0 THEN 1
        WHEN b.stock_quantity <= b.min_stock_level THEN 2
        WHEN b.stock_quantity <= (b.min_stock_level * 2) THEN 3
        ELSE 4
    END,
    recent_quantity_sold DESC;

-- =====================================================
-- QUERY 7: CUSTOMER LIFETIME VALUE ANALYSIS
-- =====================================================
-- Business Purpose: Calculate customer lifetime value for marketing decisions
-- Demonstrates: Complex aggregations, date calculations, mathematical functions
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email,
    c.registration_date,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_spent,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    DATEDIFF(CURDATE(), c.registration_date) as customer_age_days,
    ROUND(DATEDIFF(CURDATE(), c.registration_date) / 365.25, 2) as customer_age_years,
    ROUND(SUM(o.total_amount) / (DATEDIFF(CURDATE(), c.registration_date) / 365.25), 2) as annual_spending,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT o.order_id), 2) as avg_order_value_corrected,
    CASE 
        WHEN DATEDIFF(CURDATE(), c.registration_date) > 0 
        THEN ROUND(SUM(o.total_amount) / (DATEDIFF(CURDATE(), c.registration_date) / 30), 2)
        ELSE 0
    END as monthly_spending,
    ROUND((SUM(o.total_amount) - (COUNT(DISTINCT o.order_id) * 5)) / COUNT(DISTINCT o.order_id), 2) as profit_per_order
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.status IN ('Delivered', 'Shipped')
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.registration_date
HAVING total_orders > 0
ORDER BY total_spent DESC, annual_spending DESC
LIMIT 25;

-- =====================================================
-- QUERY 8: SEASONAL SALES PATTERN ANALYSIS
-- =====================================================
-- Business Purpose: Identify seasonal trends for inventory planning
-- Demonstrates: Date functions, CASE statements, aggregations
SELECT 
    CASE 
        WHEN MONTH(o.order_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(o.order_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(o.order_date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END as season,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(oi.order_item_id) as total_items_sold,
    SUM(oi.total_price) as seasonal_revenue,
    ROUND(AVG(oi.total_price), 2) as avg_order_value,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    ROUND(SUM(oi.total_price) / COUNT(DISTINCT o.customer_id), 2) as revenue_per_customer
FROM orders o
INNER JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status IN ('Delivered', 'Shipped')
GROUP BY 
    CASE 
        WHEN MONTH(o.order_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(o.order_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(o.order_date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END
ORDER BY 
    CASE 
        WHEN MONTH(o.order_date) IN (12, 1, 2) THEN 1
        WHEN MONTH(o.order_date) IN (3, 4, 5) THEN 2
        WHEN MONTH(o.order_date) IN (6, 7, 8) THEN 3
        ELSE 4
    END;

-- =====================================================
-- QUERY 9: BOOK RATING ANALYSIS WITH PERCENTILES
-- =====================================================
-- Business Purpose: Analyze book ratings to identify quality trends
-- Demonstrates: Window functions, percentiles, complex aggregations
WITH rating_stats AS (
    SELECT 
        b.book_id,
        b.title,
        c.name as category,
        COUNT(br.review_id) as review_count,
        AVG(br.rating) as avg_rating,
        MIN(br.rating) as min_rating,
        MAX(br.rating) as max_rating,
        STDDEV(br.rating) as rating_stddev
    FROM books b
    INNER JOIN categories c ON b.category_id = c.category_id
    LEFT JOIN book_reviews br ON b.book_id = br.book_id
    GROUP BY b.book_id, b.title, c.name
    HAVING review_count >= 3
),
rating_percentiles AS (
    SELECT 
        *,
        PERCENT_RANK() OVER (ORDER BY avg_rating) as rating_percentile,
        PERCENT_RANK() OVER (ORDER BY review_count) as review_count_percentile
    FROM rating_stats
)
SELECT 
    category,
    COUNT(*) as books_with_reviews,
    ROUND(AVG(avg_rating), 2) as category_avg_rating,
    ROUND(AVG(review_count), 1) as avg_reviews_per_book,
    ROUND(AVG(rating_stddev), 2) as avg_rating_consistency,
    COUNT(CASE WHEN rating_percentile >= 0.9 THEN 1 END) as top_10_percent_books,
    COUNT(CASE WHEN rating_percentile <= 0.1 THEN 1 END) as bottom_10_percent_books
FROM rating_percentiles
GROUP BY category
ORDER BY category_avg_rating DESC, books_with_reviews DESC;

-- =====================================================
-- QUERY 10: CUSTOMER RETENTION ANALYSIS
-- =====================================================
-- Business Purpose: Analyze customer retention and repeat purchase behavior
-- Demonstrates: Complex subqueries, date calculations, aggregations
WITH customer_order_sequence AS (
    SELECT 
        o.customer_id,
        o.order_id,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) as order_sequence,
        LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) as prev_order_date
    FROM orders o
    WHERE o.status IN ('Delivered', 'Shipped')
),
retention_metrics AS (
    SELECT 
        customer_id,
        COUNT(*) as total_orders,
        MAX(order_sequence) as max_order_sequence,
        AVG(DATEDIFF(order_date, prev_order_date)) as avg_days_between_orders,
        MIN(DATEDIFF(order_date, prev_order_date)) as min_days_between_orders,
        MAX(DATEDIFF(order_date, prev_order_date)) as max_days_between_orders
    FROM customer_order_sequence
    WHERE prev_order_date IS NOT NULL
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'One-time'
        WHEN total_orders = 2 THEN 'Two-time'
        WHEN total_orders BETWEEN 3 AND 5 THEN 'Regular (3-5)'
        WHEN total_orders BETWEEN 6 AND 10 THEN 'Frequent (6-10)'
        ELSE 'Loyal (10+)'
    END as customer_type,
    COUNT(*) as customer_count,
    ROUND(AVG(avg_days_between_orders), 1) as avg_days_between_orders,
    ROUND(AVG(min_days_between_orders), 1) as avg_min_days_between_orders,
    ROUND(AVG(max_days_between_orders), 1) as avg_max_days_between_orders,
    ROUND((COUNT(*) / (SELECT COUNT(*) FROM retention_metrics)) * 100, 2) as percentage_of_customers
FROM retention_metrics
GROUP BY 
    CASE 
        WHEN total_orders = 1 THEN 'One-time'
        WHEN total_orders = 2 THEN 'Two-time'
        WHEN total_orders BETWEEN 3 AND 5 THEN 'Regular (3-5)'
        WHEN total_orders BETWEEN 6 AND 10 THEN 'Frequent (6-10)'
        ELSE 'Loyal (10+)'
    END
ORDER BY 
    CASE 
        WHEN total_orders = 1 THEN 1
        WHEN total_orders = 2 THEN 2
        WHEN total_orders BETWEEN 3 AND 5 THEN 3
        WHEN total_orders BETWEEN 6 AND 10 THEN 4
        ELSE 5
    END;

-- =====================================================
-- QUERY 11: PROFITABILITY ANALYSIS BY PUBLISHER
-- =====================================================
-- Business Purpose: Analyze publisher profitability for contract negotiations
-- Demonstrates: Complex calculations, aggregations, subqueries
SELECT 
    p.name as publisher,
    COUNT(DISTINCT b.book_id) as total_books,
    COUNT(DISTINCT oi.order_item_id) as total_sales,
    SUM(oi.quantity) as total_books_sold,
    SUM(oi.total_price) as total_revenue,
    SUM(oi.quantity * b.cost) as total_cost,
    SUM(oi.total_price) - SUM(oi.quantity * b.cost) as total_profit,
    ROUND(((SUM(oi.total_price) - SUM(oi.quantity * b.cost)) / SUM(oi.total_price)) * 100, 2) as profit_margin,
    ROUND(SUM(oi.total_price) / COUNT(DISTINCT b.book_id), 2) as revenue_per_book,
    ROUND((SUM(oi.total_price) - SUM(oi.quantity * b.cost)) / COUNT(DISTINCT b.book_id), 2) as profit_per_book,
    ROUND(AVG(b.price), 2) as avg_book_price,
    ROUND(AVG(br.rating), 2) as avg_rating
FROM publishers p
INNER JOIN books b ON p.publisher_id = b.publisher_id
LEFT JOIN order_items oi ON b.book_id = oi.book_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.status IN ('Delivered', 'Shipped')
LEFT JOIN book_reviews br ON b.book_id = br.book_id
GROUP BY p.publisher_id, p.name
HAVING total_sales > 0
ORDER BY total_profit DESC, profit_margin DESC;

-- =====================================================
-- QUERY 12: GEOGRAPHIC SALES ANALYSIS
-- =====================================================
-- Business Purpose: Analyze sales by geographic location for marketing strategy
-- Demonstrates: String functions, aggregations, CASE statements
SELECT 
    CASE 
        WHEN c.state IN ('CA', 'NY', 'TX', 'FL', 'IL') THEN c.state
        ELSE 'Other States'
    END as state_group,
    COUNT(DISTINCT c.customer_id) as total_customers,
    COUNT(DISTINCT o.order_id) as total_orders,
    SUM(o.total_amount) as total_revenue,
    ROUND(AVG(o.total_amount), 2) as avg_order_value,
    ROUND(SUM(o.total_amount) / COUNT(DISTINCT c.customer_id), 2) as revenue_per_customer,
    ROUND((SUM(o.total_amount) / (SELECT SUM(total_amount) FROM orders WHERE status IN ('Delivered', 'Shipped'))) * 100, 2) as market_share
FROM customers c
INNER JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status IN ('Delivered', 'Shipped')
GROUP BY 
    CASE 
        WHEN c.state IN ('CA', 'NY', 'TX', 'FL', 'IL') THEN c.state
        ELSE 'Other States'
    END
ORDER BY total_revenue DESC;
