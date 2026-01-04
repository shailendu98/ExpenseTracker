//
//  SummaryReportsView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Charts
import SwiftUI

struct SummaryReportsView: View {
    @StateObject private var viewModel = SummaryReportsViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        // Period Selector
                        periodSelector

                        // Total Spending Card
                        totalSpendingCard

                        // Statistics Cards
                        statisticsCards

                        // Category Pie Chart
                        if !viewModel.categoryBreakdown.isEmpty {
                            categoryPieChartSection
                        }

                        // Monthly Trends Chart
                        if !viewModel.monthlyTrends.isEmpty {
                            monthlyTrendsSection
                        }

                        // Top Categories List
                        if !viewModel.topCategories.isEmpty {
                            topCategoriesSection
                        }

                        // Empty State
                        if viewModel.transactions.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadTransactions()
            }
            .refreshable {
                viewModel.loadTransactions()
            }
        }
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.sm) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        viewModel.selectedPeriod = period
                    }) {
                        Text(period.rawValue)
                            .font(.system(size: Constants.FontSize.caption, weight: .medium))
                            .foregroundColor(
                                viewModel.selectedPeriod == period
                                    ? .white : Constants.Colors.primary
                            )
                            .padding(.horizontal, Constants.Spacing.md)
                            .padding(.vertical, Constants.Spacing.sm)
                            .background(
                                viewModel.selectedPeriod == period
                                    ? Constants.Colors.primary
                                    : Constants.Colors.primary.opacity(0.1)
                            )
                            .cornerRadius(Constants.CornerRadius.sm)
                    }
                }
            }
        }
    }

    // MARK: - Total Spending Card

    private var totalSpendingCard: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Text("Total Spending")
                .font(.system(size: Constants.FontSize.body))
                .foregroundColor(Constants.Colors.textSecondary)

            Text(viewModel.totalSpending.currencyFormatted)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Constants.Colors.primary)

            Text(viewModel.selectedPeriod.rawValue)
                .font(.system(size: Constants.FontSize.caption))
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.xl)
        .cardStyle()
    }

    // MARK: - Statistics Cards

    private var statisticsCards: some View {
        HStack(spacing: Constants.Spacing.md) {
            StatisticCard(
                title: "Transactions",
                value: "\(viewModel.transactionCount)",
                icon: "list.bullet",
                color: Constants.Colors.secondary
            )

            StatisticCard(
                title: "Daily Avg",
                value: viewModel.averageDailySpending.currencyFormatted,
                icon: "calendar",
                color: Constants.Colors.accent
            )
        }
    }

    // MARK: - Category Pie Chart Section

    private var categoryPieChartSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Spending by Category")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            CategoryPieChartView(categoryBreakdown: viewModel.categoryBreakdown)
                .frame(height: 300)
                .cardStyle()
        }
    }

    // MARK: - Monthly Trends Section

    private var monthlyTrendsSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Monthly Trends")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            MonthlyTrendsChartView(monthlyTrends: viewModel.monthlyTrends)
                .frame(height: 250)
                .cardStyle()
        }
    }

    // MARK: - Top Categories Section

    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Top Categories")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            VStack(spacing: Constants.Spacing.sm) {
                ForEach(viewModel.topCategories) { category in
                    TopCategoryRow(categorySpending: category)
                }
            }
            .padding(Constants.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.md) {
            Image(systemName: "chart.bar")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.textSecondary)

            Text("No Data Available")
                .font(.system(size: Constants.FontSize.title, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            Text("Add some expenses to see your reports")
                .font(.system(size: Constants.FontSize.body))
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.xl)
    }
}

// MARK: - Statistic Card
struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(Constants.Colors.textSecondary)
            }

            Text(value)
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Top Category Row
struct TopCategoryRow: View {
    let categorySpending: CategorySpending

    var body: some View {
        HStack {
            if let category = Category.predefined.first(where: {
                $0.name == categorySpending.categoryName
            }) {
                Image(systemName: category.iconName)
                    .foregroundColor(category.color)
                    .frame(width: 30)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(categorySpending.categoryName)
                    .font(.system(size: Constants.FontSize.body, weight: .medium))
                    .foregroundColor(Constants.Colors.textPrimary)

                Text("\(categorySpending.transactionCount) transactions")
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(Constants.Colors.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(categorySpending.formattedAmount)
                    .font(.system(size: Constants.FontSize.body, weight: .bold))
                    .foregroundColor(Constants.Colors.textPrimary)

                Text(categorySpending.formattedPercentage)
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(Constants.Colors.textSecondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SummaryReportsView()
}
