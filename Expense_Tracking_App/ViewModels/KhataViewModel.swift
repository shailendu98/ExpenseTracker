//
//  KhataViewModel.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import Foundation
import Combine

@MainActor
class KhataViewModel: ObservableObject {
    @Published var persons: [KhataPerson] = []
    @Published var entriesMap: [UUID: [KhataEntry]] = [:]
    @Published var errorMessage: String?

    private let realmManager = RealmManager.shared

    // MARK: - Load
    func loadData() {
        do {
            let fetchedPersons = try realmManager.fetchKhataPersons()
            self.persons = fetchedPersons

            // Load entries for each person
            var map: [UUID: [KhataEntry]] = [:]
            for person in fetchedPersons {
                map[person.id] = try realmManager.fetchKhataEntries(for: person.id)
            }
            self.entriesMap = map
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Person Operations
    func addPerson(name: String, phone: String, emoji: String) {
        let person = KhataPerson(name: name.trimmed, phone: phone.trimmed, emoji: emoji)
        do {
            try realmManager.createKhataPerson(person)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePerson(_ person: KhataPerson) {
        do {
            try realmManager.deleteKhataPerson(person)
            loadData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Entry Operations
    func addEntry(to person: KhataPerson, amount: Double, type: KhataEntryType, note: String, date: Date) {
        let entry = KhataEntry(
            personId: person.id,
            amount: amount,
            type: type,
            note: note,
            date: date
        )
        do {
            try realmManager.createKhataEntry(entry)
            // Reload entries for this person
            entriesMap[person.id] = try realmManager.fetchKhataEntries(for: person.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteEntry(_ entry: KhataEntry) {
        do {
            try realmManager.deleteKhataEntry(entry)
            entriesMap[entry.personId] = try realmManager.fetchKhataEntries(for: entry.personId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Balance Helpers

    func entries(for person: KhataPerson) -> [KhataEntry] {
        entriesMap[person.id] ?? []
    }

    /// Positive = they owe you | Negative = you owe them
    func netBalance(for person: KhataPerson) -> Double {
        entries(for: person).reduce(0.0) { sum, entry in
            sum + (entry.amount * entry.type.sign)
        }
    }

    /// Total amount you need to receive from all persons
    var totalToReceive: Double {
        persons.reduce(0.0) { total, person in
            let balance = netBalance(for: person)
            return total + (balance > 0 ? balance : 0)
        }
    }

    /// Total amount you owe across all persons
    var totalToGive: Double {
        persons.reduce(0.0) { total, person in
            let balance = netBalance(for: person)
            return total + (balance < 0 ? abs(balance) : 0)
        }
    }

    func balanceLabel(for balance: Double) -> String {
        if balance > 0 {
            return "Will Get ₹\(String(format: "%.0f", balance))"
        } else if balance < 0 {
            return "Will Give ₹\(String(format: "%.0f", abs(balance)))"
        } else {
            return "Settled ✓"
        }
    }
}
