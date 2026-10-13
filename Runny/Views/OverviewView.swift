//
//  OverviewView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//

import SwiftUI

// MARK: - Chart models

enum OverviewRange: String, CaseIterable, Identifiable {
    case week = "1W"
    case month = "1M"
    case threeMonths = "3M"
    case year = "1Y"
    case all = "ALL"
    var id: String { rawValue }

    var dayCount: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        case .all: return nil
        }
    }
}

enum OverviewMetric: String, CaseIterable, Identifiable {
    case miles = "Miles"
    case workouts = "Workouts"
    case calories = "Calories"
    case strain = "Strain"
    var id: String { rawValue }

    var unit: String {
        switch self {
        case .miles: return "mi"
        case .workouts: return "workouts"
        case .calories: return "cal"
        case .strain: return "strain"
        }
    }

    var accent: Color {
        switch self {
        case .miles: return .green
        case .workouts: return .orange
        case .calories: return .pink
        case .strain: return .red
        }
    }
}

struct OverviewPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Overview

struct OverviewView: View {
    @EnvironmentObject var userData: UserDataViewModel

    @State private var range: OverviewRange = .week
    @State private var metric: OverviewMetric = .miles
    @State private var selectedIndex: Int?
    @State private var drawProgress: CGFloat = 0
    @Namespace private var rangeNS

    private var series: [OverviewPoint] {
        Self.buildSeries(
            activities: userData.recentActivities,
            range: range,
            metric: metric
        )
    }

    private var previousSeries: [OverviewPoint] {
        Self.buildSeries(
            activities: userData.recentActivities,
            range: range,
            metric: metric,
            previousPeriod: true
        )
    }

    private var displayValue: Double {
        if let selectedIndex, series.indices.contains(selectedIndex) {
            return series[selectedIndex].value
        }
        return series.last?.value ?? 0
    }

    private var displayDateLabel: String {
        if let selectedIndex, series.indices.contains(selectedIndex) {
            return series[selectedIndex].date.formatted(
                Date.FormatStyle().month(.abbreviated).day().weekday(.abbreviated)
            )
        }
        return range.rawValue == "ALL" ? "All time" : "Past \(range.rawValue)"
    }

    private var changeVsPrevious: Double {
        let current = series.last?.value ?? 0
        let previous = previousSeries.last?.value ?? 0
        return current - previous
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Overview")
                    .font(.largeTitle.bold())
                    .padding(.horizontal)
                    .padding(.top, 8)

                // Metric picker
                Picker("Metric", selection: $metric) {
                    ForEach(OverviewMetric.allCases) { m in
                        Text(m.rawValue).tag(m)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: metric) { _, _ in replayDraw() }

                // Header number
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayDateLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(formattedValue(displayValue))
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .foregroundStyle(metric.accent)
                        Text(metric.unit)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: displayValue)

                    if selectedIndex == nil {
                        let delta = changeVsPrevious
                        HStack(spacing: 4) {
                            Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                            Text(String(format: "%@%@ %@",
                                        delta >= 0 ? "+" : "",
                                        formattedValue(delta),
                                        metric.unit))
                            Text("vs previous")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(delta >= 0 ? Color.green : Color.red)
                    }
                }
                .padding(.horizontal)

                // Chart
                Group {
                    if series.count < 2 || (series.last?.value ?? 0) == 0 && userData.recentActivities.isEmpty {
                        emptyChart
                    } else {
                        RobinhoodChart(
                            points: series,
                            selectedIndex: $selectedIndex,
                            progress: drawProgress,
                            accent: metric.accent
                        )
                        .frame(height: 220)
                        .padding(.horizontal, 8)
                    }
                }
                .onAppear { replayDraw() }
                .onChange(of: range) { _, _ in replayDraw() }

                // Range picker
                HStack(spacing: 0) {
                    ForEach(OverviewRange.allCases) { r in
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                range = r
                            }
                        } label: {
                            Text(r.rawValue)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(range == r ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background {
                                    if range == r {
                                        Capsule()
                                            .fill(metric.accent)
                                            .matchedGeometryEffect(id: "rangeCapsule", in: rangeNS)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(4)
                .background(Color.gray.opacity(0.12))
                .clipShape(Capsule())
                .padding(.horizontal)

                // Stats
                OverviewStatsGrid(activities: userData.recentActivities, metric: metric)
                    .padding(.horizontal)

                Spacer(minLength: 30)
            }
            .padding(.bottom, 24)
        }
    }

    private var emptyChart: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(metric.accent.opacity(0.3))
                .frame(height: 2)
                .padding(.horizontal)
            Text("Log a workout to see your trend")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
    }

    private func replayDraw() {
        selectedIndex = nil
        drawProgress = 0
        withAnimation(.easeOut(duration: 0.9)) {
            drawProgress = 1
        }
    }

    private func formattedValue(_ value: Double) -> String {
        switch metric {
        case .miles:
            return String(format: "%.1f", value)
        case .workouts, .calories:
            return String(format: "%.0f", value)
        case .strain:
            return String(format: "%.1f", value)
        }
    }

    // MARK: - Series builder

    static func buildSeries(
        activities: [Activity],
        range: OverviewRange,
        metric: OverviewMetric,
        previousPeriod: Bool = false
    ) -> [OverviewPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let dayCount: Int
        if let count = range.dayCount {
            dayCount = count
        } else {
            let oldest = activities.map { calendar.startOfDay(for: $0.date) }.min() ?? today
            dayCount = max(calendar.dateComponents([.day], from: oldest, to: today).day ?? 7, 7) + 1
        }

        let endOffset = previousPeriod ? dayCount : 0
        guard let endDate = calendar.date(byAdding: .day, value: -endOffset, to: today),
              let startDate = calendar.date(byAdding: .day, value: -(dayCount - 1), to: endDate) else {
            return []
        }

        var cumulative: Double = 0
        var points: [OverviewPoint] = []

        for offset in 0..<dayCount {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startDate) else { continue }
            let dayActivities = activities.filter { calendar.isDate($0.date, inSameDayAs: day) }

            let dayValue: Double
            switch metric {
            case .miles:
                dayValue = dayActivities.compactMap(\.distance).reduce(0, +)
            case .workouts:
                dayValue = Double(dayActivities.count)
            case .calories:
                dayValue = Double(dayActivities.reduce(0) { $0 + $1.calories })
            case .strain:
                let load = dayActivities.reduce(0.0) { $0 + UserDataViewModel.load(for: $1) }
                dayValue = UserDataViewModel.strain(fromLoad: load)
            }

            cumulative += dayValue
            points.append(OverviewPoint(date: day, value: cumulative))
        }

        return points
    }
}

// MARK: - Robinhood chart

struct RobinhoodChart: View {
    let points: [OverviewPoint]
    @Binding var selectedIndex: Int?
    let progress: CGFloat
    let accent: Color

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let coords = coordinates(in: size)

            ZStack {
                // Area fill
                ChartAreaShape(points: coords)
                    .fill(
                        LinearGradient(
                            colors: [accent.opacity(0.35), accent.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .mask(
                        Rectangle()
                            .frame(width: size.width * progress)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    )

                // Baseline
                if let first = coords.first {
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: first.y))
                        path.addLine(to: CGPoint(x: size.width, y: first.y))
                    }
                    .stroke(accent.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }

                // Dimmed full line (right of scrub)
                ChartLineShape(points: coords)
                    .trim(from: 0, to: progress)
                    .stroke(accent.opacity(selectedIndex == nil ? 1 : 0.25), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                // Bright line up to scrub point
                if let selectedIndex, coords.indices.contains(selectedIndex) {
                    ChartLineShape(points: coords)
                        .trim(from: 0, to: CGFloat(selectedIndex) / CGFloat(max(coords.count - 1, 1)))
                        .stroke(accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                    let point = coords[selectedIndex]
                    Path { path in
                        path.move(to: CGPoint(x: point.x, y: 0))
                        path.addLine(to: CGPoint(x: point.x, y: size.height))
                    }
                    .stroke(accent.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [3, 3]))

                    Circle()
                        .fill(accent.opacity(0.25))
                        .frame(width: 22, height: 22)
                        .position(point)
                    Circle()
                        .fill(accent)
                        .frame(width: 10, height: 10)
                        .position(point)
                    Circle()
                        .fill(.white)
                        .frame(width: 4, height: 4)
                        .position(point)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !coords.isEmpty else { return }
                        let x = value.location.x
                        let nearest = coords.enumerated().min(by: {
                            abs($0.element.x - x) < abs($1.element.x - x)
                        })?.offset
                        if let nearest, nearest != selectedIndex {
                            selectedIndex = nearest
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.easeOut(duration: 0.2)) {
                            selectedIndex = nil
                        }
                    }
            )
            .sensoryFeedback(.selection, trigger: selectedIndex)
        }
    }

    private func coordinates(in size: CGSize) -> [CGPoint] {
        guard points.count > 1 else { return [] }
        let values = points.map(\.value)
        let minV = values.min() ?? 0
        let maxV = values.max() ?? 1
        let range = max(maxV - minV, 0.01)
        let pad: CGFloat = 12

        return points.enumerated().map { index, point in
            let x = CGFloat(index) / CGFloat(points.count - 1) * size.width
            let normalized = (point.value - minV) / range
            let y = size.height - pad - CGFloat(normalized) * (size.height - pad * 2)
            return CGPoint(x: x, y: y)
        }
    }
}

struct ChartLineShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
}

struct ChartAreaShape: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first, let last = points.last else { return path }
        path.move(to: CGPoint(x: first.x, y: rect.maxY))
        path.addLine(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Stats grid

struct OverviewStatsGrid: View {
    let activities: [Activity]
    let metric: OverviewMetric

    private var bestDay: (label: String, value: String) {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: activities) { calendar.startOfDay(for: $0.date) }
        guard let best = grouped.max(by: { lhs, rhs in
            dayScore(lhs.value) < dayScore(rhs.value)
        }) else {
            return ("—", "No data")
        }
        let label = best.key.formatted(Date.FormatStyle().month(.abbreviated).day())
        return (label, formatDayScore(best.value))
    }

    private var longestWorkout: String {
        guard let longest = activities.max(by: { $0.time < $1.time }) else { return "—" }
        return longest.formattedTime
    }

    private var averagePerWeek: String {
        guard !activities.isEmpty else { return "0" }
        let calendar = Calendar.current
        let oldest = activities.map(\.date).min() ?? Date()
        let weeks = max(1.0, Double(calendar.dateComponents([.day], from: oldest, to: Date()).day ?? 7) / 7.0)
        let avg = Double(activities.count) / weeks
        return String(format: "%.1f", avg)
    }

    private var totalTime: String {
        let total = activities.reduce(0.0) { $0 + $1.time }
        let hours = Int(total) / 3600
        let minutes = (Int(total) % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Best Day",
                    value: bestDay.label,
                    subtitle: bestDay.value,
                    icon: "trophy.fill",
                    color: .orange
                )
                StatCard(
                    title: "Longest",
                    value: longestWorkout,
                    subtitle: "workout",
                    icon: "timer",
                    color: .blue
                )
            }
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg / Week",
                    value: averagePerWeek,
                    subtitle: "workouts",
                    icon: "chart.bar.fill",
                    color: .green
                )
                StatCard(
                    title: "Total Time",
                    value: totalTime,
                    subtitle: "all workouts",
                    icon: "clock.fill",
                    color: .purple
                )
            }
        }
    }

    private func dayScore(_ dayActivities: [Activity]) -> Double {
        switch metric {
        case .miles: return dayActivities.compactMap(\.distance).reduce(0, +)
        case .workouts: return Double(dayActivities.count)
        case .calories: return Double(dayActivities.reduce(0) { $0 + $1.calories })
        case .strain:
            let load = dayActivities.reduce(0.0) { $0 + UserDataViewModel.load(for: $1) }
            return UserDataViewModel.strain(fromLoad: load)
        }
    }

    private func formatDayScore(_ dayActivities: [Activity]) -> String {
        let score = dayScore(dayActivities)
        switch metric {
        case .miles: return String(format: "%.1f mi", score)
        case .workouts: return "\(Int(score)) workouts"
        case .calories: return "\(Int(score)) cal"
        case .strain: return String(format: "%.1f strain", score)
        }
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    OverviewView()
        .environmentObject(UserDataViewModel())
}
