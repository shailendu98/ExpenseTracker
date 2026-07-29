//
//  AddExpenseViewModel.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Combine
import Foundation

// MARK: - Notification Names
extension Notification.Name {
    static let transactionSaved = Notification.Name("transactionSaved")
}

class AddExpenseViewModel: ObservableObject {
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var selectedCategory: String = ""
    @Published var description: String = ""

    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var showSuccess: Bool = false

    private let realmManager = RealmManager.shared
    private var cancellables = Set<AnyCancellable>()

    var availableCategories: [Category] = []

    init() {
        loadCategories()
    }

    // MARK: - Load Categories

    func loadCategories() {
        do {
            availableCategories = try realmManager.fetchCategories()
            if availableCategories.isEmpty {
                try realmManager.initializePredefinedCategories()
                availableCategories = try realmManager.fetchCategories()
            }
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
        }
    }

    // MARK: - Validation

    func validate() -> Bool {
        errorMessage = nil

        // Validate amount
        let amountValidation = Validators.validateAmount(amount)
        if !amountValidation.isValid {
            errorMessage = amountValidation.errorMessage
            return false
        }

        // Validate date
        let dateValidation = Validators.validateDate(date)
        if !dateValidation.isValid {
            errorMessage = dateValidation.errorMessage
            return false
        }

        // Validate category
        let categoryValidation = Validators.validateCategorySelection(selectedCategory)
        if !categoryValidation.isValid {
            errorMessage = categoryValidation.errorMessage
            return false
        }

        // Validate description (optional but has max length)
        let descriptionValidation = Validators.validateDescription(description)
        if !descriptionValidation.isValid {
            errorMessage = descriptionValidation.errorMessage
            return false
        }

        return true
    }

    // MARK: - Save Transaction

    func saveTransaction(completion: @escaping (Bool) -> Void) {
        guard validate() else {
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        guard let amountValue = Double(amount.trimmed) else {
            errorMessage = "Invalid amount"
            isLoading = false
            completion(false)
            return
        }

        let transaction = Transaction(
            amount: amountValue,
            date: date,
            categoryName: selectedCategory,
            descriptionText: description.trimmed
        )

        do {
            try realmManager.createTransaction(transaction)
            isLoading = false
            showSuccess = true

            // Notify other views that a transaction was saved
            NotificationCenter.default.post(name: .transactionSaved, object: nil)

            // Reset form after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.resetForm()
                completion(true)
            }
        } catch {
            isLoading = false
            errorMessage = "Failed to save transaction: \(error.localizedDescription)"
            completion(false)
        }
    }

    // MARK: - Reset Form

    func resetForm() {
        amount = ""
        date = Date()
        selectedCategory = ""
        description = ""
        errorMessage = nil
        showSuccess = false
    }

    // MARK: - Computed Properties

    var isFormValid: Bool {
        !amount.isEmpty && !selectedCategory.isEmpty
    }

    var formattedAmount: String {
        guard let value = Double(amount) else { return "₹0.00" }
        return value.currencyFormatted
    }

    // MARK: - Apply Scanned Receipt Data

    func applyScannedData(_ data: ScannedReceiptData) {
        if let amt = data.amount {
            amount = String(format: "%.2f", amt)
        }
        if let scannedDate = data.date {
            date = scannedDate
        }
        if let category = data.suggestedCategory,
           availableCategories.contains(where: { $0.name == category }) {
            selectedCategory = category
        }
        if let merchant = data.merchant, !merchant.isEmpty {
            description = merchant
        }
    }

    // MARK: - Apply Voice Parsed Expense

    func applyVoiceExpense(_ parsed: ParsedVoiceExpense) {
        if let amt = parsed.amount {
            amount = String(format: "%.0f", amt)
        }
        if let category = parsed.categoryName,
           availableCategories.contains(where: { $0.name == category }) {
            selectedCategory = category
        }
        if !parsed.description.isEmpty {
            description = parsed.description
        }
        date = Date()
    }
}
