//
//  AddExpenseView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct AddExpenseView: View {
    @StateObject private var viewModel = AddExpenseViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false

    var onSave: (() -> Void)?

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        // Amount Section
                        amountSection

                        // Date Section
                        dateSection

                        // Category Section
                        categorySection

                        // Description Section
                        descriptionSection

                        // Error Message
                        if let error = viewModel.errorMessage {
                            errorView(error)
                        }

                        // Save Button
                        saveButton
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                    .foregroundColor(Constants.Colors.primary)
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(
                    categories: viewModel.availableCategories,
                    selectedCategory: $viewModel.selectedCategory
                )
            }
        }
    }

    // MARK: - Amount Section

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Amount")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            HStack {
                Text("₹")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Constants.Colors.primary)

                TextField("0.00", text: $viewModel.amount)
                    .font(.system(size: 32, weight: .bold))
                    .keyboardType(.decimalPad)
                    .foregroundColor(Constants.Colors.textPrimary)
            }
            .padding(Constants.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Date Section

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Date")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            Button(action: {
                showDatePicker.toggle()
            }) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Constants.Colors.primary)

                    Text(viewModel.date, style: .date)
                        .foregroundColor(Constants.Colors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding(Constants.Spacing.md)
                .cardStyle()
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                VStack {
                    DatePicker(
                        "Select Date", selection: $viewModel.date, in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Spacer()
                }
                .navigationTitle("Select Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showDatePicker = false
                        }
                    }
                }
            }
        }
    }

    // MARK: - Category Section

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Category")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            Button(action: {
                showCategoryPicker = true
            }) {
                HStack {
                    if viewModel.selectedCategory.isEmpty {
                        Text("Select Category")
                            .foregroundColor(Constants.Colors.textSecondary)
                    } else {
                        if let category = viewModel.availableCategories.first(where: {
                            $0.name == viewModel.selectedCategory
                        }) {
                            Image(systemName: category.iconName)
                                .foregroundColor(category.color)

                            Text(category.name)
                                .foregroundColor(Constants.Colors.textPrimary)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                .padding(Constants.Spacing.md)
                .cardStyle()
            }
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Description (Optional)")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            TextField("Add a note...", text: $viewModel.description, axis: .vertical)
                .lineLimit(3...6)
                .padding(Constants.Spacing.md)
                .cardStyle()
        }
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

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: {
            viewModel.saveTransaction { success in
                if success {
                    onSave?()
                }
            }
        }) {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Save Expense")
            }
        }
        .primaryButtonStyle()
        .disabled(viewModel.isLoading || !viewModel.isFormValid)
        .opacity(viewModel.isFormValid ? 1.0 : 0.5)
        .padding(.top, Constants.Spacing.md)
    }

    // MARK: - Helper Functions

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    AddExpenseView()
}
