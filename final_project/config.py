"""
Configuration file for the Online Bookstore Data Import Script
Update these settings with your AWS MySQL database credentials
"""

# Database configuration
# This is okay since the database will be deleted after the course
DB_CONFIG = {
    'host': 'enricher.c5upedz2zmbe.us-west-1.rds.amazonaws.com',
    'user': 'admin',
    'password': 'TP)8B7}6mH:f]k2',
    'database': 'bookstore',
    'port': 3306
}

# Data generation settings
DATA_SETTINGS = {
    'total_books': 1000,  # Total number of books to generate
    'authors_count': 20,  # Number of authors to generate
    'customers_count': 50,  # Number of customers to generate
    'orders_count': 100,  # Number of orders to generate
    'order_items_count': 300,  # Number of order items to generate
    'reviews_count': 50,  # Number of reviews to generate
    'inventory_transactions_count': 200,  # Number of inventory transactions
    'wishlist_items_count': 50,  # Number of wishlist items
}

# File paths
CSV_FILE_PATH = 'books.csv'  # Path to the books.csv file
