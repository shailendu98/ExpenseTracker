//
//  Category.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct Category: Identifiable, Hashable {
    let id: UUID
    var name: String
    var colorHex: String
    var iconName: String
    var isCustom: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        iconName: String,
        isCustom: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.isCustom = isCustom
        self.createdAt = createdAt
    }

    var color: Color {
        Color(hex: colorHex)
    }
}

// MARK: - Predefined Categories
extension Category {
    static var predefined: [Category] {
        Constants.PredefinedCategories.categories.map { item in
            Category(
                name: item.name,
                colorHex: item.color,
                iconName: item.icon,
                isCustom: false
            )
        }
    }

    static var sample: Category {
        Category(
            name: "Food & Dining",
            colorHex: "FF6B6B",
            iconName: "fork.knife",
            isCustom: false
        )
    }
}
