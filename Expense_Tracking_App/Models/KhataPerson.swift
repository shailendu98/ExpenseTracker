//
//  KhataPerson.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import Foundation

// MARK: - KhataPerson Struct
struct KhataPerson: Identifiable, Hashable {
    let id: UUID
    var name: String
    var phone: String
    var emoji: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        emoji: String = "👤",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.emoji = emoji
        self.createdAt = createdAt
    }

    /// Initials from name for avatar fallback
    var initials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
