//
//  DateFilterSheet.swift
//  Expense_Tracking_App
//
//  Created on 2026-07-29.
//

import SwiftUI

// MARK: - Date Filter Mode

enum DateFilterMode: String, CaseIterable {
    case single = "Single Day"
    case range  = "Date Range"
}

// MARK: - DateFilterSheet

struct DateFilterSheet: View {
    // Bindings back to the view model
    @Binding var filterStart: Date?
    @Binding var filterEnd: Date?

    @Environment(\.dismiss) private var dismiss

    // Local draft state — only applied when user taps Apply
    @State private var mode: DateFilterMode = .single
    @State private var draftDay:   Date = Date()
    @State private var draftStart: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var draftEnd:   Date = Date()

    private let calendar = Calendar.current

    // Initialise drafts from current active filter if any
    init(filterStart: Binding<Date?>, filterEnd: Binding<Date?>) {
        _filterStart = filterStart
        _filterEnd   = filterEnd

        // Seed draft values from existing filter
        let start = filterStart.wrappedValue
        let end   = filterEnd.wrappedValue

        if let s = start, let e = end {
            if calendar.isDate(s, inSameDayAs: e) {
                _mode      = State(initialValue: .single)
                _draftDay  = State(initialValue: s)
            } else {
                _mode       = State(initialValue: .range)
                _draftStart = State(initialValue: s)
                _draftEnd   = State(initialValue: e)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: Constants.Spacing.lg) {

                        // Mode Picker
                        modePicker

                        // Picker Content
                        if mode == .single {
                            singleDayPicker
                        } else {
                            rangePicker
                        }

                        // Quick Shortcuts
                        shortcutButtons

                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, Constants.Spacing.md)
                    .padding(.top, Constants.Spacing.sm)
                }
            }
            .navigationTitle("Filter by Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Constants.Colors.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        filterStart = nil
                        filterEnd   = nil
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.accent)
                    .opacity(filterStart != nil ? 1 : 0.4)
                    .disabled(filterStart == nil)
                }
            }
            .safeAreaInset(edge: .bottom) {
                applyButton
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color(.systemBackground))
                            .ignoresSafeArea()
                            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -2)
                    )
            }
        }
    }

    // MARK: - Mode Picker

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(DateFilterMode.allCases, id: \.self) { m in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        mode = m
                    }
                } label: {
                    Text(m.rawValue)
                        .font(.system(size: 14, weight: mode == m ? .semibold : .regular))
                        .foregroundColor(mode == m ? .white : Constants.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(mode == m ? Constants.Colors.primary : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Constants.Colors.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        )
    }

    // MARK: - Single Day Picker

    private var singleDayPicker: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .foregroundColor(Constants.Colors.primary)
                    .font(.system(size: 18))
                Text("Choose a Day")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Constants.Colors.textPrimary)
                Spacer()
                Text(draftDay.formatted(as: "d MMM yyyy"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Constants.Colors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Constants.Colors.primary.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.top, Constants.Spacing.md)
            .padding(.bottom, Constants.Spacing.sm)

            Divider().padding(.horizontal, Constants.Spacing.md)

            DatePicker(
                "",
                selection: $draftDay,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(Constants.Colors.primary)
            .padding(.horizontal, 8)
            .padding(.bottom, Constants.Spacing.sm)
        }
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Range Picker

    private var rangePicker: some View {
        VStack(spacing: Constants.Spacing.sm) {
            // From date
            datePickerCard(
                title: "From",
                icon: "arrow.right.circle.fill",
                iconColor: Constants.Colors.primary,
                selection: $draftStart,
                range: Date.distantPast...draftEnd
            )

            // Visual connector
            HStack {
                Spacer()
                VStack(spacing: 2) {
                    Rectangle()
                        .fill(Constants.Colors.primary.opacity(0.3))
                        .frame(width: 2, height: 12)
                    Image(systemName: "arrow.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Constants.Colors.primary)
                    Rectangle()
                        .fill(Constants.Colors.primary.opacity(0.3))
                        .frame(width: 2, height: 12)
                }
                Spacer()
            }

            // To date
            datePickerCard(
                title: "To",
                icon: "arrow.left.circle.fill",
                iconColor: Constants.Colors.secondary,
                selection: $draftEnd,
                range: draftStart...Date()
            )

            // Range summary chip
            if draftEnd >= draftStart {
                rangeSummaryChip
            }
        }
    }

    private func datePickerCard(
        title: String,
        icon: String,
        iconColor: Color,
        selection: Binding<Date>,
        range: ClosedRange<Date>
    ) -> some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 18))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Constants.Colors.textPrimary)
                Spacer()
                Text(selection.wrappedValue.formatted(as: "d MMM yyyy"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(iconColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(iconColor.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, Constants.Spacing.md)
            .padding(.top, Constants.Spacing.md)
            .padding(.bottom, Constants.Spacing.sm)

            Divider().padding(.horizontal, Constants.Spacing.md)

            DatePicker("", selection: selection, in: range, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(iconColor)
                .padding(.horizontal, 8)
                .padding(.bottom, Constants.Spacing.sm)
        }
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.CornerRadius.lg)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var rangeSummaryChip: some View {
        let days = calendar.dateComponents([.day], from: draftStart.startOfDay, to: draftEnd.startOfDay).day ?? 0
        return HStack(spacing: 8) {
            Image(systemName: "calendar.badge.checkmark")
                .foregroundColor(Constants.Colors.primary)
            Text("\(draftStart.formatted(as: "d MMM")) → \(draftEnd.formatted(as: "d MMM yyyy"))")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Constants.Colors.textPrimary)
            Spacer()
            Text("\(days + 1) day\(days == 0 ? "" : "s")")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Constants.Colors.primary)
                .cornerRadius(20)
        }
        .padding(.horizontal, Constants.Spacing.md)
        .padding(.vertical, 12)
        .background(Constants.Colors.primary.opacity(0.08))
        .cornerRadius(Constants.CornerRadius.md)
    }

    // MARK: - Quick Shortcuts

    private var shortcutButtons: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Select")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Constants.Colors.textSecondary)
                .padding(.leading, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                shortcutButton("Today",        days: 0)
                shortcutButton("Yesterday",    days: -1)
                shortcutButton("Last 7 Days",  days: -6,  isRange: true)
                shortcutButton("Last 30 Days", days: -29, isRange: true)
                shortcutButton("This Month",   isCurrentMonth: true)
                shortcutButton("Last Month",   isLastMonth: true)
            }
        }
    }

    private func shortcutButton(
        _ label: String,
        days: Int = 0,
        isRange: Bool = false,
        isCurrentMonth: Bool = false,
        isLastMonth: Bool = false
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                applyShortcut(days: days, isRange: isRange, isCurrentMonth: isCurrentMonth, isLastMonth: isLastMonth)
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Constants.Colors.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Constants.Colors.primary.opacity(0.09))
                .cornerRadius(Constants.CornerRadius.sm)
        }
        .buttonStyle(.plain)
    }

    private func applyShortcut(days: Int, isRange: Bool, isCurrentMonth: Bool, isLastMonth: Bool) {
        let today = Date()
        if isCurrentMonth {
            mode = .range
            draftStart = today.startOfMonth
            draftEnd   = today
        } else if isLastMonth {
            mode = .range
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: today) ?? today
            draftStart = prevMonth.startOfMonth
            draftEnd   = prevMonth.endOfMonth
        } else if isRange {
            mode = .range
            draftStart = calendar.date(byAdding: .day, value: days, to: today) ?? today
            draftEnd   = today
        } else {
            // Single day shortcut
            mode = .single
            draftDay = calendar.date(byAdding: .day, value: days, to: today) ?? today
        }
    }

    // MARK: - Apply Button

    private var applyButton: some View {
        Button {
            if mode == .single {
                filterStart = draftDay.startOfDay
                filterEnd   = draftDay.endOfDay
            } else {
                filterStart = draftStart.startOfDay
                filterEnd   = draftEnd.endOfDay
            }
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                Text("Apply Filter")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Constants.Colors.primary, Constants.Colors.primary.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Constants.CornerRadius.md)
            .shadow(color: Constants.Colors.primary.opacity(0.35), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
