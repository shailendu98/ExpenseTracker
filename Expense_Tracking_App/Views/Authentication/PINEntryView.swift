//
//  PINEntryView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct PINEntryView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pin: String = ""
    @FocusState private var isPINFocused: Bool

    private let pinLength = 4

    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea()

            VStack(spacing: Constants.Spacing.xl) {
                Spacer()

                // Title
                Text("Enter PIN")
                    .font(.system(size: Constants.FontSize.largeTitle, weight: .bold))
                    .foregroundColor(Constants.Colors.textPrimary)

                // PIN Dots
                pinDotsView

                // Error Message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.system(size: Constants.FontSize.caption))
                        .foregroundColor(Constants.Colors.error)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Number Pad
                numberPad

                // Cancel Button
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(Constants.Colors.textSecondary)
                .padding(.bottom, Constants.Spacing.lg)
            }
            .padding(Constants.Spacing.lg)
        }
        .onAppear {
            isPINFocused = true
        }
    }

    // MARK: - PIN Dots View

    private var pinDotsView: some View {
        HStack(spacing: Constants.Spacing.md) {
            ForEach(0..<pinLength, id: \.self) { index in
                Circle()
                    .fill(index < pin.count ? Constants.Colors.primary : Color.gray.opacity(0.3))
                    .frame(width: 20, height: 20)
            }
        }
        .padding(Constants.Spacing.lg)
    }

    // MARK: - Number Pad

    private var numberPad: some View {
        VStack(spacing: Constants.Spacing.md) {
            ForEach(0..<3) { row in
                HStack(spacing: Constants.Spacing.md) {
                    ForEach(1..<4) { col in
                        let number = row * 3 + col
                        numberButton(String(number))
                    }
                }
            }

            HStack(spacing: Constants.Spacing.md) {
                // Empty space
                Color.clear
                    .frame(width: 80, height: 80)

                // Zero button
                numberButton("0")

                // Delete button
                Button(action: {
                    if !pin.isEmpty {
                        pin.removeLast()
                    }
                }) {
                    Image(systemName: "delete.left.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Constants.Colors.textPrimary)
                        .frame(width: 80, height: 80)
                        .background(Constants.Colors.cardBackground)
                        .cornerRadius(40)
                }
            }
        }
    }

    // MARK: - Number Button

    private func numberButton(_ number: String) -> some View {
        Button(action: {
            if pin.count < pinLength {
                pin += number

                if pin.count == pinLength {
                    verifyPIN()
                }
            }
        }) {
            Text(number)
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(Constants.Colors.textPrimary)
                .frame(width: 80, height: 80)
                .background(Constants.Colors.cardBackground)
                .cornerRadius(40)
        }
    }

    // MARK: - Verify PIN

    private func verifyPIN() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if viewModel.authenticateWithPIN(pin) {
                dismiss()
            } else {
                // Shake animation on error
                withAnimation(.default) {
                    pin = ""
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PINEntryView(viewModel: AuthenticationViewModel())
}
