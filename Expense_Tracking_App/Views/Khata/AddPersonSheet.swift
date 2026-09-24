//
//  AddPersonSheet.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import SwiftUI

struct AddPersonSheet: View {
    @ObservedObject var viewModel: KhataViewModel
    @Binding var isPresented: Bool

    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var selectedEmoji: String = "👤"
    @State private var nameError: String = ""

    private let emojis = ["👤","👨","👩","👦","👧","👨‍💼","👩‍💼","🧑‍🤝‍🧑","👨‍👩‍👧","🧑","👴","👵","🤝","👨‍🦱","👩‍🦱"]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Avatar Preview
                    avatarPreview

                    // MARK: Emoji Picker
                    emojiPicker

                    // MARK: Fields
                    VStack(spacing: 16) {
                        inputField(
                            title: "Name *",
                            placeholder: "Enter person's name",
                            text: $name,
                            keyboardType: .default,
                            error: nameError
                        )

                        inputField(
                            title: "Phone (optional)",
                            placeholder: "Enter phone number",
                            text: $phone,
                            keyboardType: .phonePad,
                            error: ""
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
                .padding(.top, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.primary)
                    .disabled(name.trimmed.isEmpty)
                }
            }
        }
    }

    // MARK: - Avatar Preview
    private var avatarPreview: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Constants.Colors.primary.opacity(0.8), Constants.Colors.primary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 90, height: 90)
                .shadow(color: Constants.Colors.primary.opacity(0.4), radius: 16, x: 0, y: 8)

            Text(selectedEmoji)
                .font(.system(size: 42))
        }
    }

    // MARK: - Emoji Picker
    private var emojiPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose Avatar")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedEmoji = emoji
                            }
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 52, height: 52)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(selectedEmoji == emoji
                                              ? Constants.Colors.primary.opacity(0.15)
                                              : Color(.secondarySystemGroupedBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(selectedEmoji == emoji
                                                        ? Constants.Colors.primary
                                                        : Color.clear, lineWidth: 2)
                                        )
                                )
                                .scaleEffect(selectedEmoji == emoji ? 1.1 : 1.0)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Input Field
    @ViewBuilder
    private func inputField(title: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType, error: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .default ? .words : .none)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .font(.system(size: 16))

            if !error.isEmpty {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - Save
    private func save() {
        guard name.trimmed.isNotEmpty else {
            nameError = "Name is required"
            return
        }
        nameError = ""
        viewModel.addPerson(name: name, phone: phone, emoji: selectedEmoji)
        isPresented = false
    }
}
