//
//  Constants.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct Constants {
    
    // MARK: - App Info
    static let appName = "Expense Tracker"
    
    // MARK: - Predefined Categories
    struct PredefinedCategories {
        static let categories: [(name: String, color: String, icon: String)] = [
            ("Food & Dining", "FF6B6B", "fork.knife"),
            ("Transportation", "4ECDC4", "car.fill"),
            ("Entertainment", "95E1D3", "tv.fill"),
            ("Shopping", "F38181", "cart.fill"),
            ("Bills & Utilities", "AA96DA", "doc.text.fill"),
            ("Health & Fitness", "FCBAD3", "heart.fill"),
            ("Education", "FFA07A", "book.fill"),
            ("Other", "A8E6CF", "ellipsis.circle.fill")
        ]
    }
    
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "6C63FF")
        static let secondary = Color(hex: "4ECDC4")
        static let accent = Color(hex: "FF6B6B")
        static let background = Color(hex: "F7F7F7")
        static let cardBackground = Color.white
        static let textPrimary = Color(hex: "2D3436")
        static let textSecondary = Color(hex: "636E72")
        static let success = Color(hex: "00B894")
        static let error = Color(hex: "D63031")
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let title: CGFloat = 20
        static let largeTitle: CGFloat = 28
    }
    
    // MARK: - Animation
    struct Animation {
        static let short: Double = 0.2
        static let medium: Double = 0.3
        static let long: Double = 0.5
    }
    
    // MARK: - Validation
    struct Validation {
        static let maxDescriptionLength = 200
        static let maxCategoryNameLength = 30
        static let maxAmount: Double = 999999.99
    }
}
