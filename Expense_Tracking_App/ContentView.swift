//
//  ContentView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

// MARK: - Tab Enum
enum AppTab: Int, CaseIterable {
    case transactions = 0
    case reports      = 1
    case categories   = 2
    case settings     = 3

    var icon: String {
        switch self {
        case .transactions: return "list.bullet"
        case .reports:      return "chart.pie.fill"
        case .categories:   return "square.grid.2x2.fill"
        case .settings:     return "gearshape.fill"
        }
    }

    var label: String {
        switch self {
        case .transactions: return "Transactions"
        case .reports:      return "Reports"
        case .categories:   return "Categories"
        case .settings:     return "Settings"
        }
    }
}

// MARK: - Floating Tab Bar
struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.rawValue) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 36)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 6)
        )
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab) -> some View {
        let isSelected = selectedTab == tab
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .primary : Color(.systemGray))
                Text(tab.label)
                    .font(.system(size: 9.5, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : Color(.systemGray))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ContentView
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab: AppTab = .transactions
    @State private var showAddExpense = false

    var body: some View {
        ZStack {
            if authViewModel.isAuthenticated {

                // ── Page content ──────────────────────────────────
                ZStack {
                    switch selectedTab {
                    case .transactions: TransactionHistoryView()
                    case .reports:      SummaryReportsView()
                    case .categories:   CategoryManagementView()
                    case .settings:     SettingsView()
                    }
                }
                .ignoresSafeArea(edges: .top)
                // Give content room so it doesn't hide behind the tab bar
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 140)
                }

                // ── Bottom overlay: tab bar + FAB ─────────────────
                VStack(spacing: 0) {
                    Spacer()

                    ZStack(alignment: .bottomTrailing) {
                        // Floating pill tab bar (full width)
                        FloatingTabBar(selectedTab: $selectedTab)
                            .frame(maxWidth: .infinity)

                        // "+" FAB — bottom-right corner, overlaps tab bar upward
                        Button {
                            showAddExpense = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 58, height: 58)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.13), radius: 18, x: 0, y: 6)
                                )
                        }
                        .offset(x: -20, y: -90) // floats above the tab bar at the right edge
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .padding(.bottom, 12)

            } else {
                // Authentication Screen
                if authViewModel.isAuthenticationRequired {
                    AuthenticationView(viewModel: authViewModel)
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView {
                showAddExpense = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AuthenticationViewModel())
}
