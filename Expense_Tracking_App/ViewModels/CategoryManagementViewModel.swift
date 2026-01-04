//
//  CategoryManagementViewModel.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Combine
import Foundation

class CategoryManagementViewModel: ObservableObject {
    @Published var predefinedCategories: [Category] = []
    @Published var customCategories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccess: Bool = false

    private let realmManager = RealmManager.shared

    init() {
        loadCategories()
    }

    // MARK: - Load Categories

    func loadCategories() {
        isLoading = true
        errorMessage = nil

        do {
            // Initialize predefined categories if needed
            try realmManager.initializePredefinedCategories()

            let allCategories = try realmManager.fetchCategories()
            predefinedCategories = allCategories.filter { !$0.isCustom }
            customCategories = allCategories.filter { $0.isCustom }

            isLoading = false
        } catch {
            errorMessage = "Failed to load categories: \(error.localizedDescription)"
            isLoading = false
        }
    }

    // MARK: - Add Category

    func addCategory(
        name: String, colorHex: String, iconName: String, completion: @escaping (Bool) -> Void
    ) {
        errorMessage = nil

        // Validate category name
        let existingNames = (predefinedCategories + customCategories).map { $0.name }
        let validation = Validators.validateCategoryName(name, existingNames: existingNames)

        if !validation.isValid {
            errorMessage = validation.errorMessage
            completion(false)
            return
        }

        let category = Category(
            name: name.trimmed,
            colorHex: colorHex,
            iconName: iconName,
            isCustom: true
        )

        do {
            try realmManager.createCategory(category)
            showSuccess = true
            loadCategories()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSuccess = false
            }

            completion(true)
        } catch {
            errorMessage = "Failed to add category: \(error.localizedDescription)"
            completion(false)
        }
    }

    // MARK: - Update Category

    func updateCategory(
        _ category: Category, name: String, colorHex: String, iconName: String,
        completion: @escaping (Bool) -> Void
    ) {
        errorMessage = nil

        // Validate category name (exclude current category from check)
        let existingNames = (predefinedCategories + customCategories)
            .filter { $0.id != category.id }
            .map { $0.name }

        let validation = Validators.validateCategoryName(name, existingNames: existingNames)

        if !validation.isValid {
            errorMessage = validation.errorMessage
            completion(false)
            return
        }

        var updatedCategory = category
        updatedCategory.name = name.trimmed
        updatedCategory.colorHex = colorHex
        updatedCategory.iconName = iconName

        do {
            try realmManager.updateCategory(updatedCategory)
            showSuccess = true
            loadCategories()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showSuccess = false
            }

            completion(true)
        } catch {
            errorMessage = "Failed to update category: \(error.localizedDescription)"
            completion(false)
        }
    }

    // MARK: - Delete Category

    func deleteCategory(_ category: Category) {
        errorMessage = nil

        do {
            try realmManager.deleteCategory(category)
            loadCategories()
        } catch {
            if let realmError = error as? RealmError {
                errorMessage = realmError.localizedDescription
            } else {
                errorMessage = "Failed to delete category: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Computed Properties

    var allCategories: [Category] {
        predefinedCategories + customCategories
    }

    var categoryCount: Int {
        allCategories.count
    }
}
