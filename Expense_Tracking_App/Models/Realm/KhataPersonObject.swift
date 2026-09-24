//
//  KhataPersonObject.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import Foundation
import RealmSwift

class KhataPersonObject: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var name: String
    @Persisted var phone: String
    @Persisted var emoji: String
    @Persisted var createdAt: Date

    convenience init(from person: KhataPerson) {
        self.init()
        self.id = person.id
        self.name = person.name
        self.phone = person.phone
        self.emoji = person.emoji
        self.createdAt = person.createdAt
    }

    func toKhataPerson() -> KhataPerson {
        return KhataPerson(
            id: id,
            name: name,
            phone: phone,
            emoji: emoji,
            createdAt: createdAt
        )
    }
}
