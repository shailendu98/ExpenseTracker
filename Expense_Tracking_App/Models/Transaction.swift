//
//  Transaction.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation

struct Transaction: Identifiable, Hashable {
    let id: UUID
    var amount: Double
    var date: Date
    var categoryName: String
    var descriptionText: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        date: Date,
        categoryName: String,
        descriptionText: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.categoryName = categoryName
        self.descriptionText = descriptionText
        self.createdAt = createdAt
    }

    // Computed properties for display
    var formattedAmount: String {
        amount.currencyFormatted
    }

    var formattedDate: String {
        date.displayFormat
    }

    var monthYear: String {
        date.formatted(as: "MMMM yyyy")
    }

    var dayMonthYear: String {
        date.formatted(as: "dd MMM yyyy")
    }
}

// MARK: - Sample Data
extension Transaction {
    static var sample: Transaction {
        Transaction(
            amount: 45.99,
            date: Date(),
            categoryName: "Food & Dining",
            descriptionText: "Lunch at restaurant"
        )
    }

    static var samples: [Transaction] {
        [
            Transaction(
                amount: 45.99, date: Date(), categoryName: "Food & Dining",
                descriptionText: "Lunch at restaurant"),
            Transaction(
                amount: 120.00, date: Date().addingTimeInterval(-86400), categoryName: "Shopping",
                descriptionText: "New shoes"),
            Transaction(
                amount: 25.50, date: Date().addingTimeInterval(-172800),
                categoryName: "Transportation", descriptionText: "Uber ride"),
            Transaction(
                amount: 89.99, date: Date().addingTimeInterval(-259200),
                categoryName: "Bills & Utilities", descriptionText: "Internet bill"),
            Transaction(
                amount: 15.00, date: Date().addingTimeInterval(-345600),
                categoryName: "Entertainment", descriptionText: "Movie tickets"),
        ]
    }
}
