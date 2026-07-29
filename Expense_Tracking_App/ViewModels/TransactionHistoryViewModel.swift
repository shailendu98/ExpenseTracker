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
    @Published var dateFilterStart: Date? {
        didSet { filterTransactions() }
    }
    @Published var dateFilterEnd: Date? {
        didSet { filterTransactions() }
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
        setupTransactionSavedObserver()
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

    private func setupTransactionSavedObserver() {
        NotificationCenter.default
            .publisher(for: .transactionSaved)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadTransactions()
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
        var filtered = transactions

        // Apply category filter
        if let category = selectedCategoryFilter, !category.isEmpty {
            filtered = filtered.filter { $0.categoryName == category }
        }

        // Apply date filter
        if let start = dateFilterStart, let end = dateFilterEnd {
            filtered = filtered.filter { $0.date >= start && $0.date <= end }
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                transaction.descriptionText.localizedCaseInsensitiveContains(searchText)
                    || transaction.categoryName.localizedCaseInsensitiveContains(searchText)
                    || transaction.formattedAmount.contains(searchText)
            }
        }

        // CRITICAL: This assignment triggers the @Published update
        filteredTransactions = filtered
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

    // MARK: - Date Filter Helpers

    var isDateFiltered: Bool {
        dateFilterStart != nil
    }

    /// Human-readable label for the active date chip, e.g. "29 Jul" or "25–29 Jul"
    var activeDateLabel: String {
        guard let start = dateFilterStart, let end = dateFilterEnd else { return "" }
        let cal = Calendar.current
        if cal.isDate(start, inSameDayAs: end) {
            return start.formatted(as: "d MMM")
        }
        // Same year: omit year on start
        let startStr = cal.isDate(start, equalTo: end, toGranularity: .year)
            ? start.formatted(as: "d MMM")
            : start.formatted(as: "d MMM yy")
        return "\(startStr) – \(end.formatted(as: "d MMM"))"
    }

    func clearDateFilter() {
        dateFilterStart = nil
        dateFilterEnd   = nil
    }
}
