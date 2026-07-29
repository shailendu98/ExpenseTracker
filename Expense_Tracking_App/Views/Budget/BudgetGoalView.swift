//
//  BudgetGoalView.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-05.
//

import SwiftUI

// MARK: - Budget Goal Card

struct BudgetGoalView: View {
    @ObservedObject var budgetService: BudgetService
    let transactions: [Transaction]

    @State private var showSetupSheet = false
    @State private var animatedProgress: Double = 0

    private var spending: Double { budgetService.currentMonthSpending(transactions: transactions) }
    private var budget: Double   { budgetService.monthlyBudget }
    private var remaining: Double { budgetService.remaining(transactions: transactions) }
    private var progress: Double  { budgetService.progress(transactions: transactions) }

    // Color transitions: green → orange → red
    private var ringColor: Color {
        switch progress {
        case ..<0.6: return Constants.Colors.success
        case ..<0.85: return Color(hex: "FF9500")
        default: return Constants.Colors.error
        }
    }

    var body: some View {
        if budgetService.isBudgetSet {
            budgetCard
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.top, Constants.Spacing.sm)
        } else {
            setGoalPrompt
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.top, Constants.Spacing.sm)
        }
    }

    // MARK: - Budget Card (compact)

    private var budgetCard: some View {
        Button(action: { showSetupSheet = true }) {
            HStack(spacing: Constants.Spacing.md) {

                // ── Progress Ring (compact) ──
                ZStack {
                    Circle()
                        .stroke(ringColor.opacity(0.15), lineWidth: 7)
                        .frame(width: 68, height: 68)

                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                        )
                        .frame(width: 68, height: 68)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: animatedProgress)

                    VStack(spacing: 0) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(ringColor)
                        Text("used")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                }

                // ── Stats laid out horizontally ──
                HStack(spacing: Constants.Spacing.md) {
                    budgetStat(label: "Budget", value: budget, color: Constants.Colors.primary)
                    budgetStat(label: "Spent", value: spending, color: Constants.Colors.accent)
                    budgetStat(
                        label: "Left",
                        value: remaining,
                        color: progress >= 1 ? Constants.Colors.error : Constants.Colors.success
                    )
                }

                Spacer()

                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Constants.Colors.primary.opacity(0.5))
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                    .fill(Color(.systemBackground))
                    .shadow(color: ringColor.opacity(0.12), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSetupSheet) {
            BudgetSetupSheet(budgetService: budgetService)
        }
        .onAppear { animatedProgress = progress }
        .onChange(of: progress) { _, newVal in animatedProgress = newVal }
    }

    // MARK: - Stat Column (compact)

    private func budgetStat(label: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 3) {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            Text(value.currencyFormatted)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    // MARK: - Set Goal Prompt

    private var setGoalPrompt: some View {
        Button(action: { showSetupSheet = true }) {
            HStack(spacing: Constants.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Constants.Colors.primary.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "target")
                        .font(.system(size: 22))
                        .foregroundColor(Constants.Colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Set Monthly Budget")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Constants.Colors.textPrimary)
                    Text("Track your spending with a goal")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(Constants.Colors.textSecondary)
            }
            .padding(Constants.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Constants.CornerRadius.lg)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showSetupSheet) {
            BudgetSetupSheet(budgetService: budgetService)
        }
    }
}
