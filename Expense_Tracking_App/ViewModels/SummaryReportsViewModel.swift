//
//  SummaryReportsViewModel.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Combine
import Foundation

class SummaryReportsViewModel: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .month {
        didSet {
            loadTransactions()
        }
    }
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let realmManager = RealmManager.shared

    init() {
        loadTransactions()
    }

    // MARK: - Load Transactions

    func loadTransactions() {
        isLoading = true
        errorMessage = nil

        let dateRange = selectedPeriod.dateRange

        do {
            transactions = try realmManager.fetchTransactions(
                from: dateRange.start,
                to: dateRange.end
            )
            isLoading = false
        } catch {
            errorMessage = "Failed to load transactions: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Total Spending

    var totalSpending: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Category Breakdown

    var categoryBreakdown: [CategorySpending] {
        let grouped = Dictionary(grouping: transactions) { $0.categoryName }

        return grouped.map { categoryName, transactions in
            let total = transactions.reduce(0) { $0 + $1.amount }
            let percentage = totalSpending > 0 ? (total / totalSpending) * 100 : 0

            return CategorySpending(
                categoryName: categoryName,
                amount: total,
                percentage: percentage,
                transactionCount: transactions.count
            )
        }.sorted { $0.amount > $1.amount }
    }

    // MARK: - Monthly Trends

    var monthlyTrends: [MonthlySpending] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction -> String in
            let components = calendar.dateComponents([.year, .month], from: transaction.date)
            let date = calendar.date(from: components) ?? transaction.date
            return date.formatted(as: "MMM yyyy")
        }

        return grouped.map { monthYear, transactions in
            let total = transactions.reduce(0) { $0 + $1.amount }
            return MonthlySpending(monthYear: monthYear, amount: total)
        }.sorted { $0.monthYear < $1.monthYear }
    }

    // MARK: - Top Categories

    var topCategories: [CategorySpending] {
        Array(categoryBreakdown.prefix(5))
    }

    // MARK: - Average Daily Spending

    var averageDailySpending: Double {
        let days = selectedPeriod.numberOfDays
        guard days > 0 else { return 0 }
        return totalSpending / Double(days)
    }

    // MARK: - Transaction Count

    var transactionCount: Int {
        transactions.count
    }

    // MARK: - Largest Transaction

    var largestTransaction: Transaction? {
        transactions.max { $0.amount < $1.amount }
    }

    // MARK: - Average Transaction

    var averageTransaction: Double {
        guard !transactions.isEmpty else { return 0 }
        return totalSpending / Double(transactions.count)
    }
}

// MARK: - Time Period
enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case year = "Year"
    case allTime = "All Time"

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return (start, now)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return (start, now)
        case .threeMonths:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return (start, now)
        case .sixMonths:
            let start = calendar.date(byAdding: .month, value: -6, to: now) ?? now
            return (start, now)
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return (start, now)
        case .allTime:
            let start = calendar.date(byAdding: .year, value: -10, to: now) ?? now
            return (start, now)
        }
    }

    var numberOfDays: Int {
        let calendar = Calendar.current
        let range = dateRange
        let components = calendar.dateComponents([.day], from: range.start, to: range.end)
        return components.day ?? 1
    }
}

// MARK: - Category Spending
struct CategorySpending: Identifiable {
    let id = UUID()
    let categoryName: String
    let amount: Double
    let percentage: Double
    let transactionCount: Int

    var formattedAmount: String {
        amount.currencyFormatted
    }

    var formattedPercentage: String {
        String(format: "%.1f%%", percentage)
    }
}

// MARK: - Monthly Spending
struct MonthlySpending: Identifiable {
    let id = UUID()
    let monthYear: String
    let amount: Double

    var formattedAmount: String {
        amount.currencyFormatted
    }
}
