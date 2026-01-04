//
//  AddCategoryView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categoryName: String = ""
    @State private var selectedColor: Color = Constants.Colors.primary
    @State private var selectedIcon: String = "circle.fill"

    var onSave: (String, String, String) -> Void

    private let availableIcons = [
        "cart.fill", "bag.fill", "creditcard.fill", "banknote.fill",
        "fork.knife", "cup.and.saucer.fill", "takeoutbag.and.cup.and.straw.fill",
        "car.fill", "bus.fill", "tram.fill", "airplane",
        "tv.fill", "gamecontroller.fill", "music.note", "film.fill",
        "heart.fill", "cross.case.fill", "figure.run", "dumbbell.fill",
        "book.fill", "graduationcap.fill", "pencil", "backpack.fill",
        "house.fill", "lightbulb.fill", "wifi", "phone.fill",
        "gift.fill", "star.fill", "flag.fill", "tag.fill",
    ]

    private let availableColors: [Color] = [
        Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "95E1D3"),
        Color(hex: "F38181"), Color(hex: "AA96DA"), Color(hex: "FCBAD3"),
        Color(hex: "FFA07A"), Color(hex: "A8E6CF"), Color(hex: "6C63FF"),
        Color(hex: "FF9FF3"), Color(hex: "54A0FF"), Color(hex: "48DBFB"),
        Color(hex: "1DD1A1"), Color(hex: "FFC312"), Color(hex: "EE5A6F"),
        Color(hex: "C44569"),
    ]

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        // Preview
                        categoryPreview

                        // Name Input
                        nameSection

                        // Color Picker
                        colorSection

                        // Icon Picker
                        iconSection

                        // Save Button
                        saveButton
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Category Preview

    private var categoryPreview: some View {
        VStack(spacing: Constants.Spacing.md) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: selectedIcon)
                    .font(.system(size: 50))
                    .foregroundColor(selectedColor)
            }

            Text(categoryName.isEmpty ? "Category Name" : categoryName)
                .font(.system(size: Constants.FontSize.title, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(Constants.Spacing.xl)
        .cardStyle()
    }

    // MARK: - Name Section

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Category Name")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            TextField("Enter category name", text: $categoryName)
                .padding(Constants.Spacing.md)
                .cardStyle()
        }
    }

    // MARK: - Color Section

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Color")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 8),
                spacing: Constants.Spacing.sm
            ) {
                ForEach(availableColors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 2)
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding(Constants.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.sm) {
            Text("Icon")
                .font(.system(size: Constants.FontSize.body, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible()), count: 6),
                spacing: Constants.Spacing.md
            ) {
                ForEach(availableIcons, id: \.self) { icon in
                    ZStack {
                        Circle()
                            .fill(
                                selectedIcon == icon
                                    ? selectedColor.opacity(0.2) : Color.gray.opacity(0.1)
                            )
                            .frame(width: 50, height: 50)

                        Image(systemName: icon)
                            .font(.system(size: 24))
                            .foregroundColor(
                                selectedIcon == icon
                                    ? selectedColor : Constants.Colors.textSecondary)
                    }
                    .onTapGesture {
                        selectedIcon = icon
                    }
                }
            }
            .padding(Constants.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: {
            let colorHex = selectedColor.toHex() ?? "6C63FF"
            onSave(categoryName, colorHex, selectedIcon)
        }) {
            Text("Add Category")
        }
        .primaryButtonStyle()
        .disabled(categoryName.trimmed.isEmpty)
        .opacity(categoryName.trimmed.isEmpty ? 0.5 : 1.0)
    }
}

// MARK: - Preview
#Preview {
    AddCategoryView { _, _, _ in }
}
