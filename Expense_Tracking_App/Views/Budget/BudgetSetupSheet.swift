//
//  BudgetSetupSheet.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import SwiftUI

struct BudgetSetupSheet: View {
    @ObservedObject var budgetService: BudgetService
    @Environment(\.dismiss) private var dismiss

    @State private var budgetText: String = ""
    @State private var showSuccess = false
    @FocusState private var isFieldFocused: Bool

    private var parsedBudget: Double? {
        Double(budgetText.trimmingCharacters(in: .whitespaces))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {

                        // Header illustration
                        headerSection

                        // Amount input
                        inputSection

                        // Quick presets
                        presetsSection

                        // Save button
                        saveButton

                        // Clear budget
                        if budgetService.isBudgetSet {
                            clearButton
                        }
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Monthly Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Constants.Colors.primary)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { isFieldFocused = false }
                        .foregroundColor(Constants.Colors.primary)
                }
            }
        }
        .onAppear {
            if budgetService.monthlyBudget > 0 {
                budgetText = String(Int(budgetService.monthlyBudget))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFieldFocused = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: Constants.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Constants.Colors.primary.opacity(0.15), Constants.Colors.secondary.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)

                Image(systemName: "target")
                    .font(.system(size: 36))
                    .foregroundColor(Constants.Colors.primary)
            }

            Text("Set Your Monthly Goal")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            Text("We'll track your spending and alert you\nas you approach your limit.")
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, Constants.Spacing.md)
    }

    // MARK: - Input

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Budget Amount")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            HStack(alignment: .center) {
                Text("₹")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Constants.Colors.primary)

                TextField("0", text: $budgetText)
                    .font(.system(size: 36, weight: .bold))
                    .keyboardType(.numberPad)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .focused($isFieldFocused)
            }
            .padding(Constants.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Quick Presets

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Quick Select")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            let presets: [Int] = [5000, 10000, 15000, 20000, 30000, 50000]

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
            ], spacing: 10) {
                ForEach(presets, id: \.self) { amount in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            budgetText = String(amount)
                        }
                        isFieldFocused = false
                    }) {
                        Text("₹\(amount / 1000)K")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(
                                parsedBudget == Double(amount)
                                    ? .white : Constants.Colors.primary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.sm)
                                    .fill(
                                        parsedBudget == Double(amount)
                                            ? Constants.Colors.primary
                                            : Constants.Colors.primary.opacity(0.1)
                                    )
                            )
                    }
                }
            }
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: {
            guard let value = parsedBudget, value > 0 else { return }
            withAnimation {
                budgetService.monthlyBudget = value
            }
            dismiss()
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Set Budget")
            }
        }
        .primaryButtonStyle()
        .disabled(parsedBudget == nil || parsedBudget! <= 0)
        .opacity((parsedBudget != nil && parsedBudget! > 0) ? 1.0 : 0.5)
    }

    // MARK: - Clear Button

    private var clearButton: some View {
        Button(action: {
            withAnimation {
                budgetService.monthlyBudget = 0
                budgetText = ""
            }
            dismiss()
        }) {
            Text("Remove Budget Goal")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.error)
        }
        .padding(.top, Constants.Spacing.sm)
    }
}
