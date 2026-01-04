//
//  Expense_Tracking_AppApp.swift
//  Expense_Tracking_App
//
//  Created by iB Arts Pvt. Ltd. on 26/12/25.
//

import SwiftUI

@main
struct Expense_Tracking_AppApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // Lock app when going to background
                authViewModel.lockApp()
            }
        }
    }
}
