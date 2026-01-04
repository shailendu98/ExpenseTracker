//
//  AuthenticationViewModel.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Combine
import Foundation

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var showPINEntry: Bool = false
    @Published var errorMessage: String?
    @Published var isAuthenticationRequired: Bool = true

    private let biometricService = BiometricAuthService.shared
    private let encryptionService = EncryptionService.shared

    var biometricType: BiometricType {
        biometricService.biometricType()
    }

    var isBiometricAvailable: Bool {
        biometricService.isBiometricAvailable()
    }

    var isPINSet: Bool {
        encryptionService.isPINSet()
    }

    init() {
        // For first-time users, don't require authentication
        if !isPINSet && !isBiometricAvailable {
            isAuthenticationRequired = false
            isAuthenticated = true
        }
    }

    // MARK: - Authenticate with Biometrics

    func authenticateWithBiometrics() {
        errorMessage = nil

        biometricService.authenticateWithBiometrics { [weak self] result in
            switch result {
            case .success:
                self?.isAuthenticated = true
                self?.errorMessage = nil
            case .failure(let error):
                if case .userFallback = error {
                    self?.showPINEntry = true
                } else if case .userCancelled = error {
                    // User cancelled, don't show error
                    self?.errorMessage = nil
                } else {
                    self?.errorMessage = error.localizedDescription
                    // Fallback to PIN if biometric fails
                    if self?.isPINSet == true {
                        self?.showPINEntry = true
                    }
                }
            }
        }
    }

    // MARK: - Authenticate with PIN

    func authenticateWithPIN(_ pin: String) -> Bool {
        errorMessage = nil

        if encryptionService.validatePIN(pin) {
            isAuthenticated = true
            showPINEntry = false
            return true
        } else {
            errorMessage = "Incorrect PIN. Please try again."
            return false
        }
    }

    // MARK: - Setup PIN

    func setupPIN(_ pin: String) -> Bool {
        errorMessage = nil

        if pin.count < 4 {
            errorMessage = "PIN must be at least 4 digits"
            return false
        }

        if encryptionService.savePIN(pin) {
            isAuthenticationRequired = true
            isAuthenticated = true
            return true
        } else {
            errorMessage = "Failed to save PIN"
            return false
        }
    }

    // MARK: - Lock App

    func lockApp() {
        if isAuthenticationRequired {
            isAuthenticated = false
            errorMessage = nil
            showPINEntry = false
        }
    }

    // MARK: - Skip Authentication (First Time)

    func skipAuthentication() {
        isAuthenticationRequired = false
        isAuthenticated = true
    }

    // MARK: - Reset Authentication

    func resetAuthentication() {
        _ = encryptionService.deletePIN()
        isAuthenticationRequired = false
        isAuthenticated = true  // Allow user to continue using app
        errorMessage = nil
    }
}
