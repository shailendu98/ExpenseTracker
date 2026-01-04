//
//  CategoryPickerView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategory: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: Constants.Spacing.md
                    ) {
                        ForEach(categories) { category in
                            CategoryCard(
                                category: category,
                                isSelected: selectedCategory == category.name
                            )
                            .onTapGesture {
                                selectedCategory = category.name
                                dismiss()
                            }
                        }
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: Category
    let isSelected: Bool

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
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                .stroke(isSelected ? Constants.Colors.primary : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    CategoryPickerView(
        categories: Category.predefined,
        selectedCategory: .constant("Food & Dining")
    )
}
