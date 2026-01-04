//
//  EncryptionService.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Foundation
import Security

class EncryptionService {
    static let shared = EncryptionService()

    private init() {}

    // MARK: - Keychain Operations

    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete any existing item
        _ = delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        else {
            return nil
        }

        return value
    }

    func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - PIN Management

    private let pinKey = "user_pin_code"

    func savePIN(_ pin: String) -> Bool {
        return save(key: pinKey, value: pin)
    }

    func retrievePIN() -> String? {
        return retrieve(key: pinKey)
    }

    func deletePIN() -> Bool {
        return delete(key: pinKey)
    }

    func isPINSet() -> Bool {
        return retrievePIN() != nil
    }

    func validatePIN(_ pin: String) -> Bool {
        guard let storedPIN = retrievePIN() else { return false }
        return storedPIN == pin
    }
}

// MARK: - Keychain Keys
extension EncryptionService {
    struct KeychainKeys {
        static let userPIN = "user_pin_code"
        static let authEnabled = "auth_enabled"
        static let biometricEnabled = "biometric_enabled"
    }
}
