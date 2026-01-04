//
//  EditTransactionView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct EditTransactionView: View {
    let transaction: Transaction
    var onSave: (() -> Void)?

    @Environment(\.dismiss) private var dismiss
    @State private var amount: String
    @State private var date: Date
    @State private var selectedCategory: String
    @State private var description: String
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    private let realmManager = RealmManager.shared
    private let categories: [Category]

    init(transaction: Transaction, onSave: (() -> Void)? = nil) {
        self.transaction = transaction
        self.onSave = onSave

        _amount = State(initialValue: String(format: "%.2f", transaction.amount))
        _date = State(initialValue: transaction.date)
        _selectedCategory = State(initialValue: transaction.categoryName)
        _description = State(initialValue: transaction.descriptionText)

        do {
            self.categories = try RealmManager.shared.fetchCategories()
        } catch {
            self.categories = Category.predefined
        }
    }

    var body: some View {
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
                    if let error = errorMessage {
                        errorView(error)
                    }

                    // Save Button
                    saveButton
                }
                .padding(Constants.Spacing.md)
            }
        }
        .navigationTitle("Edit Expense")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }

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
                categories: categories,
                selectedCategory: $selectedCategory
            )
            .presentationDetents([.medium, .large])
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
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

                TextField("0.00", text: $amount)
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

                    Text(date, style: .date)
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
                        "Select Date", selection: $date, in: ...Date(), displayedComponents: .date
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
                    if let category = categories.first(where: { $0.name == selectedCategory }) {
                        Image(systemName: category.iconName)
                            .foregroundColor(category.color)

                        Text(category.name)
                            .foregroundColor(Constants.Colors.textPrimary)
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

            TextField("Add a note...", text: $description, axis: .vertical)
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
        Button(action: saveChanges) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                Text("Save Changes")
            }
        }
        .primaryButtonStyle()
        .disabled(isLoading)
        .padding(.top, Constants.Spacing.md)
    }

    // MARK: - Save Changes

    private func saveChanges() {
        errorMessage = nil

        // Validate amount
        guard let amountValue = Double(amount.trimmingCharacters(in: .whitespaces)), amountValue > 0
        else {
            errorMessage = "Please enter a valid amount"
            return
        }

        // Validate date
        if date > Date() {
            errorMessage = "Date cannot be in the future"
            return
        }

        isLoading = true

        var updatedTransaction = transaction
        updatedTransaction.amount = amountValue
        updatedTransaction.date = date
        updatedTransaction.categoryName = selectedCategory
        updatedTransaction.descriptionText = description.trimmingCharacters(in: .whitespaces)

        do {
            try realmManager.updateTransaction(updatedTransaction)
            isLoading = false
            onSave?()
            dismiss()
        } catch {
            isLoading = false
            errorMessage = "Failed to update transaction: \(error.localizedDescription)"
        }
    }

    // MARK: - Helper Functions

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    EditTransactionView(transaction: Transaction.sample)
}
