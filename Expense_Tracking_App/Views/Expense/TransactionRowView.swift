//
//  TransactionRowView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: Constants.Spacing.md) {
            // Category Icon
            if let category = getCategoryInfo() {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: category.iconName)
                        .font(.system(size: 22))
                        .foregroundColor(category.color)
                }
            }

            // Transaction Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.categoryName)
                    .font(.system(size: Constants.FontSize.body, weight: .semibold))
                    .foregroundColor(Constants.Colors.textPrimary)

                if !transaction.descriptionText.isEmpty {
                    Text(transaction.descriptionText)
                        .font(.system(size: Constants.FontSize.caption))
                        .foregroundColor(Constants.Colors.textSecondary)
                        .lineLimit(1)
                }

                Text(transaction.formattedDate)
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(Constants.Colors.textSecondary)
            }

            Spacer()

            // Amount
            Text(transaction.formattedAmount)
                .font(.system(size: Constants.FontSize.body, weight: .bold))
                .foregroundColor(Constants.Colors.accent)
        }
        .padding(Constants.Spacing.md)
        .cardStyle()
        .padding(.horizontal, Constants.Spacing.md)
    }

    private func getCategoryInfo() -> (color: Color, iconName: String)? {
        guard
            let category = Category.predefined.first(where: { $0.name == transaction.categoryName })
        else {
            return (Color.gray, "circle.fill")
        }
        return (category.color, category.iconName)
    }
}

// MARK: - Preview
#Preview {
    TransactionRowView(transaction: Transaction.sample)
}
