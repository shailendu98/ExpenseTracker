//
//  RealmManager+Khata.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import Foundation
import RealmSwift

// MARK: - Khata CRUD Extension
extension RealmManager {

    // MARK: - Person Operations

    func createKhataPerson(_ person: KhataPerson) throws {
        let realm = self.realm
        let object = KhataPersonObject(from: person)
        try realm.write {
            realm.add(object)
        }
    }

    func fetchKhataPersons() throws -> [KhataPerson] {
        let realm = self.realm
        let results = realm.objects(KhataPersonObject.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
        return Array(results.map { $0.toKhataPerson() })
    }

    func deleteKhataPerson(_ person: KhataPerson) throws {
        let realm = self.realm

        guard let personObject = realm.object(
            ofType: KhataPersonObject.self, forPrimaryKey: person.id)
        else { throw RealmError.transactionNotFound }

        // Delete entries and person in a single atomic write
        let entries = realm.objects(KhataEntryObject.self)
            .filter("personId == %@", person.id)

        try realm.write {
            realm.delete(entries)
            realm.delete(personObject)
        }
    }

    // MARK: - Entry Operations

    func createKhataEntry(_ entry: KhataEntry) throws {
        let realm = self.realm
        let object = KhataEntryObject(from: entry)
        try realm.write {
            realm.add(object)
        }
    }

    func fetchKhataEntries(for personId: UUID) throws -> [KhataEntry] {
        let realm = self.realm
        let results = realm.objects(KhataEntryObject.self)
            .filter("personId == %@", personId)
            .sorted(byKeyPath: "date", ascending: false)
        return Array(results.map { $0.toKhataEntry() })
    }

    func deleteKhataEntry(_ entry: KhataEntry) throws {
        let realm = self.realm
        guard let object = realm.object(
            ofType: KhataEntryObject.self, forPrimaryKey: entry.id)
        else { throw RealmError.transactionNotFound }

        try realm.write {
            realm.delete(object)
        }
    }

    // MARK: - Balance Calculation

    /// Net balance for a person.
    /// Positive = they owe you (you gave more than you received)
    /// Negative = you owe them
    func netBalance(for personId: UUID) throws -> Double {
        let entries = try fetchKhataEntries(for: personId)
        return entries.reduce(0.0) { sum, entry in
            sum + (entry.amount * entry.type.sign)
        }
    }
}
