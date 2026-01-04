//
//  Validators.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation

struct Validators {

    // MARK: - Amount Validation
    static func validateAmount(_ amount: String) -> ValidationResult {
        let trimmed = amount.trimmed

        if trimmed.isEmpty {
            return .failure("Amount is required")
        }

        guard let value = Double(trimmed) else {
            return .failure("Please enter a valid number")
        }

        if value <= 0 {
            return .failure("Amount must be greater than 0")
        }

        if value > Constants.Validation.maxAmount {
            return .failure("Amount exceeds maximum limit")
        }

        // Check for max 2 decimal places
        let components = trimmed.components(separatedBy: ".")
        if components.count > 1 && components[1].count > 2 {
            return .failure("Amount can have maximum 2 decimal places")
        }

        return .success
    }

    // MARK: - Date Validation
    static func validateDate(_ date: Date) -> ValidationResult {
        if date > Date() {
            return .failure("Date cannot be in the future")
        }
        return .success
    }

    // MARK: - Description Validation
    static func validateDescription(_ description: String) -> ValidationResult {
        let trimmed = description.trimmed

        if trimmed.count > Constants.Validation.maxDescriptionLength {
            return .failure(
                "Description is too long (max \(Constants.Validation.maxDescriptionLength) characters)"
            )
        }

        return .success
    }

    // MARK: - Category Name Validation
    static func validateCategoryName(_ name: String, existingNames: [String] = [])
        -> ValidationResult
    {
        let trimmed = name.trimmed

        if trimmed.isEmpty {
            return .failure("Category name is required")
        }

        if trimmed.count > Constants.Validation.maxCategoryNameLength {
            return .failure(
                "Category name is too long (max \(Constants.Validation.maxCategoryNameLength) characters)"
            )
        }

        if existingNames.contains(where: { $0.lowercased() == trimmed.lowercased() }) {
            return .failure("Category name already exists")
        }

        return .success
    }

    // MARK: - Category Selection Validation
    static func validateCategorySelection(_ categoryName: String?) -> ValidationResult {
        if categoryName == nil || categoryName?.trimmed.isEmpty == true {
            return .failure("Please select a category")
        }
        return .success
    }
}

// MARK: - Validation Result
enum ValidationResult {
    case success
    case failure(String)

    var isValid: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case .failure(let message) = self {
            return message
        }
        return nil
    }
}
