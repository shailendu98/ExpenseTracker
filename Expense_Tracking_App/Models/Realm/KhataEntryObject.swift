//
//  KhataEntryObject.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import Foundation
import RealmSwift

class KhataEntryObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var personId: UUID
    @Persisted var amount: Double
    @Persisted var type: String   // "gave" or "received"
    @Persisted var note: String
    @Persisted var date: Date
    @Persisted var createdAt: Date

    convenience init(from entry: KhataEntry) {
        self.init()
        self.id = entry.id
        self.personId = entry.personId
        self.amount = entry.amount
        self.type = entry.type.rawValue
        self.note = entry.note
        self.date = entry.date
        self.createdAt = entry.createdAt
    }

    func toKhataEntry() -> KhataEntry {
        return KhataEntry(
            id: id,
            personId: personId,
            amount: amount,
            type: KhataEntryType(rawValue: type) ?? .gave,
            note: note,
            date: date,
            createdAt: createdAt
        )
    }
}
