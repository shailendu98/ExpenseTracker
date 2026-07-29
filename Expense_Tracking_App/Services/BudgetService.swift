//
//  BudgetService.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import Foundation
import Combine

// MARK: - Budget Service

class BudgetService: ObservableObject {
    static let shared = BudgetService()

    private let budgetKey = "monthlyBudgetGoal"
    private let defaults = UserDefaults.standard

    @Published var monthlyBudget: Double {
        didSet {
            defaults.set(monthlyBudget, forKey: budgetKey)
        }
    }

    private init() {
        let stored = defaults.double(forKey: "monthlyBudgetGoal")
        self.monthlyBudget = stored > 0 ? stored : 0
    }

    // MARK: - Computed Spending for Current Month

    func currentMonthSpending(transactions: [Transaction]) -> Double {
        let now = Date()
        return transactions
            .filter { $0.date.isSameMonth(as: now) }
            .reduce(0) { $0 + $1.amount }
    }

    func remaining(transactions: [Transaction]) -> Double {
        guard monthlyBudget > 0 else { return 0 }
        return max(0, monthlyBudget - currentMonthSpending(transactions: transactions))
    }

    func progress(transactions: [Transaction]) -> Double {
        guard monthlyBudget > 0 else { return 0 }
        return min(1.0, currentMonthSpending(transactions: transactions) / monthlyBudget)
    }

    var isBudgetSet: Bool { monthlyBudget > 0 }

    var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }
}
