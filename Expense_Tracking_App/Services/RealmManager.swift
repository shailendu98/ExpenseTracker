//
//  RealmManager.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation
import RealmSwift

// MARK: - Transaction Sort Option
enum TransactionSortOption: Hashable, Equatable {
    case dateDescending
    case dateAscending
    case amountDescending
    case amountAscending
    case category
}

class RealmManager {
    static let shared = RealmManager()

    private var realm: Realm {
        do {
            let realmInstance = try Realm()
            print("✅ Realm database opened successfully")
            print(
                "📍 Realm file location: \(realmInstance.configuration.fileURL?.path ?? "Unknown")")
            return realmInstance
        } catch {
            print("❌ Failed to initialize Realm: \(error.localizedDescription)")
            fatalError("Failed to initialize Realm: \(error.localizedDescription)")
        }
    }

    private init() {
        print("🔧 Initializing RealmManager...")

        // Configure Realm
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // Handle migrations if needed in future
                print("🔄 Realm migration from schema version \(oldSchemaVersion)")
            }
        )
        Realm.Configuration.defaultConfiguration = config

        print("✅ RealmManager initialized with schema version 1")
    }

    // MARK: - Transaction Operations

    func createTransaction(_ transaction: Transaction) throws {
        let realm = self.realm
        let transactionObject = TransactionObject(from: transaction)

        try realm.write {
            realm.add(transactionObject)
        }
    }

    func fetchTransactions(
        sortBy: TransactionSortOption = .dateDescending,
        categoryFilter: String? = nil,
        searchText: String? = nil
    ) throws -> [Transaction] {
        let realm = self.realm
        var results = realm.objects(TransactionObject.self)

        // Apply category filter
        if let category = categoryFilter {
            results = results.filter("categoryName == %@", category)
        }

        // Apply search filter
        if let search = searchText, !search.isEmpty {
            results = results.filter(
                "descriptionText CONTAINS[cd] %@ OR categoryName CONTAINS[cd] %@", search, search)
        }

        // Apply sorting
        switch sortBy {
        case .dateDescending:
            results = results.sorted(byKeyPath: "date", ascending: false)
        case .dateAscending:
            results = results.sorted(byKeyPath: "date", ascending: true)
        case .amountDescending:
            results = results.sorted(byKeyPath: "amount", ascending: false)  // High to Low = descending
        case .amountAscending:
            results = results.sorted(byKeyPath: "amount", ascending: true)  // Low to High = ascending
        case .category:
            results = results.sorted(by: [
                SortDescriptor(keyPath: "categoryName", ascending: true),
                SortDescriptor(keyPath: "date", ascending: false),
            ])
        }

        return Array(results.map { $0.toTransaction() })
    }

    func updateTransaction(_ transaction: Transaction) throws {
        let realm = self.realm

        guard
            let transactionObject = realm.object(
                ofType: TransactionObject.self, forPrimaryKey: transaction.id)
        else {
            throw RealmError.transactionNotFound
        }

        try realm.write {
            transactionObject.amount = transaction.amount
            transactionObject.date = transaction.date
            transactionObject.categoryName = transaction.categoryName
            transactionObject.descriptionText = transaction.descriptionText
        }
    }

    func deleteTransaction(_ transaction: Transaction) throws {
        let realm = self.realm

        guard
            let transactionObject = realm.object(
                ofType: TransactionObject.self, forPrimaryKey: transaction.id)
        else {
            throw RealmError.transactionNotFound
        }

        try realm.write {
            realm.delete(transactionObject)
        }
    }

    // MARK: - Category Operations

    func createCategory(_ category: Category) throws {
        let realm = self.realm
        let categoryObject = CategoryObject(from: category)

        try realm.write {
            realm.add(categoryObject)
        }
    }

    func fetchCategories() throws -> [Category] {
        let realm = self.realm
        let results = realm.objects(CategoryObject.self).sorted(byKeyPath: "name", ascending: true)
        return Array(results.map { $0.toCategory() })
    }

    func updateCategory(_ category: Category) throws {
        let realm = self.realm

        guard
            let categoryObject = realm.object(
                ofType: CategoryObject.self, forPrimaryKey: category.id)
        else {
            throw RealmError.categoryNotFound
        }

        try realm.write {
            categoryObject.name = category.name
            categoryObject.colorHex = category.colorHex
            categoryObject.iconName = category.iconName
        }
    }

    func deleteCategory(_ category: Category) throws {
        let realm = self.realm

        // Check if category is used in any transactions
        let transactionsWithCategory = realm.objects(TransactionObject.self).filter(
            "categoryName == %@", category.name)
        if !transactionsWithCategory.isEmpty {
            throw RealmError.categoryInUse
        }

        guard
            let categoryObject = realm.object(
                ofType: CategoryObject.self, forPrimaryKey: category.id)
        else {
            throw RealmError.categoryNotFound
        }

        try realm.write {
            realm.delete(categoryObject)
        }
    }

    // MARK: - Initialize Predefined Categories

    func initializePredefinedCategories() throws {
        let existingCategories = try fetchCategories()
        let predefinedCategories = Category.predefined

        for category in predefinedCategories {
            if !existingCategories.contains(where: { $0.name == category.name }) {
                try createCategory(category)
            }
        }
    }

    // MARK: - Analytics Helpers

    func fetchTransactions(from startDate: Date, to endDate: Date) throws -> [Transaction] {
        let realm = self.realm
        let results = realm.objects(TransactionObject.self)
            .filter("date >= %@ AND date <= %@", startDate, endDate)
            .sorted(byKeyPath: "date", ascending: false)

        return Array(results.map { $0.toTransaction() })
    }
}

// MARK: - Realm Errors
enum RealmError: LocalizedError {
    case transactionNotFound
    case categoryNotFound
    case categoryInUse

    var errorDescription: String? {
        switch self {
        case .transactionNotFound:
            return "Transaction not found"
        case .categoryNotFound:
            return "Category not found"
        case .categoryInUse:
            return "Cannot delete category that is being used in transactions"
        }
    }
}
