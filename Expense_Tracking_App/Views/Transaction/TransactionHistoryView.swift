//
//  TransactionHistoryView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct TransactionHistoryView: View {
    @StateObject private var viewModel = TransactionHistoryViewModel()
    @ObservedObject private var budgetService = BudgetService.shared
    @State private var showSortOptions = false
    @State private var showFilterOptions = false
    @State private var selectedTransaction: Transaction?
    @State private var showDateFilter = false

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Budget Goal Card
                    BudgetGoalView(
                        budgetService: budgetService,
                        transactions: viewModel.filteredTransactions
                    )

                    // Search Bar
                    searchBar

                    // Filter and Sort Bar
                    filterSortBar

                    // Statistics Summary
                    statisticsSummary

                    // Transaction List
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.filteredTransactions.isEmpty {
                        emptyStateView
                    } else {
                        transactionList
                    }
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadTransactions()
            }
            .refreshable {
                viewModel.loadTransactions()
            }
            .sheet(item: $selectedTransaction) { transaction in
                NavigationView {
                    EditTransactionView(transaction: transaction) {
                        viewModel.loadTransactions()
                    }
                }
            }
            .sheet(isPresented: $showDateFilter) {
                DateFilterSheet(
                    filterStart: $viewModel.dateFilterStart,
                    filterEnd:   $viewModel.dateFilterEnd
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Constants.Colors.textSecondary)

            TextField("Search transactions...", text: $viewModel.searchText)
                .textFieldStyle(.plain)

            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Constants.Colors.textSecondary)
                }
            }
        }
        .padding(Constants.Spacing.md)
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.sm)
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.top, Constants.Spacing.sm)
    }

    // MARK: - Filter and Sort Bar

    private var filterSortBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.sm) {
                // Sort Button
                Menu {
                    ForEach(
                        [
                            TransactionSortOption.dateDescending, .dateAscending, .amountDescending,
                            .amountAscending, .category,
                        ], id: \.self
                    ) { option in
                        Button(action: {
                            withAnimation {
                                viewModel.selectedSortOption = option
                            }
                        }) {
                            HStack {
                                Text(option.displayName)
                                if viewModel.selectedSortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    filterChip(
                        icon: "arrow.up.arrow.down",
                        label: "Sort",
                        isActive: false
                    )
                }

                // Category Filter Button
                Menu {
                    Button(action: {
                        withAnimation { viewModel.selectedCategoryFilter = nil }
                    }) {
                        HStack {
                            Text("All Categories")
                            if viewModel.selectedCategoryFilter == nil { Image(systemName: "checkmark") }
                        }
                    }
                    Divider()
                    ForEach(viewModel.availableCategories, id: \.self) { category in
                        Button(action: {
                            withAnimation { viewModel.selectedCategoryFilter = category }
                        }) {
                            HStack {
                                Text(category)
                                if viewModel.selectedCategoryFilter == category { Image(systemName: "checkmark") }
                            }
                        }
                    }
                } label: {
                    filterChip(
                        icon: "line.3.horizontal.decrease.circle",
                        label: viewModel.selectedCategoryFilter ?? "Category",
                        isActive: viewModel.selectedCategoryFilter != nil
                    )
                }

                // Date Filter Button / Active Chip
                if viewModel.isDateFiltered {
                    // Active state — show label with × dismiss
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.clearDateFilter()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12, weight: .semibold))
                            Text(viewModel.activeDateLabel)
                                .font(.system(size: Constants.FontSize.caption, weight: .semibold))
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(Constants.Colors.primary)
                        )
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                } else {
                    Button { showDateFilter = true } label: {
                        filterChip(icon: "calendar", label: "Date", isActive: false)
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.vertical, Constants.Spacing.sm)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isDateFiltered)
        }
    }

    /// Reusable chip label used by Sort and Category buttons
    private func filterChip(icon: String, label: String, isActive: Bool) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(label)
                .font(.system(size: Constants.FontSize.caption, weight: .medium))
                .lineLimit(1)
        }
        .foregroundColor(isActive ? .white : Constants.Colors.primary)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(isActive ? Constants.Colors.primary : Constants.Colors.primary.opacity(0.1))
        )
    }

    // MARK: - Statistics Summary

    private var statisticsSummary: some View {
        HStack(spacing: Constants.Spacing.md) {
            StatCard(
                title: "Total",
                value: viewModel.totalSpent.currencyFormatted,
                icon: "dollarsign.circle.fill",
                color: Constants.Colors.primary
            )

            StatCard(
                title: "Count",
                value: "\(viewModel.transactionCount)",
                icon: "number.circle.fill",
                color: Constants.Colors.secondary
            )

            StatCard(
                title: "Average",
                value: viewModel.averageTransaction.currencyFormatted,
                icon: "chart.bar.fill",
                color: Constants.Colors.accent
            )
        }
        .padding(Constants.Spacing.md)
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        List {
            ForEach(viewModel.groupedTransactions, id: \.0) { date, transactions in
                Section {
                    ForEach(transactions) { transaction in
                        TransactionRowView(transaction: transaction)
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteTransaction(transaction)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: Constants.CornerRadius.md)
                                    .fill(Constants.Colors.cardBackground)
                                    .padding(.horizontal, Constants.Spacing.md)
                                    .padding(.vertical, 4)
                            )
                    }
                } header: {
                    HStack {
                        Text(date)
                            .font(.system(size: Constants.FontSize.caption, weight: .semibold))
                            .foregroundColor(Constants.Colors.textSecondary)

                        Spacer()
                    }
                }
                .textCase(nil)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Constants.Colors.background)
        .contentMargins(.bottom, 140, for: .scrollContent)
    }


    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: Constants.Spacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.textSecondary)

            Text("No Transactions")
                .font(.system(size: Constants.FontSize.title, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)

            Text("Add your first expense to get started")
                .font(.system(size: Constants.FontSize.body))
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.xs) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: Constants.FontSize.caption))
                    .foregroundColor(Constants.Colors.textSecondary)
            }

            Text(value)
                .font(.system(size: Constants.FontSize.body, weight: .bold))
                .foregroundColor(Constants.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Constants.Spacing.md)
        .cardStyle()
    }
}

// MARK: - Transaction Sort Option Extension
extension TransactionSortOption {
    var displayName: String {
        switch self {
        case .dateDescending: return "Date (Newest First)"
        case .dateAscending: return "Date (Oldest First)"
        case .amountDescending: return "Amount (High to Low)"
        case .amountAscending: return "Amount (Low to High)"
        case .category: return "Category"
        }
    }
}

// MARK: - Preview
#Preview {
    TransactionHistoryView()
}
