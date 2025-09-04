-- =====================================================
-- DATA IMPORT SCRIPT FOR ONLINE BOOKSTORE (AWS Compatible)
-- =====================================================
-- This script creates sample data without requiring LOAD DATA INFILE
-- =====================================================

USE bookstore;

-- =====================================================
-- INSERT SAMPLE BOOKS DATA (AWS Compatible)
-- =====================================================

-- Insert first batch of books (20 books from the original CSV)
INSERT INTO books (title, price, cost, stock_quantity, book_url, category_id, publisher_id, publication_date, pages, language, description)
VALUES
('A Light in the Attic', 51.77, 31.06, 25, 'http://books.toscrape.com/catalogue/a-light-in-the-attic_1000/index.html', 11, 1, '2006-01-01', 200, 'English', 'A collection of poems for children'),
('Tipping the Velvet', 53.74, 32.24, 30, 'http://books.toscrape.com/catalogue/tipping-the-velvet_999/index.html', 1, 2, '2005-01-01', 350, 'English', 'A historical fiction novel'),
('Soumission', 50.10, 30.06, 15, 'http://books.toscrape.com/catalogue/soumission_998/index.html', 1, 3, '2015-01-01', 280, 'French', 'A contemporary fiction novel'),
('Sharp Objects', 47.82, 28.69, 40, 'http://books.toscrape.com/catalogue/sharp-objects_997/index.html', 3, 4, '2006-01-01', 320, 'English', 'A psychological thriller'),
('Sapiens: A Brief History of Humankind', 54.23, 32.54, 35, 'http://books.toscrape.com/catalogue/sapiens-a-brief-history-of-humankind_996/index.html', 8, 5, '2011-01-01', 443, 'English', 'A comprehensive history of human evolution'),
('The Requiem Red', 22.65, 13.59, 20, 'http://books.toscrape.com/catalogue/the-requiem-red_995/index.html', 12, 6, '2016-01-01', 250, 'English', 'A young adult fantasy novel'),
('The Dirty Little Secrets of Getting Your Dream Job', 33.34, 20.00, 18, 'http://books.toscrape.com/catalogue/the-dirty-little-secrets-of-getting-your-dream-job_994/index.html', 9, 7, '2011-01-01', 180, 'English', 'Career advice and job search strategies'),
('The Coming Woman: A Novel Based on the Life of the Infamous Feminist, Victoria Woodhull', 17.93, 10.76, 12, 'http://books.toscrape.com/catalogue/the-coming-woman-a-novel-based-on-the-life-of-the-infamous-feminist-victoria-woodhull_993/index.html', 1, 8, '2015-01-01', 400, 'English', 'Historical fiction about a pioneering feminist'),
('The Boys in the Boat: Nine Americans and Their Epic Quest for Gold at the 1936 Berlin Olympics', 22.60, 13.56, 28, 'http://books.toscrape.com/catalogue/the-boys-in-the-boat-nine-americans-and-their-epic-quest-for-gold-at-the-1936-berlin-olympics_992/index.html', 8, 9, '2013-01-01', 404, 'English', 'A true story of Olympic rowing triumph'),
('The Black Maria', 52.15, 31.29, 22, 'http://books.toscrape.com/catalogue/the-black-maria_991/index.html', 11, 10, '2015-01-01', 150, 'English', 'A collection of contemporary poetry'),
('Starving Hearts (Triangular Trade Trilogy, #1)', 13.99, 8.39, 16, 'http://books.toscrape.com/catalogue/starving-hearts-triangular-trade-trilogy-1_990/index.html', 4, 1, '2016-01-01', 320, 'English', 'Historical romance novel'),
('Shakespeare\'s Sonnets', 20.66, 12.40, 14, 'http://books.toscrape.com/catalogue/shakespeares-sonnets_989/index.html', 11, 2, '2004-01-01', 200, 'English', 'The complete collection of Shakespeare\'s sonnets'),
('Set Me Free', 17.46, 10.48, 19, 'http://books.toscrape.com/catalogue/set-me-free_988/index.html', 12, 3, '2015-01-01', 280, 'English', 'A young adult contemporary novel'),
('Scott Pilgrim\'s Precious Little Life (Scott Pilgrim #1)', 52.29, 31.37, 33, 'http://books.toscrape.com/catalogue/scott-pilgrims-precious-little-life-scott-pilgrim-1_987/index.html', 6, 4, '2004-01-01', 168, 'English', 'A graphic novel about love and video games'),
('Rip it Up and Start Again', 35.02, 21.01, 11, 'http://books.toscrape.com/catalogue/rip-it-up-and-start-again_986/index.html', 8, 5, '2005-01-01', 400, 'English', 'A history of post-punk music'),
('Our Band Could Be Your Life: Scenes from the American Indie Underground, 1981-1991', 57.25, 34.35, 7, 'http://books.toscrape.com/catalogue/our-band-could-be-your-life-scenes-from-the-american-indie-underground-1981-1991_985/index.html', 8, 6, '2001-01-01', 528, 'English', 'A comprehensive history of American indie music'),
('Olio', 23.88, 14.33, 13, 'http://books.toscrape.com/catalogue/olio_984/index.html', 11, 7, '2016-01-01', 240, 'English', 'A poetry collection exploring African American history'),
('Mesaerion: The Best Science Fiction Stories 1800-1849', 37.59, 22.55, 21, 'http://books.toscrape.com/catalogue/mesaerion-the-best-science-fiction-stories-1800-1849_983/index.html', 5, 8, '2013-01-01', 300, 'English', 'A collection of early science fiction stories'),
('Libertarianism for Beginners', 51.33, 30.80, 9, 'http://books.toscrape.com/catalogue/libertarianism-for-beginners_982/index.html', 8, 9, '2012-01-01', 176, 'English', 'An introduction to libertarian political philosophy'),
('It\'s Only the Himalayas', 45.17, 27.10, 17, 'http://books.toscrape.com/catalogue/its-only-the-himalayas_981/index.html', 15, 10, '2014-01-01', 250, 'English', 'A travel memoir about adventure and self-discovery');

-- Generate additional books using a more efficient approach
-- Create a stored procedure to generate books
DELIMITER //
CREATE PROCEDURE sp_generate_books(IN num_books INT)
BEGIN
    DECLARE i INT DEFAULT 21;
    WHILE i <= num_books DO
        INSERT INTO books (title, price, cost, stock_quantity, book_url, category_id, publisher_id, publication_date, pages, language, description)
        VALUES (
            CONCAT('Sample Book ', i),
            ROUND(RAND() * 50 + 10, 2),
            ROUND((RAND() * 50 + 10) * 0.6, 2),
            FLOOR(RAND() * 50) + 10,
            CONCAT('http://books.toscrape.com/catalogue/sample-book-', i, '/index.html'),
            FLOOR(RAND() * 20) + 1,
            FLOOR(RAND() * 10) + 1,
            DATE_ADD('2000-01-01', INTERVAL FLOOR(RAND() * 20) YEAR),
            FLOOR(RAND() * 400) + 100,
            'English',
            CONCAT('This is a sample book description for book number ', i)
        );
        SET i = i + 1;
    END WHILE;
END//
DELIMITER ;

-- Generate 980 more books to reach 1000 total
CALL sp_generate_books(1000);

-- Drop the procedure as it's no longer needed
DROP PROCEDURE sp_generate_books;

-- =====================================================
-- GENERATE FAKE DATA FOR COMPLETE SYSTEM
-- =====================================================

-- Generate fake authors
INSERT INTO authors (first_name, last_name, birth_date, nationality, biography)
SELECT 
    CASE FLOOR(RAND() * 20)
        WHEN 0 THEN 'John' WHEN 1 THEN 'Jane' WHEN 2 THEN 'Michael' WHEN 3 THEN 'Sarah'
        WHEN 4 THEN 'David' WHEN 5 THEN 'Emily' WHEN 6 THEN 'Robert' WHEN 7 THEN 'Jessica'
        WHEN 8 THEN 'William' WHEN 9 THEN 'Ashley' WHEN 10 THEN 'James' WHEN 11 THEN 'Amanda'
        WHEN 12 THEN 'Christopher' WHEN 13 THEN 'Jennifer' WHEN 14 THEN 'Daniel' WHEN 15 THEN 'Lisa'
        WHEN 16 THEN 'Matthew' WHEN 17 THEN 'Michelle' WHEN 18 THEN 'Anthony' WHEN 19 THEN 'Kimberly'
    END as first_name,
    CASE FLOOR(RAND() * 20)
        WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Brown'
        WHEN 4 THEN 'Jones' WHEN 5 THEN 'Garcia' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Davis'
        WHEN 8 THEN 'Rodriguez' WHEN 9 THEN 'Martinez' WHEN 10 THEN 'Hernandez' WHEN 11 THEN 'Lopez'
        WHEN 12 THEN 'Gonzalez' WHEN 13 THEN 'Wilson' WHEN 14 THEN 'Anderson' WHEN 15 THEN 'Thomas'
        WHEN 16 THEN 'Taylor' WHEN 17 THEN 'Moore' WHEN 18 THEN 'Jackson' WHEN 19 THEN 'Martin'
    END as last_name,
    DATE_ADD('1950-01-01', INTERVAL FLOOR(RAND() * 50) YEAR) as birth_date,
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'American' WHEN 1 THEN 'British' WHEN 2 THEN 'Canadian' WHEN 3 THEN 'Australian' ELSE 'Irish'
    END as nationality,
    CONCAT('Award-winning author with over ', FLOOR(RAND() * 20) + 5, ' published works.') as biography
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
) numbers;

-- Link books to authors (many-to-many)
INSERT INTO book_authors (book_id, author_id, author_order, royalty_percentage)
SELECT 
    b.book_id,
    FLOOR(RAND() * 20) + 1 as author_id,
    1 as author_order,
    ROUND(RAND() * 15 + 5, 2) as royalty_percentage
FROM books b
WHERE b.book_id <= 1000; -- Only for imported books

-- Generate fake customers
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, 
                      address_line1, city, state, postal_code, country, total_orders, total_spent)
SELECT 
    CASE FLOOR(RAND() * 15)
        WHEN 0 THEN 'Alex' WHEN 1 THEN 'Jordan' WHEN 2 THEN 'Taylor' WHEN 3 THEN 'Casey'
        WHEN 4 THEN 'Morgan' WHEN 5 THEN 'Riley' WHEN 6 THEN 'Avery' WHEN 7 THEN 'Quinn'
        WHEN 8 THEN 'Blake' WHEN 9 THEN 'Cameron' WHEN 10 THEN 'Drew' WHEN 11 THEN 'Emery'
        WHEN 12 THEN 'Finley' WHEN 13 THEN 'Hayden' WHEN 14 THEN 'Jamie' ELSE 'Parker'
    END as first_name,
    CASE FLOOR(RAND() * 15)
        WHEN 0 THEN 'Anderson' WHEN 1 THEN 'Thompson' WHEN 2 THEN 'White' WHEN 3 THEN 'Harris'
        WHEN 4 THEN 'Sanchez' WHEN 5 THEN 'Clark' WHEN 6 THEN 'Ramirez' WHEN 7 THEN 'Lewis'
        WHEN 8 THEN 'Robinson' WHEN 9 THEN 'Walker' WHEN 10 THEN 'Young' WHEN 11 THEN 'Allen'
        WHEN 12 THEN 'King' WHEN 13 THEN 'Wright' WHEN 14 THEN 'Scott' ELSE 'Torres'
    END as last_name,
    CONCAT('customer', n, '@email.com') as email,
    CONCAT('555-', LPAD(FLOOR(RAND() * 1000), 3, '0'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0')) as phone,
    DATE_ADD('1980-01-01', INTERVAL FLOOR(RAND() * 30) YEAR) as date_of_birth,
    CASE FLOOR(RAND() * 3) WHEN 0 THEN 'M' WHEN 1 THEN 'F' ELSE 'Other' END as gender,
    CONCAT(FLOOR(RAND() * 9999) + 1, ' Main St') as address_line1,
    CASE FLOOR(RAND() * 10)
        WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago' WHEN 3 THEN 'Houston'
        WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia' WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego'
        WHEN 8 THEN 'Dallas' WHEN 9 THEN 'San Jose' ELSE 'Austin'
    END as city,
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'CA' WHEN 1 THEN 'NY' WHEN 2 THEN 'TX' WHEN 3 THEN 'FL' ELSE 'IL'
    END as state,
    LPAD(FLOOR(RAND() * 100000), 5, '0') as postal_code,
    'USA' as country,
    FLOOR(RAND() * 20) as total_orders,
    ROUND(RAND() * 2000 + 100, 2) as total_spent
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
    UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
    UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40
    UNION SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45
    UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50
) numbers;

-- Generate fake orders
INSERT INTO orders (customer_id, order_date, status, subtotal, tax_amount, shipping_cost, 
                   discount_amount, total_amount, payment_method, payment_status, shipping_address)
SELECT 
    FLOOR(RAND() * 50) + 1 as customer_id,
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 365) DAY) as order_date,
    CASE FLOOR(RAND() * 6)
        WHEN 0 THEN 'Pending' WHEN 1 THEN 'Processing' WHEN 2 THEN 'Shipped'
        WHEN 3 THEN 'Delivered' WHEN 4 THEN 'Cancelled' ELSE 'Returned'
    END as status,
    ROUND(RAND() * 200 + 20, 2) as subtotal,
    ROUND(RAND() * 20 + 2, 2) as tax_amount,
    CASE WHEN RAND() > 0.7 THEN ROUND(RAND() * 10 + 5, 2) ELSE 0 END as shipping_cost,
    CASE WHEN RAND() > 0.8 THEN ROUND(RAND() * 20 + 5, 2) ELSE 0 END as discount_amount,
    ROUND(RAND() * 200 + 20, 2) as total_amount,
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'Credit Card' WHEN 1 THEN 'Debit Card' WHEN 2 THEN 'PayPal'
        WHEN 3 THEN 'Bank Transfer' ELSE 'Cash on Delivery'
    END as payment_method,
    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Pending' WHEN 1 THEN 'Paid' WHEN 2 THEN 'Failed' ELSE 'Refunded'
    END as payment_status,
    CONCAT(FLOOR(RAND() * 9999) + 1, ' Main St, City, State 12345') as shipping_address
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
    UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
    UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40
    UNION SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45
    UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50
    UNION SELECT 51 UNION SELECT 52 UNION SELECT 53 UNION SELECT 54 UNION SELECT 55
    UNION SELECT 56 UNION SELECT 57 UNION SELECT 58 UNION SELECT 59 UNION SELECT 60
    UNION SELECT 61 UNION SELECT 62 UNION SELECT 63 UNION SELECT 64 UNION SELECT 65
    UNION SELECT 66 UNION SELECT 67 UNION SELECT 68 UNION SELECT 69 UNION SELECT 70
    UNION SELECT 71 UNION SELECT 72 UNION SELECT 73 UNION SELECT 74 UNION SELECT 75
    UNION SELECT 76 UNION SELECT 77 UNION SELECT 78 UNION SELECT 79 UNION SELECT 80
    UNION SELECT 81 UNION SELECT 82 UNION SELECT 83 UNION SELECT 84 UNION SELECT 85
    UNION SELECT 86 UNION SELECT 87 UNION SELECT 88 UNION SELECT 89 UNION SELECT 90
    UNION SELECT 91 UNION SELECT 92 UNION SELECT 93 UNION SELECT 94 UNION SELECT 95
    UNION SELECT 96 UNION SELECT 97 UNION SELECT 98 UNION SELECT 99 UNION SELECT 100
) numbers;

-- Generate order items
INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price)
SELECT 
    o.order_id,
    FLOOR(RAND() * 1000) + 1 as book_id,
    FLOOR(RAND() * 3) + 1 as quantity,
    b.price as unit_price,
    b.price * (FLOOR(RAND() * 3) + 1) as total_price
FROM orders o
CROSS JOIN books b
WHERE o.order_id <= 100 AND b.book_id <= 1000
LIMIT 300; -- Limit to prevent too many order items

-- Generate book reviews
INSERT INTO book_reviews (customer_id, book_id, rating, title, review_text, is_verified_purchase)
SELECT 
    FLOOR(RAND() * 50) + 1 as customer_id,
    FLOOR(RAND() * 1000) + 1 as book_id,
    FLOOR(RAND() * 5) + 1 as rating,
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'Great book!' WHEN 1 THEN 'Highly recommended' WHEN 2 THEN 'Good read'
        WHEN 3 THEN 'Interesting story' ELSE 'Worth reading'
    END as title,
    CASE FLOOR(RAND() * 5)
        WHEN 0 THEN 'This book exceeded my expectations. The plot was engaging and the characters were well-developed.'
        WHEN 1 THEN 'A fantastic read that kept me hooked from start to finish. Highly recommend to others.'
        WHEN 2 THEN 'Good book with interesting themes. The writing style was enjoyable.'
        WHEN 3 THEN 'An okay read. Some parts were slow but overall decent.'
        ELSE 'Not my favorite, but others might enjoy it more than I did.'
    END as review_text,
    CASE WHEN RAND() > 0.3 THEN TRUE ELSE FALSE END as is_verified_purchase
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
    UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
    UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40
    UNION SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45
    UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50
) numbers
WHERE NOT EXISTS (
    SELECT 1 FROM book_reviews br 
    WHERE br.customer_id = FLOOR(RAND() * 50) + 1 
    AND br.book_id = FLOOR(RAND() * 1000) + 1
);

-- Generate inventory transactions
INSERT INTO inventory_transactions (book_id, transaction_type, quantity_change, reference_id, reference_type, notes)
SELECT 
    b.book_id,
    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Purchase' WHEN 1 THEN 'Sale' WHEN 2 THEN 'Adjustment' ELSE 'Damaged'
    END as transaction_type,
    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN FLOOR(RAND() * 50) + 10 -- Purchase
        WHEN 1 THEN -(FLOOR(RAND() * 5) + 1) -- Sale
        WHEN 2 THEN FLOOR(RAND() * 10) - 5 -- Adjustment
        ELSE -(FLOOR(RAND() * 3) + 1) -- Damaged
    END as quantity_change,
    CASE WHEN FLOOR(RAND() * 4) = 1 THEN FLOOR(RAND() * 100) + 1 ELSE NULL END as reference_id,
    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Purchase Order' WHEN 1 THEN 'Order' WHEN 2 THEN 'Manual' ELSE 'System'
    END as reference_type,
    CASE FLOOR(RAND() * 4)
        WHEN 0 THEN 'Initial stock purchase'
        WHEN 1 THEN 'Customer order fulfillment'
        WHEN 2 THEN 'Inventory adjustment'
        ELSE 'Damaged goods removal'
    END as notes
FROM books b
WHERE b.book_id <= 1000
LIMIT 200;

-- Generate wishlist items
INSERT INTO wishlist (customer_id, book_id, priority, notes)
SELECT 
    FLOOR(RAND() * 50) + 1 as customer_id,
    FLOOR(RAND() * 1000) + 1 as book_id,
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'Low' WHEN 1 THEN 'Medium' ELSE 'High'
    END as priority,
    CASE FLOOR(RAND() * 3)
        WHEN 0 THEN 'Want to read this soon'
        WHEN 1 THEN 'Recommended by friend'
        ELSE 'Looks interesting'
    END as notes
FROM (
    SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
    UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
    UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40
    UNION SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45
    UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50
) numbers
WHERE NOT EXISTS (
    SELECT 1 FROM wishlist w 
    WHERE w.customer_id = FLOOR(RAND() * 50) + 1 
    AND w.book_id = FLOOR(RAND() * 1000) + 1
);

-- Generate discount codes
INSERT INTO discount_codes (code, description, discount_type, discount_value, min_order_amount, 
                           usage_limit, valid_from, valid_to)
VALUES
('WELCOME10', 'Welcome discount for new customers', 'Percentage', 10.00, 25.00, 100, '2024-01-01', '2024-12-31'),
('SAVE20', 'Save 20% on orders over $50', 'Percentage', 20.00, 50.00, 50, '2024-01-01', '2024-12-31'),
('FREESHIP', 'Free shipping on any order', 'Fixed Amount', 10.00, 0.00, 200, '2024-01-01', '2024-12-31'),
('STUDENT15', 'Student discount', 'Percentage', 15.00, 30.00, 100, '2024-01-01', '2024-12-31'),
('BULK25', 'Bulk purchase discount', 'Percentage', 25.00, 100.00, 25, '2024-01-01', '2024-12-31');

COMMIT;

-- Display summary of imported data
SELECT 'Data Import Summary' as Summary;
SELECT 'Books' as Table_Name, COUNT(*) as Record_Count FROM books
UNION ALL
SELECT 'Authors', COUNT(*) FROM authors
UNION ALL
SELECT 'Customers', COUNT(*) FROM customers
UNION ALL
SELECT 'Orders', COUNT(*) FROM orders
UNION ALL
SELECT 'Order Items', COUNT(*) FROM order_items
UNION ALL
SELECT 'Reviews', COUNT(*) FROM book_reviews
UNION ALL
SELECT 'Wishlist Items', COUNT(*) FROM wishlist
UNION ALL
SELECT 'Inventory Transactions', COUNT(*) FROM inventory_transactions
UNION ALL
SELECT 'Discount Codes', COUNT(*) FROM discount_codes;
