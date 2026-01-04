//
//  TransactionHistoryViewModel.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Combine
import Foundation

class TransactionHistoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var searchText: String = ""
    @Published var selectedSortOption: TransactionSortOption = .dateDescending {
        didSet {
            loadTransactions()
        }
    }
    @Published var selectedCategoryFilter: String? {
        didSet {
            filterTransactions()
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var availableCategories: [String] = []

    // CRITICAL: filteredTransactions must be @Published to trigger UI updates
    @Published var filteredTransactions: [Transaction] = []

    private let realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadTransactions()
        loadCategories()
        setupSearchObserver()
    }

    // MARK: - Setup Observers

    private func setupSearchObserver() {
        // Only observe search text - sort and filter use didSet
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterTransactions()
            }
            .store(in: &cancellables)
    }

    // MARK: - Load Data

    func loadTransactions() {
        print("📥 Loading transactions...")
        isLoading = true
        errorMessage = nil

        do {
            transactions = try realmManager.fetchTransactions(sortBy: selectedSortOption)
            print("✅ Loaded \(transactions.count) transactions")
            filterTransactions()
            isLoading = false
        } catch {
            print("❌ Failed to load: \(error.localizedDescription)")
            errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func loadCategories() {
        do {
            let categories = try realmManager.fetchCategories()
            availableCategories = categories.map { $0.name }
            print("📂 Loaded categories: \(availableCategories)")
        } catch {
            print("❌ Failed to load categories: \(error.localizedDescription)")
        }
    }

    // MARK: - Filter Transactions

    private func filterTransactions() {
        print("🔍 Filtering transactions...")
        print("📊 Total transactions: \(transactions.count)")
        print("🏷️ Selected category: \(selectedCategoryFilter ?? "None")")
        print("🔎 Search text: '\(searchText)'")

        var filtered = transactions

        // Apply category filter
        if let category = selectedCategoryFilter, !category.isEmpty {
            print("🔧 Filtering by category: \(category)")

            // Debug: Print all categories in transactions
            let allCategories = Set(transactions.map { $0.categoryName })
            print("📋 All categories in data: \(allCategories)")

            filtered = filtered.filter { transaction in
                let match = transaction.categoryName == category
                if !match {
                    print("  ❌ '\(transaction.categoryName)' != '\(category)'")
                }
                return match
            }
            print("✅ After category filter: \(filtered.count) transactions")
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.descriptionText.localizedCaseInsensitiveContains(searchText)
                    || transaction.categoryName.localizedCaseInsensitiveContains(searchText)
                    || transaction.formattedAmount.contains(searchText)
            }
            print("✅ After search filter: \(filtered.count) transactions")
        }

        // CRITICAL: This assignment triggers the @Published update
        filteredTransactions = filtered
        print("📋 Final filtered count: \(filteredTransactions.count)")
        print("---")
    }

    // MARK: - Delete Transaction

    func deleteTransaction(_ transaction: Transaction) {
        do {
            try realmManager.deleteTransaction(transaction)
            loadTransactions()
        } catch {
            errorMessage = "Failed to delete transaction: \(error.localizedDescription)"
        }
    }

    // MARK: - Update Transaction

    func updateTransaction(_ transaction: Transaction) {
        do {
            try realmManager.updateTransaction(transaction)
            loadTransactions()
        } catch {
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
        }
    }

    // MARK: - Grouped Transactions

    var groupedTransactions: [(String, [Transaction])] {
        // Sort groups based on selected sort option
        switch selectedSortOption {
        case .dateDescending:
            // Group by date and sort groups by date (newest first)
            let grouped = Dictionary(grouping: filteredTransactions) { transaction in
                transaction.date.formatted(as: "MMMM dd, yyyy")
            }
            return grouped.sorted { group1, group2 in
                let date1 = group1.value.first?.date ?? Date.distantPast
                let date2 = group2.value.first?.date ?? Date.distantPast
                return date1 > date2
            }

        case .dateAscending:
            // Group by date and sort groups by date (oldest first)
            let grouped = Dictionary(grouping: filteredTransactions) { transaction in
                transaction.date.formatted(as: "MMMM dd, yyyy")
            }
            return grouped.sorted { group1, group2 in
                let date1 = group1.value.first?.date ?? Date.distantPast
                let date2 = group2.value.first?.date ?? Date.distantPast
                return date1 < date2
            }

        case .amountDescending, .amountAscending:
            // For amount sorting, show all transactions in a single group sorted by amount
            // No date grouping - just show all transactions in amount order
            return [("All Transactions", filteredTransactions)]

        case .category:
            // For category sorting, group by date but preserve the transaction order within each group
            var result: [(String, [Transaction])] = []
            var seenDates = Set<String>()

            for transaction in filteredTransactions {
                let dateKey = transaction.date.formatted(as: "MMMM dd, yyyy")
                if !seenDates.contains(dateKey) {
                    seenDates.insert(dateKey)
                    let transactionsForDate = filteredTransactions.filter {
                        $0.date.formatted(as: "MMMM dd, yyyy") == dateKey
                    }
                    result.append((dateKey, transactionsForDate))
                }
            }
            return result
        }
    }

    // MARK: - Statistics

    var totalSpent: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    var transactionCount: Int {
        filteredTransactions.count
    }

    var averageTransaction: Double {
        guard !filteredTransactions.isEmpty else { return 0 }
        return totalSpent / Double(filteredTransactions.count)
    }
}
