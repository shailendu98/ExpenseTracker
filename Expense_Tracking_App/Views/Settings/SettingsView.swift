//
//  SettingsView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var showPINSetup = false
    @State private var showPINVerification = false
    @State private var showResetSuccess = false

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Constants.Spacing.lg) {
                        // Authentication Status Section
                        authenticationStatusSection

                        // Biometric Section
                        if authViewModel.isBiometricAvailable {
                            biometricSection
                        }

                        // PIN Section
                        pinSection

                        // Reset Section
                        resetSection
                    }
                    .padding(Constants.Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPINSetup) {
                PINSetupView(viewModel: authViewModel)
            }
            .sheet(isPresented: $showPINVerification) {
                PINVerificationView(
                    onSuccess: {
                        showPINVerification = false
                        authViewModel.resetAuthentication()
                        showResetSuccess = true
                    },
                    onCancel: {
                        showPINVerification = false
                    }
                )
            }
            .alert("Authentication Reset", isPresented: $showResetSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "Your authentication has been reset successfully. You can set up a new PIN anytime."
                )
            }
        }
    }

    // MARK: - Authentication Status Section

    private var authenticationStatusSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Security Status")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            HStack {
                Image(
                    systemName: authViewModel.isAuthenticationRequired
                        ? "lock.shield.fill" : "lock.open.fill"
                )
                .font(.system(size: 40))
                .foregroundColor(
                    authViewModel.isAuthenticationRequired
                        ? Constants.Colors.success : Constants.Colors.textSecondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(authViewModel.isAuthenticationRequired ? "Protected" : "Not Protected")
                        .font(.system(size: Constants.FontSize.body, weight: .semibold))
                        .foregroundColor(Constants.Colors.textPrimary)

                    Text(
                        authViewModel.isAuthenticationRequired
                            ? "Your data is secure" : "Enable authentication to protect your data"
                    )
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(Constants.Colors.textSecondary)
                }

                Spacer()
            }
            .padding(Constants.Spacing.md)
            .cardStyle()
        }
    }

    // MARK: - Biometric Section

    private var biometricSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text(authViewModel.biometricType.displayName)
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            VStack(spacing: Constants.Spacing.sm) {
                HStack {
                    Image(systemName: authViewModel.biometricType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Constants.Colors.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(authViewModel.biometricType.displayName) Available")
                            .font(.system(size: Constants.FontSize.body, weight: .medium))
                            .foregroundColor(Constants.Colors.textPrimary)

                        Text("Use \(authViewModel.biometricType.displayName) to unlock the app")
                            .font(.system(size: Constants.FontSize.caption))
                            .foregroundColor(Constants.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Constants.Colors.success)
                }
                .padding(Constants.Spacing.md)
                .cardStyle()
            }
        }
    }

    // MARK: - PIN Section

    private var pinSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("PIN Code")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            VStack(spacing: Constants.Spacing.sm) {
                // PIN Status
                HStack {
                    Image(systemName: "key.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Constants.Colors.primary)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(authViewModel.isPINSet ? "PIN Enabled" : "PIN Not Set")
                            .font(.system(size: Constants.FontSize.body, weight: .medium))
                            .foregroundColor(Constants.Colors.textPrimary)

                        Text(
                            authViewModel.isPINSet
                                ? "4-digit PIN is active" : "Set up a PIN for security"
                        )
                        .font(.system(size: Constants.FontSize.caption))
                        .foregroundColor(Constants.Colors.textSecondary)
                    }

                    Spacer()

                    if authViewModel.isPINSet {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Constants.Colors.success)
                    }
                }
                .padding(Constants.Spacing.md)
                .cardStyle()

                // Change/Set PIN Button
                Button(action: {
                    showPINSetup = true
                }) {
                    HStack {
                        Image(
                            systemName: authViewModel.isPINSet
                                ? "arrow.triangle.2.circlepath" : "plus.circle.fill")
                        Text(authViewModel.isPINSet ? "Change PIN" : "Set Up PIN")
                    }
                }
                .primaryButtonStyle()
            }
        }
    }

    // MARK: - Reset Section

    private var resetSection: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Text("Advanced")
                .font(.system(size: Constants.FontSize.title, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)

            Button(action: {
                showPINVerification = true
            }) {
                HStack {
                    Image(systemName: "trash.fill")
                    Text("Reset Authentication")
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Constants.Colors.error)
            .cornerRadius(Constants.CornerRadius.md)
            .disabled(!authViewModel.isPINSet && !authViewModel.isBiometricAvailable)
            .opacity((!authViewModel.isPINSet && !authViewModel.isBiometricAvailable) ? 0.5 : 1.0)
        }
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AuthenticationViewModel())
}
