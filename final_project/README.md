# Online Bookstore Management System - Final Project

## Project Overview
This is a comprehensive database project for CS568 Advanced SQL course, implementing a mini data warehouse for an online bookstore with both OLTP (operational) and OLAP (analytical) schemas.

## Prerequisites

### Required Software
- **MySQL Server**: Version 8.0.41 or higher
- **Python**: Version 3.11 or higher. However, 3.7 or higher may work as well
- **MySQL Connector/Python**: For database connectivity

### System Requirements
- Minimum 4GB RAM
- 2GB free disk space
- Internet connection (for AWS RDS setup)

## Database Setup

### Option 1: Local MySQL Installation
1. Install MySQL Server 8.0.41 or higher
2. Create a database user with appropriate privileges
3. Update `config.py` with your local MySQL credentials

### Option 2: AWS RDS MySQL (Recommended)
1. Set up an AWS RDS MySQL instance
2. Configure security groups to allow connections
3. Update `config.py` with your AWS RDS credentials

## Installation Steps

### 1. Clone and Navigate to Project
```bash
cd final_project/sql/data
```

### 2. Install Python Dependencies
```bash
pip install -r requirements.txt
```

### 3. Configure Database Connection
Edit `config.py` and update the database configuration:
```python
DB_CONFIG = {
    'host': 'your-mysql-host',
    'user': 'your-username',
    'password': 'your-password',
    'database': 'bookstore',
    'port': 3306
}
```

### 4. Test Database Connection
```bash
python setup.py
```

## Project Execution Order

**IMPORTANT**: Execute the following scripts in the exact order specified:

### Step 1: Create Database Schema
```bash
mysql -u your_username -p < ../schema_design.sql
```
- Creates the `bookstore` database
- Sets up all OLTP and OLAP tables
- Defines primary keys, foreign keys, and constraints
- Creates initial indexes

### Step 2: Populate Data
```bash
python data_import.py
```
- Imports book data from `books.csv`
- Generates additional sample data (authors, customers, orders, reviews)
- Populates all tables with realistic test data
- Creates approximately 1000+ records across all tables

### Step 3: Create Views and Procedures
```bash
mysql -u your_username -p < ../views_and_procedures.sql
```
- Creates regular views for reporting
- Implements stored procedures with transaction handling
- Sets up materialized view simulation
- Adds business logic procedures

### Step 4: Apply Performance Optimizations
```bash
mysql -u your_username -p < ../performance_optimization.sql
```
- Creates additional indexes for query optimization
- Implements performance monitoring procedures
- Sets up query analysis tools

### Step 5: Execute Complex Queries
```bash
mysql -u your_username -p < ../complex_queries.sql
```
- Demonstrates advanced SQL techniques
- Shows business intelligence queries
- Includes performance analysis examples

## Verification Steps

### 1. Check Database Structure
```sql
USE bookstore;
SHOW TABLES;
DESCRIBE books;
```

### 2. Verify Data Population
```sql
SELECT COUNT(*) FROM books;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM orders;
```

### 3. Test Views
```sql
SELECT * FROM v_customer_order_summary LIMIT 5;
SELECT * FROM v_book_sales_analysis LIMIT 5;
```

### 4. Test Stored Procedures
```sql
CALL sp_place_order(1, 1, 2, @result);
SELECT @result;
```

## Project Structure
There may be additional fields that this structure doesn't reveal.

```
final_project/
├── sql/
│   ├── schema_design.sql          # Database schema creation
│   ├── views_and_procedures.sql   # Views and stored procedures
│   ├── performance_optimization.sql # Indexes and optimization
│   ├── complex_queries.sql        # Advanced query demonstrations
│   └── data/
│       ├── config.py              # Database configuration
│       ├── setup.py               # Setup verification script
│       ├── data_import.py         # Data population script
│       ├── books.csv              # Sample book data
│       └── requirements.txt       # Python dependencies
├── docs/
│   ├── ERD.png                    # Entity Relationship Diagram
│   ├── index_report.md            # Performance analysis report
│   └── OLAP_design_note.md        # OLAP schema documentation
└── demo/
    └── Optimization/              # Before/after performance screenshots
```

## Key Features Demonstrated

### Database Design
- **OLTP Schema**: 10+ normalized tables for operational data
- **OLAP Schema**: Star schema with fact and dimension tables
- **Constraints**: Primary keys, foreign keys, check constraints
- **Data Types**: Appropriate use of VARCHAR, INT, DECIMAL, DATE, TIMESTAMP

### Advanced Queries
- **JOINs**: Inner, left, right joins across multiple tables
- **Aggregations**: GROUP BY, HAVING, window functions
- **Subqueries**: Correlated and non-correlated subqueries
- **CTEs**: Common Table Expressions using WITH clause
- **Functions**: Date, string, and numeric function usage

### Views and Automation
- **Regular Views**: 2+ views for simplified reporting
- **Stored Procedures**: Transaction handling with COMMIT/ROLLBACK
- **Materialized Views**: Simulated using tables and procedures
- **Error Handling**: Comprehensive error handling in procedures

### Performance Optimization
- **Indexes**: 3+ strategic indexes beyond primary keys
- **Composite Indexes**: Multi-column indexes for complex queries
- **Query Analysis**: EXPLAIN output and performance metrics
- **Before/After**: Performance improvement demonstrations

### Transactions and Concurrency
- **ACID Properties**: Proper transaction implementation
- **Concurrency Control**: SELECT FOR UPDATE demonstrations
- **Error Handling**: Rollback scenarios and error recovery
- **Business Logic**: Inventory checks and validation rules

## Troubleshooting

### Common Issues

1. **Connection Errors**
   - Verify MySQL server is running
   - Check firewall settings
   - Confirm credentials in `config.py`

2. **Permission Errors**
   - Ensure user has CREATE, INSERT, UPDATE, DELETE privileges
   - Grant necessary permissions: `GRANT ALL PRIVILEGES ON bookstore.* TO 'user'@'host';`

3. **Python Import Errors**
   - Install requirements: `pip install -r requirements.txt`
   - Verify Python version compatibility

4. **Data Import Issues**
   - Check `books.csv` file exists in data directory
   - Verify file permissions
   - Ensure sufficient disk space

## Business Context

This system simulates an online bookstore with the following business processes:
- **Customer Management**: Registration, profiles, order history
- **Inventory Management**: Book catalog, stock tracking, supplier management
- **Order Processing**: Order placement, payment processing, fulfillment
- **Analytics**: Sales reporting, customer behavior analysis, performance metrics

## Support

For technical issues or questions about this project:
1. Review the documentation in the `docs/` folder
2. Examine the demo screenshots in the `demo/` folder
---

**MySQL Version**: 8.0.41  
**Last Updated**: September 2025
**Course**: CS568 Advanced SQL - Final Project