//
//  CategoryObject.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation
import RealmSwift

class CategoryObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var colorHex: String
    @Persisted var iconName: String
    @Persisted var isCustom: Bool
    @Persisted var createdAt: Date

    convenience init(from category: Category) {
        self.init()
        self.id = category.id
        self.name = category.name
        self.colorHex = category.colorHex
        self.iconName = category.iconName
        self.isCustom = category.isCustom
        self.createdAt = category.createdAt
    }

    func toCategory() -> Category {
        return Category(
            id: id,
            name: name,
            colorHex: colorHex,
            iconName: iconName,
            isCustom: isCustom,
            createdAt: createdAt
        )
    }
}
