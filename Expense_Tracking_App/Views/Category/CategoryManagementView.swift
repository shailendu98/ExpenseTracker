//
//  CategoryManagementView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct CategoryManagementView: View {
    @StateObject private var viewModel = CategoryManagementViewModel()
    @State private var showAddCategory = false
    @State private var editingCategory: Category?
    @State private var isEditMode = false

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        // Predefined Categories Section
                        predefinedCategoriesSection

                        // Custom Categories Section
                        customCategoriesSection

                        // Add Category Button
                        addCategoryButton
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadCategories()
            }
            .sheet(isPresented: $showAddCategory) {
                AddCategoryView { name, colorHex, iconName in
                    viewModel.addCategory(name: name, colorHex: colorHex, iconName: iconName) {
                        success in
                        if success {
                            showAddCategory = false
                        }
                    }
                }
            }
            .sheet(item: $editingCategory) { category in
                EditCategoryView(category: category) { name, colorHex, iconName in
                    viewModel.updateCategory(
                        category, name: name, colorHex: colorHex, iconName: iconName
                    ) { success in
                        if success {
                            editingCategory = nil
                        }
                    }
                }
            }
        }
    }

    // MARK: - Predefined Categories

    private var predefinedCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Default Categories")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: Constants.Spacing.md
            ) {
                ForEach(viewModel.predefinedCategories) { category in
                    CategoryItemView(category: category, isEditable: false)
                }
            }
        }
    }

    // MARK: - Custom Categories

    private var customCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            HStack {
                Text("Custom Categories")
                    .font(.system(size: Constants.FontSize.title, weight: .bold))
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                if !viewModel.customCategories.isEmpty {
                    Button(isEditMode ? "Done" : "Edit") {
                        withAnimation {
                            isEditMode.toggle()
                        }
                    }
                    .font(.system(size: Constants.FontSize.body, weight: .medium))
                    .foregroundColor(Constants.Colors.primary)
                }
            }

            if viewModel.customCategories.isEmpty {
                Text("No custom categories yet")
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundColor(Constants.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(Constants.Spacing.xl)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: Constants.Spacing.md
                ) {
                    ForEach(viewModel.customCategories) { category in
                        ZStack(alignment: .topTrailing) {
                            CategoryItemView(category: category, isEditable: true)

                            // Edit and delete buttons (visible in edit mode)
                            if isEditMode {
                                VStack(spacing: 4) {
                                // Edit Button
                                Button(action: {
                                    editingCategory = category
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Constants.Colors.primary)
                                        .background(
                                            Circle()
                                                .fill(Constants.Colors.background)
                                                .frame(width: 20, height: 20)
                                        )
                                }

                                // Delete Button
                                Button(action: {
                                    viewModel.deleteCategory(category)
                                }) {
                                    Image(systemName: "trash.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(Constants.Colors.error)
                                        .background(
                                            Circle()
                                                .fill(Constants.Colors.background)
                                                .frame(width: 20, height: 20)
                                        )
                                }
                            }
                            .padding(8)
                            }
                        }
                    }
                }
            }

            if let error = viewModel.errorMessage {
                errorView(error)
            }
        }
    }

    // MARK: - Add Category Button

    private var addCategoryButton: some View {
        Button(action: {
            showAddCategory = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Custom Category")
            }
        }
        .primaryButtonStyle()
    }

    // MARK: - Error View

    private func errorView(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(Constants.Colors.error)

            Text(message)
                .font(.system(size: Constants.FontSize.body))
                .foregroundColor(Constants.Colors.error)

            Spacer()
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.error.opacity(0.1))
        .cornerRadius(Constants.CornerRadius.sm)
    }
}

// MARK: - Category Item View
struct CategoryItemView: View {
    let category: Category
    let isEditable: Bool

    var body: some View {
        VStack(spacing: Constants.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: 60, height: 60)

                Image(systemName: category.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(category.color)
            }

            Text(category.name)
                .font(.system(size: Constants.FontSize.caption, weight: .medium))
                .foregroundColor(Constants.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if isEditable {
                Text("Custom")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Constants.Colors.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Constants.Colors.secondary.opacity(0.1))
                    .cornerRadius(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Preview
#Preview {
    CategoryManagementView()
}
