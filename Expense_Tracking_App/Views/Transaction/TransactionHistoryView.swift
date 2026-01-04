//
//  TransactionHistoryView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import SwiftUI

struct TransactionHistoryView: View {
    @StateObject private var viewModel = TransactionHistoryViewModel()
    @State private var showSortOptions = false
    @State private var showFilterOptions = false
    @State private var selectedTransaction: Transaction?

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                VStack(spacing: 0) {
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
        HStack(spacing: Constants.Spacing.md) {
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
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Sort")
                }
                .font(.system(size: Constants.FontSize.caption, weight: .medium))
                .foregroundColor(Constants.Colors.primary)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.primary.opacity(0.1))
                .cornerRadius(Constants.CornerRadius.sm)
            }

            // Filter Button
            Menu {
                Button(action: {
                    withAnimation {
                        viewModel.selectedCategoryFilter = nil
                    }
                }) {
                    HStack {
                        Text("All Categories")
                        if viewModel.selectedCategoryFilter == nil {
                            Image(systemName: "checkmark")
                        }
                    }
                }

                Divider()

                ForEach(viewModel.availableCategories, id: \.self) { category in
                    Button(action: {
                        withAnimation {
                            viewModel.selectedCategoryFilter = category
                        }
                    }) {
                        HStack {
                            Text(category)
                            if viewModel.selectedCategoryFilter == category {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text(viewModel.selectedCategoryFilter ?? "Filter")
                }
                .font(.system(size: Constants.FontSize.caption, weight: .medium))
                .foregroundColor(Constants.Colors.primary)
                .padding(.horizontal, Constants.Spacing.md)
                .padding(.vertical, Constants.Spacing.sm)
                .background(Constants.Colors.primary.opacity(0.1))
                .cornerRadius(Constants.CornerRadius.sm)
            }

            Spacer()
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, Constants.Spacing.sm)
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
                            .listRowInsets(
                                EdgeInsets(
                                    top: Constants.Spacing.md / 2,
                                    leading: Constants.Spacing.md,
                                    bottom: Constants.Spacing.md / 2,
                                    trailing: Constants.Spacing.md
                                )
                            )
                            .listRowSeparator(.hidden)
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
