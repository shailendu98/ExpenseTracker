//
//  PINVerificationView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct PINVerificationView: View {
    var onSuccess: () -> Void
    var onCancel: () -> Void

    @State private var pin: String = ""
    @State private var errorMessage: String?
    @FocusState private var isPINFocused: Bool

    private let pinLength = 4
    private let encryptionService = EncryptionService.shared

    var body: some View {
        ZStack {
            Constants.Colors.background.ignoresSafeArea()

            VStack(spacing: Constants.Spacing.xl) {
                Spacer()

                // Title
                VStack(spacing: Constants.Spacing.sm) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Constants.Colors.error)

                    Text("Verify Your PIN")
                        .font(.system(size: Constants.FontSize.largeTitle, weight: .bold))
                        .foregroundColor(Constants.Colors.textPrimary)

                    Text("Enter your current PIN to reset authentication")
                        .font(.system(size: Constants.FontSize.body))
                        .foregroundColor(Constants.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Spacing.xl)
                }

                // PIN Dots
                pinDotsView

                // Error Message
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: Constants.FontSize.caption))
                        .foregroundColor(Constants.Colors.error)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Constants.Spacing.lg)
                }

                Spacer()

                // Number Pad
                numberPad

                // Cancel Button
                Button("Cancel") {
                    onCancel()
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
                    .fill(index < pin.count ? Constants.Colors.error : Color.gray.opacity(0.3))
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
                        errorMessage = nil
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
            errorMessage = nil

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
            if encryptionService.validatePIN(pin) {
                // PIN is correct, call success callback
                onSuccess()
            } else {
                // PIN is incorrect
                errorMessage = "Incorrect PIN. Please try again."
                withAnimation(.default) {
                    pin = ""
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PINVerificationView(
        onSuccess: { print("Success") },
        onCancel: { print("Cancelled") }
    )
}
