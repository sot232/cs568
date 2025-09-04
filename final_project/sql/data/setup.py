#!/usr/bin/env python3
"""
Setup script for the Online Bookstore Data Import
This script helps you configure and run the data import process
"""

import os
import sys

def check_requirements():
    """Check if required packages are installed"""
    try:
        import pandas
        import mysql.connector
        print("All required packages are installed")
        return True
    except ImportError as e:
        print(f"Missing required package: {e}")
        print("Please install requirements with: pip install -r requirements.txt")
        return False

def check_files():
    """Check if required files exist"""
    required_files = ['books.csv', 'config.py', 'data_import.py']
    missing_files = []
    
    for file in required_files:
        if not os.path.exists(file):
            missing_files.append(file)
    
    if missing_files:
        print(f"Missing files: {', '.join(missing_files)}")
        return False
    else:
        print("All required files are present")
        return True

def configure_database():
    """Help user configure database settings"""
    print("\n🔧 Database Configuration")
    print("="*40)
    
    # Check if config.py exists and has default values
    with open('config.py', 'r') as f:
        content = f.read()
        if 'your-aws-mysql-host.amazonaws.com' in content:
            print("You need to update your database configuration in config.py")
            print("\nPlease edit config.py and update the following:")
            print("- DB_CONFIG['host']: Your AWS MySQL host")
            print("- DB_CONFIG['user']: Your MySQL username")
            print("- DB_CONFIG['password']: Your MySQL password")
            print("\nExample:")
            print("DB_CONFIG = {")
            print("    'host': 'mydb.abc123.us-east-1.rds.amazonaws.com',")
            print("    'user': 'admin',")
            print("    'password': 'mypassword123',")
            print("    'database': 'bookstore',")
            print("    'port': 3306")
            print("}")
            return False
        else:
            print("Database configuration appears to be set up")
            return True

def main():
    """Main setup function"""
    print("🚀 Online Bookstore Data Import Setup")
    print("="*50)
    
    # Check requirements
    if not check_requirements():
        sys.exit(1)
    
    # Check files
    if not check_files():
        sys.exit(1)
    
    # Check database configuration
    if not configure_database():
        print("\nPlease configure your database settings and run this script again")
        sys.exit(1)
    
    print("\nSetup complete! You can now run the data import:")
    print("   python data_import.py")

if __name__ == "__main__":
    main()
