//
//  BiometricAuthService.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation
import LocalAuthentication

class BiometricAuthService {
    static let shared = BiometricAuthService()

    private init() {}

    // MARK: - Biometric Availability

    func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }

    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    // MARK: - Authentication

    func authenticateWithBiometrics(
        reason: String = "Authenticate to access your expenses",
        completion: @escaping (Result<Bool, AuthenticationError>) -> Void
    ) {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        else {
            if let error = error {
                completion(.failure(.biometricNotAvailable(error.localizedDescription)))
            } else {
                completion(
                    .failure(.biometricNotAvailable("Biometric authentication not available")))
            }
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
            success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(true))
                } else {
                    if let error = error as? LAError {
                        completion(.failure(self.handleLAError(error)))
                    } else {
                        completion(.failure(.unknown))
                    }
                }
            }
        }
    }

    func authenticateWithDevicePasscode(
        reason: String = "Authenticate to access your expenses",
        completion: @escaping (Result<Bool, AuthenticationError>) -> Void
    ) {
        let context = LAContext()

        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
            success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(true))
                } else {
                    if let error = error as? LAError {
                        completion(.failure(self.handleLAError(error)))
                    } else {
                        completion(.failure(.unknown))
                    }
                }
            }
        }
    }

    // MARK: - Error Handling

    private func handleLAError(_ error: LAError) -> AuthenticationError {
        switch error.code {
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancelled
        case .userFallback:
            return .userFallback
        case .biometryNotAvailable:
            return .biometricNotAvailable("Biometric authentication not available")
        case .biometryNotEnrolled:
            return .biometricNotEnrolled
        case .biometryLockout:
            return .biometricLockout
        default:
            return .unknown
        }
    }
}

// MARK: - Biometric Type
enum BiometricType {
    case none
    case touchID
    case faceID

    var displayName: String {
        switch self {
        case .none:
            return "None"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        }
    }

    var icon: String {
        switch self {
        case .none:
            return "lock.fill"
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        }
    }
}

// MARK: - Authentication Error
enum AuthenticationError: LocalizedError {
    case biometricNotAvailable(String)
    case biometricNotEnrolled
    case biometricLockout
    case authenticationFailed
    case userCancelled
    case userFallback
    case unknown

    var errorDescription: String? {
        switch self {
        case .biometricNotAvailable(let message):
            return message
        case .biometricNotEnrolled:
            return "Biometric authentication is not set up on this device"
        case .biometricLockout:
            return "Biometric authentication is locked. Please try again later"
        case .authenticationFailed:
            return "Authentication failed. Please try again"
        case .userCancelled:
            return "Authentication was cancelled"
        case .userFallback:
            return "User chose to enter passcode"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
