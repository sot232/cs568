# OLAP Design Notes - Online Bookstore Management System

## Overview
This document outlines the Online Analytical Processing (OLAP) design for the Online Bookstore Management System, including the data warehouse schema, dimensional modeling approach, and analytical capabilities.

## Data Warehouse Architecture

### Design Philosophy
The OLAP system follows the **Star Schema** design pattern with:
- **Fact Tables**: Central tables containing measurable business events (sales transactions)
- **Dimension Tables**: Descriptive tables providing context for facts (customers, books, dates)
- **Denormalized Structure**: Optimized for analytical queries and reporting

### Core Components

#### 1. Fact Table: `fact_sales`
**Purpose**: Central fact table storing individual book sale transactions
**Grain**: One row per book sold in an order

**Key Metrics**:
- `quantity_sold`: Number of books sold
- `unit_price`: Price per book at time of sale
- `total_revenue`: Total revenue from the sale
- `cost_of_goods`: Cost basis for profit calculation
- `profit`: Calculated profit (revenue - cost)
- `profit_margin`: Profit percentage
- `discount_amount`: Any discounts applied
- `tax_amount`: Tax collected
- `shipping_cost`: Shipping charges

**Foreign Keys**:
- `date_id` → `dim_date.date_id`
- `customer_key` → `dim_customer.customer_key`
- `book_key` → `dim_book.book_key`

#### 2. Dimension Tables

##### `dim_date`
**Purpose**: Time dimension for temporal analysis
**Key Attributes**:
- Hierarchical time structure (Year → Quarter → Month → Day)
- Business calendar attributes (weekends, holidays)
- Fiscal year support
- Pre-calculated time-based groupings

**Analytical Benefits**:
- Enables time-series analysis
- Supports seasonal trend analysis
- Facilitates year-over-year comparisons
- Enables fiscal period reporting

##### `dim_customer`
**Purpose**: Customer dimension with SCD Type 2 support
**Key Attributes**:
- Demographics (age groups, gender, location)
- Customer segmentation (New, Regular, VIP, Inactive)
- Behavioral metrics (total orders, total spent, avg order value)
- Temporal validity (valid_from, valid_to) for historical tracking

**Analytical Benefits**:
- Customer lifetime value analysis
- Geographic sales analysis
- Customer segmentation and targeting
- Behavioral pattern analysis

##### `dim_book`
**Purpose**: Book dimension with denormalized attributes
**Key Attributes**:
- Book details (title, ISBN, category, publisher)
- Author information (concatenated author names)
- Classification attributes (price ranges, page ranges)
- Performance indicators (bestseller status, avg rating)

**Analytical Benefits**:
- Product performance analysis
- Category and publisher analysis
- Price point analysis
- Author performance tracking

## Analytical Capabilities
This database design supports the following analytics.

### Sales Analytics
- **Revenue Analysis**: Total revenue, revenue trends, revenue by segment
- **Product Performance**: Best-selling books, category performance
- **Customer Analysis**: Customer value, purchase patterns
- **Geographic Analysis**: Sales by location, regional trends

### Inventory Analytics
- **Stock Analysis**: Stock levels, turnover rates
- **Demand Forecasting**: Based on historical sales patterns
- **Reorder Point Analysis**: Optimal inventory levels
- **Supplier Performance**: Publisher and author performance

### Customer Analytics
- **Segmentation**: Customer tier analysis, behavioral segments
- **Retention Analysis**: Customer lifetime value, churn prediction
- **Purchase Patterns**: Buying frequency, seasonal preferences
- **Geographic Distribution**: Customer location analysis

### Financial Analytics
- **Profitability Analysis**: Profit margins, cost analysis
- **Pricing Analysis**: Price elasticity, competitive positioning
- **Discount Impact**: Promotional effectiveness
- **Cost Management**: Operational cost tracking

## Performance Optimization

### Indexing Strategy
- **Primary Keys**: Clustered indexes on all dimension and fact tables
- **Foreign Keys**: Non-clustered indexes for join performance
- **Composite Indexes**: Multi-column indexes for common query patterns
- **Covering Indexes**: Include frequently accessed columns