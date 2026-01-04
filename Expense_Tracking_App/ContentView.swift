//
//  ContentView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {
                // Main App Content
                TabView(selection: $selectedTab) {
                    // Transactions Tab
                    TransactionHistoryView()
                        .tabItem {
                            Label("Transactions", systemImage: "list.bullet")
                        }
                        .tag(0)

                    // Add Expense Tab
                    AddExpenseView {
                        // Switch to transactions tab after adding
                        selectedTab = 0
                    }
                    .tabItem {
                        Label("Add", systemImage: "plus.circle.fill")
                    }
                    .tag(1)

                    // Reports Tab
                    SummaryReportsView()
                        .tabItem {
                            Label("Reports", systemImage: "chart.pie.fill")
                        }
                        .tag(2)

                    // Categories Tab
                    CategoryManagementView()
                        .tabItem {
                            Label("Categories", systemImage: "square.grid.2x2.fill")
                        }
                        .tag(3)

                    // Settings Tab
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                        .tag(4)
                }
                .accentColor(Constants.Colors.primary)
            } else {
                // Authentication Screen
                if authViewModel.isAuthenticationRequired {
                    AuthenticationView(viewModel: authViewModel)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
}
