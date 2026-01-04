//
//  PINSetupView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct PINSetupView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var pin: String = ""
    @State private var confirmPin: String = ""
    @State private var isConfirming: Bool = false
    @State private var errorMessage: String?

    private let pinLength = 4

    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea()

            VStack(spacing: Constants.Spacing.xl) {
                Spacer()

                // Title
                Text(isConfirming ? "Confirm PIN" : "Create PIN")
                    .font(.system(size: Constants.FontSize.largeTitle, weight: .bold))
                    .foregroundColor(Constants.Colors.textPrimary)

                Text(isConfirming ? "Enter your PIN again" : "Enter a 4-digit PIN")
                    .font(.system(size: Constants.FontSize.body))
                    .foregroundColor(Constants.Colors.textSecondary)

                // PIN Dots
                pinDotsView

                // Error Message
                if let error = errorMessage {
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
    }

    // MARK: - PIN Dots View

    private var pinDotsView: some View {
        HStack(spacing: Constants.Spacing.md) {
            ForEach(0..<pinLength, id: \.self) { index in
                Circle()
                    .fill(
                        index < currentPIN.count
                            ? Constants.Colors.primary : Color.gray.opacity(0.3)
                    )
                    .frame(width: 20, height: 20)
            }
        }
        .padding(Constants.Spacing.lg)
    }

    private var currentPIN: String {
        isConfirming ? confirmPin : pin
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
                    if isConfirming {
                        if !confirmPin.isEmpty {
                            confirmPin.removeLast()
                        }
                    } else {
                        if !pin.isEmpty {
                            pin.removeLast()
                        }
                    }
                    errorMessage = nil
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
            errorMessage = nil

            if isConfirming {
                if confirmPin.count < pinLength {
                    confirmPin += number

                    if confirmPin.count == pinLength {
                        verifyAndSavePIN()
                    }
                }
            } else {
                if pin.count < pinLength {
                    pin += number

                    if pin.count == pinLength {
                        // Move to confirmation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isConfirming = true
                        }
                    }
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

    // MARK: - Verify and Save PIN

    private func verifyAndSavePIN() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if pin == confirmPin {
                if viewModel.setupPIN(pin) {
                    dismiss()
                } else {
                    errorMessage = "Failed to save PIN. Please try again."
                    resetPINs()
                }
            } else {
                errorMessage = "PINs don't match. Please try again."
                resetPINs()
            }
        }
    }

    private func resetPINs() {
        pin = ""
        confirmPin = ""
        isConfirming = false
    }
}

// MARK: - Preview
#Preview {
    PINSetupView(viewModel: AuthenticationViewModel())
}
