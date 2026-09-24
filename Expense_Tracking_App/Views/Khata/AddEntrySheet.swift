//
//  AddEntrySheet.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import SwiftUI

struct AddEntrySheet: View {
    @ObservedObject var viewModel: KhataViewModel
    let person: KhataPerson
    @Binding var isPresented: Bool

    @State private var selectedType: KhataEntryType = .gave
    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var selectedDate: Date = Date()
    @State private var amountError: String = ""
    @FocusState private var amountFocused: Bool

    private var amount: Double { Double(amountText) ?? 0 }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: Type Toggle
                    typeToggle
                        .padding(.top, 8)

                    // MARK: Amount Card
                    amountCard

                    // MARK: Fields
                    VStack(spacing: 16) {
                        noteField
                        dateField
                    }
                    .padding(.horizontal, 20)

                    // MARK: Save Button
                    saveButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
            }
            .onAppear { amountFocused = true }
        }
    }

    // MARK: - Type Toggle
    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach(KhataEntryType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedType = type
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: type.icon)
                            .font(.system(size: 14, weight: .semibold))
                        Text(type.label)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(
                        selectedType == type
                        ? type.color
                        : Color(.secondarySystemGroupedBackground)
                    )
                    .foregroundColor(selectedType == type ? .white : .secondary)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Amount Card
    private var amountCard: some View {
        VStack(spacing: 6) {
            Text("Amount")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("₹")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(selectedType.color)

                TextField("0", text: $amountText)
                    .focused($amountFocused)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(selectedType.color)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 220)
            }

            if !amountError.isEmpty {
                Text(amountError)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(selectedType.color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(selectedType.color.opacity(0.25), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: selectedType)
    }

    // MARK: - Note Field
    private var noteField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Note (optional)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            TextField("Add a note...", text: $note)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .font(.system(size: 16))
        }
    }

    // MARK: - Date Field
    private var dateField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            save()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: selectedType.icon)
                    .font(.system(size: 16, weight: .semibold))
                Text("Save Entry")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [selectedType.color, selectedType.color.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .shadow(color: selectedType.color.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .animation(.easeInOut(duration: 0.2), value: selectedType)
    }

    // MARK: - Save
    private func save() {
        guard amount > 0 else {
            amountError = "Please enter a valid amount"
            return
        }
        amountError = ""
        viewModel.addEntry(to: person, amount: amount, type: selectedType, note: note, date: selectedDate)
        isPresented = false
    }
}
