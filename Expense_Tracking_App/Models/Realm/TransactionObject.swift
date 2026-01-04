//
//  TransactionObject.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation
import RealmSwift

class TransactionObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var amount: Double
    @Persisted var date: Date
    @Persisted var categoryName: String
    @Persisted var descriptionText: String
    @Persisted var createdAt: Date

    convenience init(from transaction: Transaction) {
        self.init()
        self.id = transaction.id
        self.amount = transaction.amount
        self.date = transaction.date
        self.categoryName = transaction.categoryName
        self.descriptionText = transaction.descriptionText
        self.createdAt = transaction.createdAt
    }

    func toTransaction() -> Transaction {
        return Transaction(
            id: id,
            amount: amount,
            date: date,
            categoryName: categoryName,
            descriptionText: descriptionText,
            createdAt: createdAt
        )
    }
}
