#!/usr/bin/env python3
"""
Data Import Script for Online Bookstore Management System
This script imports books.csv data and generates additional fake data for the complete system.
"""

import pandas as pd
import mysql.connector
import random
from datetime import datetime, timedelta
import sys
import os
from config import DB_CONFIG, DATA_SETTINGS, CSV_FILE_PATH

def connect_to_database():
    """Connect to MySQL database"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        print("Successfully connected to MySQL database")
        return connection
    except mysql.connector.Error as err:
        print(f"Error connecting to MySQL: {err}")
        sys.exit(1)

def read_books_csv():
    """Read books.csv file"""
    try:
        csv_path = os.path.join(os.path.dirname(__file__), CSV_FILE_PATH)
        df = pd.read_csv(csv_path)
        print(f"Successfully read {len(df)} books from CSV")
        return df
    except FileNotFoundError:
        print(f"{CSV_FILE_PATH} file not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading CSV: {e}")
        sys.exit(1)

def convert_rating_to_int(rating_str):
    """Convert rating string to integer"""
    rating_map = {
        'One': 1,
        'Two': 2,
        'Three': 3,
        'Four': 4,
        'Five': 5
    }
    return rating_map.get(rating_str, 3)

def insert_books(cursor, books_df):
    """Insert books from CSV into database"""
    print("Inserting books from CSV...")
    
    # Get category mappings
    cursor.execute("SELECT category_id, name FROM categories")
    categories = {name.lower(): cat_id for cat_id, name in cursor.fetchall()}
    
    # Get publisher mappings
    cursor.execute("SELECT publisher_id, name FROM publishers")
    publishers = {name: pub_id for pub_id, name in cursor.fetchall()}
    publisher_ids = list(publishers.values())
    
    books_inserted = 0
    
    for _, row in books_df.iterrows():
        try:
            # Map category
            category_id = categories.get(row['category'].lower(), 1)  # Default to Fiction
            
            # Random publisher
            publisher_id = random.choice(publisher_ids)
            
            # Calculate cost (40% markup)
            cost = round(row['price'] * 0.6, 2)
            
            # Stock quantity
            stock_quantity = random.randint(10, 50) if row['stock'] == 'In stock' else 0
            
            # Insert book
            insert_query = """
            INSERT INTO books (title, price, cost, stock_quantity, book_url, category_id, publisher_id, 
                             publication_date, pages, language, description)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            values = (
                row['title'],
                row['price'],
                cost,
                stock_quantity,
                row['book_url'],
                category_id,
                publisher_id,
                datetime(2000 + random.randint(0, 20), random.randint(1, 12), random.randint(1, 28)),
                random.randint(100, 500),
                'English',
                f"Description for {row['title']}"
            )
            
            cursor.execute(insert_query, values)
            books_inserted += 1
            
        except Exception as e:
            print(f"⚠️ Error inserting book '{row['title']}': {e}")
            continue
    
    print(f"Inserted {books_inserted} books from CSV")

def generate_additional_books(cursor, target_total=None):
    """Generate additional books to reach target total"""
    print("Generating additional books...")
    
    # Check current count
    cursor.execute("SELECT COUNT(*) FROM books")
    current_count = cursor.fetchone()[0]
    
    if target_total is None:
        target_total = DATA_SETTINGS['total_books']
    
    books_needed = target_total - current_count
    
    if books_needed <= 0:
        print(f"Already have {current_count} books, no additional books needed")
        return
    
    # Get category and publisher IDs
    cursor.execute("SELECT category_id FROM categories")
    category_ids = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT publisher_id FROM publishers")
    publisher_ids = [row[0] for row in cursor.fetchall()]
    
    # Generate additional books
    for i in range(books_needed):
        try:
            book_number = current_count + i + 1
            
            insert_query = """
            INSERT INTO books (title, price, cost, stock_quantity, book_url, category_id, publisher_id,
                             publication_date, pages, language, description)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            values = (
                f"Generated Book {book_number}",
                round(random.uniform(10, 60), 2),
                round(random.uniform(6, 36), 2),
                random.randint(10, 50),
                f"http://books.toscrape.com/catalogue/generated-book-{book_number}/index.html",
                random.choice(category_ids),
                random.choice(publisher_ids),
                datetime(2000 + random.randint(0, 20), random.randint(1, 12), random.randint(1, 28)),
                random.randint(100, 500),
                'English',
                f"This is a generated book description for book number {book_number}"
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating book {i+1}: {e}")
            continue
    
    print(f"Generated {books_needed} additional books")

def generate_authors(cursor, count=20):
    """Generate fake authors"""
    print("👥 Generating authors...")
    
    first_names = ['John', 'Jane', 'Michael', 'Sarah', 'David', 'Emily', 'Robert', 'Jessica', 
                   'William', 'Ashley', 'James', 'Amanda', 'Christopher', 'Jennifer', 'Daniel', 
                   'Lisa', 'Matthew', 'Michelle', 'Anthony', 'Kimberly']
    
    last_names = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis',
                  'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson',
                  'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin']
    
    nationalities = ['American', 'British', 'Canadian', 'Australian', 'Irish']
    
    for i in range(count):
        try:
            insert_query = """
            INSERT INTO authors (first_name, last_name, birth_date, nationality, biography)
            VALUES (%s, %s, %s, %s, %s)
            """
            
            values = (
                random.choice(first_names),
                random.choice(last_names),
                datetime(1950 + random.randint(0, 50), random.randint(1, 12), random.randint(1, 28)),
                random.choice(nationalities),
                f"Award-winning author with over {random.randint(5, 25)} published works."
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating author {i+1}: {e}")
            continue
    
    print(f"Generated {count} authors")

def link_books_to_authors(cursor):
    """Link books to authors (many-to-many relationship)"""
    print("🔗 Linking books to authors...")
    
    # Get all books and authors
    cursor.execute("SELECT book_id FROM books")
    book_ids = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT author_id FROM authors")
    author_ids = [row[0] for row in cursor.fetchall()]
    
    links_created = 0
    
    for book_id in book_ids:
        try:
            # Each book gets 1-3 authors
            num_authors = random.randint(1, 3)
            selected_authors = random.sample(author_ids, min(num_authors, len(author_ids)))
            
            for i, author_id in enumerate(selected_authors):
                insert_query = """
                INSERT INTO book_authors (book_id, author_id, author_order, royalty_percentage)
                VALUES (%s, %s, %s, %s)
                """
                
                values = (
                    book_id,
                    author_id,
                    i + 1,
                    round(random.uniform(5, 20), 2)
                )
                
                cursor.execute(insert_query, values)
                links_created += 1
                
        except Exception as e:
            print(f"Error linking book {book_id}: {e}")
            continue
    
    print(f"Created {links_created} book-author links")

def generate_customers(cursor, count=50):
    """Generate fake customers"""
    print("👤 Generating customers...")
    
    first_names = ['Alex', 'Jordan', 'Taylor', 'Casey', 'Morgan', 'Riley', 'Avery', 'Quinn',
                   'Blake', 'Cameron', 'Drew', 'Emery', 'Finley', 'Hayden', 'Jamie', 'Parker']
    
    last_names = ['Anderson', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis',
                  'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres']
    
    cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 
              'San Antonio', 'San Diego', 'Dallas', 'San Jose', 'Austin']
    
    states = ['CA', 'NY', 'TX', 'FL', 'IL']
    
    genders = ['M', 'F', 'Other']
    
    for i in range(count):
        try:
            insert_query = """
            INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender,
                                 address_line1, city, state, postal_code, country, total_orders, total_spent)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            values = (
                random.choice(first_names),
                random.choice(last_names),
                f'customer{i+1}@email.com',
                f'555-{random.randint(100, 999)}-{random.randint(1000, 9999)}',
                datetime(1980 + random.randint(0, 30), random.randint(1, 12), random.randint(1, 28)),
                random.choice(genders),
                f'{random.randint(1, 9999)} Main St',
                random.choice(cities),
                random.choice(states),
                f'{random.randint(10000, 99999)}',
                'USA',
                random.randint(0, 20),
                round(random.uniform(100, 2000), 2)
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating customer {i+1}: {e}")
            continue
    
    print(f"Generated {count} customers")

def generate_orders(cursor, count=100):
    """Generate fake orders"""
    print("Generating orders...")
    
    # Get customer IDs
    cursor.execute("SELECT customer_id FROM customers")
    customer_ids = [row[0] for row in cursor.fetchall()]
    
    statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned']
    payment_methods = ['Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash on Delivery']
    payment_statuses = ['Pending', 'Paid', 'Failed', 'Refunded']
    
    for i in range(count):
        try:
            subtotal = round(random.uniform(20, 200), 2)
            tax_amount = round(subtotal * 0.08, 2)
            shipping_cost = 0 if subtotal >= 50 else round(random.uniform(5, 10), 2)
            discount_amount = round(random.uniform(0, 20), 2) if random.random() > 0.8 else 0
            total_amount = subtotal + tax_amount + shipping_cost - discount_amount
            
            insert_query = """
            INSERT INTO orders (customer_id, order_date, status, subtotal, tax_amount, shipping_cost,
                               discount_amount, total_amount, payment_method, payment_status, shipping_address)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            values = (
                random.choice(customer_ids),
                datetime(2023, 1, 1) + timedelta(days=random.randint(0, 365)),
                random.choice(statuses),
                subtotal,
                tax_amount,
                shipping_cost,
                discount_amount,
                total_amount,
                random.choice(payment_methods),
                random.choice(payment_statuses),
                f'{random.randint(1, 9999)} Main St, City, State 12345'
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating order {i+1}: {e}")
            continue
    
    print(f"Generated {count} orders")

def generate_order_items(cursor, count=300):
    """Generate fake order items"""
    print("Generating order items...")
    
    # Get order and book IDs
    cursor.execute("SELECT order_id FROM orders")
    order_ids = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT book_id, price FROM books")
    books = cursor.fetchall()
    
    for i in range(count):
        try:
            order_id = random.choice(order_ids)
            book_id, price = random.choice(books)
            quantity = random.randint(1, 3)
            total_price = price * quantity
            
            insert_query = """
            INSERT INTO order_items (order_id, book_id, quantity, unit_price, total_price)
            VALUES (%s, %s, %s, %s, %s)
            """
            
            values = (order_id, book_id, quantity, price, total_price)
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"Error generating order item {i+1}: {e}")
            continue
    
    print(f"Generated {count} order items")

def generate_reviews(cursor, count=50):
    """Generate fake book reviews"""
    print("Generating book reviews...")
    
    # Get customer and book IDs
    cursor.execute("SELECT customer_id FROM customers")
    customer_ids = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT book_id FROM books")
    book_ids = [row[0] for row in cursor.fetchall()]
    
    review_titles = ['Great book!', 'Highly recommended', 'Good read', 'Interesting story', 'Worth reading']
    review_texts = [
        'This book exceeded my expectations. The plot was engaging and the characters were well-developed.',
        'A fantastic read that kept me hooked from start to finish. Highly recommend to others.',
        'Good book with interesting themes. The writing style was enjoyable.',
        'An okay read. Some parts were slow but overall decent.',
        'Not my favorite, but others might enjoy it more than I did.'
    ]
    
    for i in range(count):
        try:
            insert_query = """
            INSERT INTO book_reviews (customer_id, book_id, rating, title, review_text, is_verified_purchase)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            
            values = (
                random.choice(customer_ids),
                random.choice(book_ids),
                random.randint(1, 5),
                random.choice(review_titles),
                random.choice(review_texts),
                random.choice([True, False])
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating review {i+1}: {e}")
            continue
    
    print(f"Generated {count} book reviews")

def generate_inventory_transactions(cursor, count=200):
    """Generate fake inventory transactions"""
    print("Generating inventory transactions...")
    
    # Get book IDs
    cursor.execute("SELECT book_id FROM books")
    book_ids = [row[0] for row in cursor.fetchall()]
    
    transaction_types = ['Purchase', 'Sale', 'Adjustment', 'Damaged']
    reference_types = ['Purchase Order', 'Order', 'Manual', 'System']
    
    notes = [
        'Initial stock purchase',
        'Customer order fulfillment',
        'Inventory adjustment',
        'Damaged goods removal'
    ]
    
    for i in range(count):
        try:
            book_id = random.choice(book_ids)
            transaction_type = random.choice(transaction_types)
            
            if transaction_type == 'Purchase':
                quantity_change = random.randint(10, 50)
            elif transaction_type == 'Sale':
                quantity_change = -random.randint(1, 5)
            elif transaction_type == 'Adjustment':
                quantity_change = random.randint(-5, 10)
            else:  # Damaged
                quantity_change = -random.randint(1, 3)
            
            insert_query = """
            INSERT INTO inventory_transactions (book_id, transaction_type, quantity_change, reference_id, reference_type, notes)
            VALUES (%s, %s, %s, %s, %s, %s)
            """
            
            values = (
                book_id,
                transaction_type,
                quantity_change,
                random.randint(1, 100) if random.random() > 0.5 else None,
                random.choice(reference_types),
                random.choice(notes)
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating inventory transaction {i+1}: {e}")
            continue
    
    print(f"Generated {count} inventory transactions")

def generate_wishlist_items(cursor, count=50):
    """Generate fake wishlist items"""
    print("Generating wishlist items...")
    
    # Get customer and book IDs
    cursor.execute("SELECT customer_id FROM customers")
    customer_ids = [row[0] for row in cursor.fetchall()]
    
    cursor.execute("SELECT book_id FROM books")
    book_ids = [row[0] for row in cursor.fetchall()]
    
    priorities = ['Low', 'Medium', 'High']
    notes = ['Want to read this soon', 'Recommended by friend', 'Looks interesting']
    
    for i in range(count):
        try:
            insert_query = """
            INSERT INTO wishlist (customer_id, book_id, priority, notes)
            VALUES (%s, %s, %s, %s)
            """
            
            values = (
                random.choice(customer_ids),
                random.choice(book_ids),
                random.choice(priorities),
                random.choice(notes)
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating wishlist item {i+1}: {e}")
            continue
    
    print(f"Generated {count} wishlist items")

def generate_discount_codes(cursor):
    """Generate discount codes"""
    print("Generating discount codes...")
    
    discount_codes = [
        ('WELCOME10', 'Welcome discount for new customers', 'Percentage', 10.00, 25.00, 100),
        ('SAVE20', 'Save 20% on orders over $50', 'Percentage', 20.00, 50.00, 50),
        ('FREESHIP', 'Free shipping on any order', 'Fixed Amount', 10.00, 0.00, 200),
        ('STUDENT15', 'Student discount', 'Percentage', 15.00, 30.00, 100),
        ('BULK25', 'Bulk purchase discount', 'Percentage', 25.00, 100.00, 25)
    ]
    
    for code, description, discount_type, discount_value, min_order_amount, usage_limit in discount_codes:
        try:
            insert_query = """
            INSERT INTO discount_codes (code, description, discount_type, discount_value, min_order_amount, 
                                       usage_limit, valid_from, valid_to)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            
            values = (
                code,
                description,
                discount_type,
                discount_value,
                min_order_amount,
                usage_limit,
                datetime(2024, 1, 1),
                datetime(2024, 12, 31)
            )
            
            cursor.execute(insert_query, values)
            
        except Exception as e:
            print(f"⚠️ Error generating discount code {code}: {e}")
            continue
    
    print("Generated 5 discount codes")

def print_summary(cursor):
    """Print summary of imported data"""
    print("\n" + "="*50)
    print("DATA IMPORT SUMMARY")
    print("="*50)
    
    tables = [
        ('Books', 'books'),
        ('Authors', 'authors'),
        ('Customers', 'customers'),
        ('Orders', 'orders'),
        ('Order Items', 'order_items'),
        ('Reviews', 'book_reviews'),
        ('Wishlist Items', 'wishlist'),
        ('Inventory Transactions', 'inventory_transactions'),
        ('Discount Codes', 'discount_codes')
    ]
    
    for table_name, table_query in tables:
        try:
            cursor.execute(f"SELECT COUNT(*) FROM {table_query}")
            count = cursor.fetchone()[0]
            print(f"{table_name:.<30} {count:>10}")
        except Exception as e:
            print(f"{table_name:.<30} {'ERROR':>10}")

def main():
    """Main function to run the data import process"""
    print("Starting Online Bookstore Data Import")
    print("="*50)
    
    # Connect to database
    connection = connect_to_database()
    cursor = connection.cursor()
    
    try:
        # Read books CSV
        books_df = read_books_csv()
        
        # Insert books from CSV
        insert_books(cursor, books_df)
        
        # Generate additional books
        generate_additional_books(cursor)
        
        # Generate supporting data
        generate_authors(cursor, count=DATA_SETTINGS['authors_count'])
        link_books_to_authors(cursor)
        generate_customers(cursor, count=DATA_SETTINGS['customers_count'])
        generate_orders(cursor, count=DATA_SETTINGS['orders_count'])
        generate_order_items(cursor, count=DATA_SETTINGS['order_items_count'])
        generate_reviews(cursor, count=DATA_SETTINGS['reviews_count'])
        generate_inventory_transactions(cursor, count=DATA_SETTINGS['inventory_transactions_count'])
        generate_wishlist_items(cursor, count=DATA_SETTINGS['wishlist_items_count'])
        generate_discount_codes(cursor)
        
        # Commit all changes
        connection.commit()
        print("\nAll data imported successfully!")
        
        # Print summary
        print_summary(cursor)
        
    except Exception as e:
        print(f"\nError during import: {e}")
        connection.rollback()
        sys.exit(1)
    
    finally:
        cursor.close()
        connection.close()
        print("\n🔌 Database connection closed")

if __name__ == "__main__":
    main()
