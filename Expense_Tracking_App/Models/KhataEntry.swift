//
//  KhataEntry.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import Foundation
import SwiftUI

// MARK: - Entry Type
enum KhataEntryType: String, CaseIterable, Codable {
    case gave     = "gave"
    case received = "received"

    var label: String {
        switch self {
        case .gave:     return "Gave"
        case .received: return "Received"
        }
    }

    var icon: String {
        switch self {
        case .gave:     return "arrow.up.right"
        case .received: return "arrow.down.left"
        }
    }

    var color: Color {
        switch self {
        case .gave:     return Color(hex: "#FF5C5C")
        case .received: return Color(hex: "#34C97A")
        }
    }

    /// Sign multiplier for balance calculation
    /// Gave → you gave money → balance = negative (they owe you)
    /// Received → you got money back → balance = positive (settles debt)
    var sign: Double {
        switch self {
        case .gave:     return 1.0   // positive means they owe you
        case .received: return -1.0  // negative means debt decreases
        }
    }
}

// MARK: - KhataEntry Struct
struct KhataEntry: Identifiable, Hashable {
    let id: UUID
    var personId: UUID
    var amount: Double
    var type: KhataEntryType
    var note: String
    var date: Date
    var createdAt: Date

    init(
        id: UUID = UUID(),
        personId: UUID,
        amount: Double,
        type: KhataEntryType,
        note: String = "",
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.personId = personId
        self.amount = amount
        self.type = type
        self.note = note
        self.date = date
        self.createdAt = createdAt
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "₹\(amount)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
