//
//  KhataDetailView.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import SwiftUI

struct KhataDetailView: View {
    @ObservedObject var viewModel: KhataViewModel
    let person: KhataPerson

    @State private var showAddEntry = false
    @State private var entryToDelete: KhataEntry?
    @State private var showDeleteAlert = false

    private var entries: [KhataEntry] { viewModel.entries(for: person) }
    private var balance: Double { viewModel.netBalance(for: person) }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Balance Card
                    balanceCard
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    // MARK: Quick Stats
                    quickStats
                        .padding(.horizontal, 20)

                    // MARK: Entries List / Empty State
                    if entries.isEmpty {
                        emptyState
                    } else {
                        entriesList
                    }

                    // Bottom padding to clear floating tab bar + FAB
                    Color.clear.frame(height: 140)
                }
            }

            // MARK: FAB — positioned above the floating tab bar
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    fabButton
                        .padding(.trailing, 20)
                        // 90pt tab bar height + 20pt gap = 110pt from bottom
                        .padding(.bottom, 110)
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddEntry) {
            AddEntrySheet(viewModel: viewModel, person: person, isPresented: $showAddEntry)
                .presentationDetents([.large])
        }
        .alert("Delete Entry?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let entry = entryToDelete {
                    withAnimation { viewModel.deleteEntry(entry) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This entry will be permanently deleted and the balance will be recalculated.")
        }
        .onAppear { viewModel.loadData() }
    }

    // MARK: - Balance Card
    private var balanceCard: some View {
        let isPositive = balance >= 0
        let isSettled  = balance == 0

        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isSettled ? "All Settled" : (isPositive ? "Will Get" : "Will Give"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))

                    Text("₹\(String(format: "%.2f", abs(balance)))")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 60, height: 60)

                    Text(person.emoji)
                        .font(.system(size: 30))
                }
            }

            if !isSettled {
                HStack(spacing: 6) {
                    Image(systemName: isPositive ? "arrow.down.left" : "arrow.up.right")
                        .font(.system(size: 12, weight: .semibold))
                    Text(isPositive ? "\(person.name) owes you" : "You owe \(person.name)")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: isSettled
                    ? [Color(.systemGray), Color(.systemGray2)]
                    : isPositive
                        ? [Color(hex: "#34C97A"), Color(hex: "#27ae60")]
                        : [Color(hex: "#FF5C5C"), Color(hex: "#c0392b")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(
            color: (isSettled
                    ? Color(.systemGray)
                    : isPositive ? Color(hex: "#34C97A") : Color(hex: "#FF5C5C")
                   ).opacity(0.35),
            radius: 16, x: 0, y: 8
        )
    }

    // MARK: - Quick Stats
    private var quickStats: some View {
        let gaveTotal     = entries.filter { $0.type == .gave     }.reduce(0) { $0 + $1.amount }
        let receivedTotal = entries.filter { $0.type == .received }.reduce(0) { $0 + $1.amount }

        return HStack(spacing: 12) {
            statCard(title: "Total Gave",     amount: gaveTotal,     icon: "arrow.up.right",  color: Color(hex: "#FF5C5C"))
            statCard(title: "Total Received", amount: receivedTotal, icon: "arrow.down.left", color: Color(hex: "#34C97A"))
        }
    }

    private func statCard(title: String, amount: Double, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            Text("₹\(String(format: "%.0f", amount))")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Entries List
    private var entriesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transaction History")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)

            LazyVStack(spacing: 1) {
                ForEach(entries) { entry in
                    entryRow(entry)
                        .background(Color(.secondarySystemGroupedBackground))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                entryToDelete = entry
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
        }
    }

    private func entryRow(_ entry: KhataEntry) -> some View {
        HStack(spacing: 14) {
            // Type icon
            ZStack {
                Circle()
                    .fill(entry.type.color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: entry.type.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(entry.type.color)
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.type.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)

                if entry.note.isNotEmpty {
                    Text(entry.note)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Text(entry.formattedDate)
                    .font(.system(size: 12))
                    .foregroundColor(Color(.tertiaryLabel))
            }

            Spacer()

            // Amount
            Text(entry.formattedAmount)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(entry.type.color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Constants.Colors.primary.opacity(0.08))
                    .frame(width: 90, height: 90)
                Image(systemName: "indianrupeesign.circle")
                    .font(.system(size: 38))
                    .foregroundColor(Constants.Colors.primary.opacity(0.5))
            }

            VStack(spacing: 6) {
                Text("No entries yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text("Tap the + button to add your first\nGave or Received entry")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - FAB
    private var fabButton: some View {
        Button {
            showAddEntry = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(
                    LinearGradient(
                        colors: [Constants.Colors.primary, Constants.Colors.primary.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Constants.Colors.primary.opacity(0.5), radius: 14, x: 0, y: 6)
        }
    }
}
