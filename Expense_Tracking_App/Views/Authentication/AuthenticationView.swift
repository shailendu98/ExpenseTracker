//
//  AuthenticationView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct AuthenticationView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var showPINSetup = false

    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [Constants.Colors.primary, Constants.Colors.secondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: Constants.Spacing.xl) {
                Spacer()

                // App Icon/Logo
                appLogo

                // Welcome Text
                welcomeText

                Spacer()

                // Authentication Buttons
                authenticationButtons

                Spacer()
            }
            .padding(Constants.Spacing.xl)
        }
        .sheet(isPresented: $viewModel.showPINEntry) {
            PINEntryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showPINSetup) {
            PINSetupView(viewModel: viewModel)
        }
    }

    // MARK: - App Logo

    private var appLogo: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.2))
                .frame(width: 120, height: 120)

            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)
        }
    }

    // MARK: - Welcome Text

    private var welcomeText: some View {
        VStack(spacing: Constants.Spacing.sm) {
            Text("Expense Tracker")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Secure your financial data")
                .font(.system(size: Constants.FontSize.body))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    // MARK: - Authentication Buttons

    private var authenticationButtons: some View {
        VStack(spacing: Constants.Spacing.md) {
            // Biometric Authentication Button
            if viewModel.isBiometricAvailable {
                Button(action: {
                    viewModel.authenticateWithBiometrics()
                }) {
                    HStack {
                        Image(systemName: viewModel.biometricType.icon)
                            .font(.system(size: 24))

                        Text("Unlock with \(viewModel.biometricType.displayName)")
                            .font(.system(size: Constants.FontSize.body, weight: .semibold))
                    }
                    .foregroundColor(Constants.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(Constants.CornerRadius.md)
                }
            }

            // PIN Entry Button
            if viewModel.isPINSet {
                Button(action: {
                    viewModel.showPINEntry = true
                }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))

                        Text("Enter PIN")
                            .font(.system(size: Constants.FontSize.body, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(Constants.CornerRadius.md)
                }
            } else {
                // Setup PIN Button (first time)
                Button(action: {
                    showPINSetup = true
                }) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))

                        Text("Set up PIN")
                            .font(.system(size: Constants.FontSize.body, weight: .semibold))
                    }
                    .foregroundColor(Constants.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(Constants.CornerRadius.md)
                }
            }

            // Skip Button (first time only)
            if !viewModel.isPINSet && !viewModel.isBiometricAvailable {
                Button(action: {
                    viewModel.skipAuthentication()
                }) {
                    Text("Skip for now")
                        .font(.system(size: Constants.FontSize.body))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, Constants.Spacing.sm)
            }

            // Error Message
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, Constants.Spacing.sm)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AuthenticationView(viewModel: AuthenticationViewModel())
}
