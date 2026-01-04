#!/usr/bin/env python3
"""
Script to add Swift files to Xcode project
This script adds all Swift files from the project directory to the Xcode project.
"""

import os
import subprocess
import sys

def add_files_to_xcode():
    project_dir = "/Users/ibarts/Desktop/Expense_Tracking_App"
    app_dir = os.path.join(project_dir, "Expense_Tracking_App")
    
    # List of all Swift files to add (relative to app_dir)
    swift_files = [
        # Utilities
        "Utilities/Constants.swift",
        "Utilities/Extensions.swift",
        "Utilities/Validators.swift",
        
        # Models
        "Models/Transaction.swift",
        "Models/Category.swift",
        "Models/CoreData/PersistenceController.swift",
        
        # Services
        "Services/CoreDataManager.swift",
        "Services/BiometricAuthService.swift",
        "Services/EncryptionService.swift",
        
        # ViewModels
        "ViewModels/AddExpenseViewModel.swift",
        "ViewModels/TransactionHistoryViewModel.swift",
        "ViewModels/CategoryManagementViewModel.swift",
        "ViewModels/SummaryReportsViewModel.swift",
        "ViewModels/AuthenticationViewModel.swift",
        
        # Views - Expense
        "Views/Expense/AddExpenseView.swift",
        "Views/Expense/TransactionRowView.swift",
        
        # Views - Transaction
        "Views/Transaction/TransactionHistoryView.swift",
        "Views/Transaction/EditTransactionView.swift",
        
        # Views - Category
        "Views/Category/CategoryPickerView.swift",
        "Views/Category/CategoryManagementView.swift",
        "Views/Category/AddCategoryView.swift",
        "Views/Category/EditCategoryView.swift",
        
        # Views - Reports
        "Views/Reports/SummaryReportsView.swift",
        "Views/Reports/CategoryPieChartView.swift",
        "Views/Reports/MonthlyTrendsChartView.swift",
        
        # Views - Authentication
        "Views/Authentication/AuthenticationView.swift",
        "Views/Authentication/PINEntryView.swift",
        "Views/Authentication/PINSetupView.swift",
    ]
    
    print("Files to be added to Xcode project:")
    for file in swift_files:
        full_path = os.path.join(app_dir, file)
        if os.path.exists(full_path):
            print(f"  ✓ {file}")
        else:
            print(f"  ✗ {file} (NOT FOUND)")
    
    print("\nNote: These files need to be manually added to the Xcode project.")
    print("Please open the project in Xcode and drag these files into the project navigator.")
    
if __name__ == "__main__":
    add_files_to_xcode()
