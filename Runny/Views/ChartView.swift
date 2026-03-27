//
//  ChartView.swift
//  Runny
//
//  Created by Vinay Honne  on 2/19/26.
//

import SwiftUI
import Charts

struct DailyCount: Identifiable {
    let id = UUID()
    let day: String
    let date: Date
    let count: Int
}

struct ChartView: View {
    @EnvironmentObject var userData: UserDataViewModel

    private var weeklyData: [DailyCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

        return (0..<7).reversed().map { daysAgo in
            let date = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            let count = userData.recentActivities.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }.count
            let weekday = calendar.component(.weekday, from: date)
            return DailyCount(day: dayLabels[weekday - 1], date: date, count: count)
        }
    }

    private var weekTotal: Int {
        weeklyData.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("This Week")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(weekTotal)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                        Text("workouts")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                Chart(weeklyData) { day in
                    BarMark(
                        x: .value("Day", day.day),
                        y: .value("Workouts", day.count)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine()
                            .foregroundStyle(.gray.opacity(0.15))
                        AxisValueLabel()
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 220)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
    }
}

#Preview {
    ChartView()
        .environmentObject(UserDataViewModel())
}
