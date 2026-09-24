//
//  KhataView.swift
//  Expense_Tracking_App
//
//  Created on 2026-09-05.
//

import SwiftUI

struct KhataView: View {
    @StateObject private var viewModel = KhataViewModel()
    @State private var showAddPerson = false
    @State private var searchText: String = ""
    @State private var personToDelete: KhataPerson?
    @State private var showDeleteAlert = false

    private var filteredPersons: [KhataPerson] {
        if searchText.trimmed.isEmpty {
            return viewModel.persons
        }
        return viewModel.persons.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.phone.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: Header
                    headerView

                    // MARK: Summary Cards
                    if !viewModel.persons.isEmpty {
                        summaryCards
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 8)
                    }

                    // MARK: Search Bar
                    if !viewModel.persons.isEmpty {
                        searchBar
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }

                    // MARK: Person List / Empty State
                    if viewModel.persons.isEmpty {
                        emptyState
                    } else if filteredPersons.isEmpty {
                        noResultsState
                    } else {
                        personList
                    }
                }

                // MARK: FAB — floats above the tab bar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        fabButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 110)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddPerson) {
                AddPersonSheet(viewModel: viewModel, isPresented: $showAddPerson)
                    .presentationDetents([.large])
            }
            .alert("Delete Person?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let person = personToDelete {
                        withAnimation { viewModel.deletePerson(person) }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All entries for this person will also be permanently deleted.")
            }
            .onAppear { viewModel.loadData() }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Constants.Colors.primary, Color(hex: "#9B8FFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Khata Book")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        Text("Track who owes you what")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(.horizontal, 20)
                .padding(.top, 56)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 130)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        HStack(spacing: 12) {
            summaryCard(
                title: "Will Get",
                amount: viewModel.totalToReceive,
                color: Color(hex: "#34C97A"),
                icon: "arrow.down.left.circle.fill"
            )
            summaryCard(
                title: "Will Give",
                amount: viewModel.totalToGive,
                color: Color(hex: "#FF5C5C"),
                icon: "arrow.up.right.circle.fill"
            )
        }
    }

    private func summaryCard(title: String, amount: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                Spacer()
            }
            Text("₹\(String(format: "%.0f", amount))")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1.5)
        )
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 15))
            TextField("Search people...", text: $searchText)
                .font(.system(size: 15))
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Person List
    private var personList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(filteredPersons) { person in
                    NavigationLink(destination: KhataDetailView(viewModel: viewModel, person: person)) {
                        personRow(person)
                            .background(Color(.secondarySystemGroupedBackground))
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            personToDelete = person
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 100)
        }
    }

    private func personRow(_ person: KhataPerson) -> some View {
        let balance = viewModel.netBalance(for: person)
        let isPositive = balance > 0
        let isSettled = balance == 0

        return HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Constants.Colors.primary.opacity(0.7), Constants.Colors.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Text(person.emoji)
                    .font(.system(size: 24))
            }

            // Info
            VStack(alignment: .leading, spacing: 3) {
                Text(person.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                if person.phone.isNotEmpty {
                    Text(person.phone)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Text("\(viewModel.entries(for: person).count) entries")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.tertiaryLabel))
            }

            Spacer()

            // Balance badge
            VStack(alignment: .trailing, spacing: 3) {
                Text("₹\(String(format: "%.0f", abs(balance)))")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(
                        isSettled ? .secondary
                        : isPositive ? Color(hex: "#34C97A")
                        : Color(hex: "#FF5C5C")
                    )

                Text(
                    isSettled ? "Settled" :
                    isPositive ? "Will Get" : "Will Give"
                )
                .font(.system(size: 11, weight: .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    (isSettled ? Color(.systemGray5)
                     : isPositive ? Color(hex: "#34C97A").opacity(0.12)
                     : Color(hex: "#FF5C5C").opacity(0.12))
                )
                .foregroundColor(
                    isSettled ? .secondary
                    : isPositive ? Color(hex: "#34C97A")
                    : Color(hex: "#FF5C5C")
                )
                .cornerRadius(6)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Constants.Colors.primary.opacity(0.08))
                    .frame(width: 110, height: 110)
                Image(systemName: "book.closed")
                    .font(.system(size: 45))
                    .foregroundColor(Constants.Colors.primary.opacity(0.5))
            }
            VStack(spacing: 8) {
                Text("Your Khata is Empty")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Text("Add people to start tracking\nwho owes you and who you owe.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            Button {
                showAddPerson = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("Add First Person")
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Constants.Colors.primary)
                .foregroundColor(.white)
                .cornerRadius(14)
                .shadow(color: Constants.Colors.primary.opacity(0.35), radius: 10, x: 0, y: 5)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 80)
    }

    // MARK: - No Results
    private var noResultsState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.5))
            Text("No results for \"\(searchText)\"")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - FAB
    private var fabButton: some View {
        Button {
            showAddPerson = true
        } label: {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(
                    LinearGradient(
                        colors: [Constants.Colors.primary, Color(hex: "#9B8FFF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: Constants.Colors.primary.opacity(0.5), radius: 14, x: 0, y: 6)
        }
    }
}

// MARK: - Preview
#Preview {
    KhataView()
}
