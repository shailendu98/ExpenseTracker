//
//  CategoryPieChartView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Charts
import SwiftUI

struct CategoryPieChartView: View {
    let categoryBreakdown: [CategorySpending]

    var body: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Pie Chart
            Chart(categoryBreakdown) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Category", item.categoryName))
                .cornerRadius(5)
            }
            .chartLegend(position: .bottom, alignment: .center, spacing: 10)
            .frame(height: 200)

            // Scrollable Legend with all categories
            ScrollView {
                VStack(spacing: Constants.Spacing.sm) {
                    ForEach(categoryBreakdown) { item in
                        HStack {
                            if let category = Category.predefined.first(where: {
                                $0.name == item.categoryName
                            }) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                            }

                            Text(item.categoryName)
                                .font(.system(size: Constants.FontSize.caption))
                                .foregroundColor(Constants.Colors.textPrimary)

                            Spacer()

                            Text(item.formattedPercentage)
                                .font(.system(size: Constants.FontSize.caption, weight: .medium))
                                .foregroundColor(Constants.Colors.textSecondary)

                            Text(item.formattedAmount)
                                .font(.system(size: Constants.FontSize.caption, weight: .semibold))
                                .foregroundColor(Constants.Colors.textPrimary)
                        }
                    }
                }
            }
            .frame(maxHeight: 150)  // Limit height to make it scrollable
            .padding(.horizontal, Constants.Spacing.md)
        }
        .padding(Constants.Spacing.md)
    }
}

// MARK: - Preview
#Preview {
    CategoryPieChartView(categoryBreakdown: [
        CategorySpending(
            categoryName: "Food & Dining", amount: 450.00, percentage: 35, transactionCount: 12),
        CategorySpending(
            categoryName: "Transportation", amount: 300.00, percentage: 25, transactionCount: 8),
        CategorySpending(
            categoryName: "Shopping", amount: 250.00, percentage: 20, transactionCount: 5),
        CategorySpending(
            categoryName: "Entertainment", amount: 150.00, percentage: 12, transactionCount: 4),
        CategorySpending(categoryName: "Other", amount: 100.00, percentage: 8, transactionCount: 3),
    ])
    .frame(height: 300)
    .cardStyle()
    .padding()
}
