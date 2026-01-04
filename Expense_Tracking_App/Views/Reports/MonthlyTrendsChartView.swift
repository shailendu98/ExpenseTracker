//
//  MonthlyTrendsChartView.swift
//  Expense_Tracking_App
//
//  Created on 2025-12-26.
//

import Charts
import SwiftUI

struct MonthlyTrendsChartView: View {
    let monthlyTrends: [MonthlySpending]

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.Spacing.md) {
            Chart(monthlyTrends) { item in
                BarMark(
                    x: .value("Month", item.monthYear),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Constants.Colors.primary, Constants.Colors.secondary,
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(6)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(Constants.Colors.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.2))

                    AxisValueLabel()
                        .font(.system(size: 10))
                        .foregroundStyle(Constants.Colors.textSecondary)
                }
            }
            .frame(height: 200)
            .padding(Constants.Spacing.md)
        }
    }
}

// MARK: - Preview
#Preview {
    MonthlyTrendsChartView(monthlyTrends: [
        MonthlySpending(monthYear: "Jan 2024", amount: 1200),
        MonthlySpending(monthYear: "Feb 2024", amount: 1500),
        MonthlySpending(monthYear: "Mar 2024", amount: 1100),
        MonthlySpending(monthYear: "Apr 2024", amount: 1800),
        MonthlySpending(monthYear: "May 2024", amount: 1400),
        MonthlySpending(monthYear: "Jun 2024", amount: 1600),
    ])
    .frame(height: 250)
    .cardStyle()
    .padding()
}
