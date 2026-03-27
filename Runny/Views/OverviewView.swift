//
//  OverviewView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//

import SwiftUI
import Charts

// Monthly activity data model
struct MonthlyActivity: Identifiable {
    let id = UUID()
    let month: String
    let monthIndex: Int
    let activities: Int
    let distance: Double // in miles
}

struct OverviewView: View {
    @State private var monthlyData: [MonthlyActivity] = [
        MonthlyActivity(month: "Jan", monthIndex: 0, activities: 12, distance: 45.2),
        MonthlyActivity(month: "Feb", monthIndex: 1, activities: 8, distance: 32.1),
        MonthlyActivity(month: "Mar", monthIndex: 2, activities: 15, distance: 58.7),
        MonthlyActivity(month: "Apr", monthIndex: 3, activities: 20, distance: 78.3),
        MonthlyActivity(month: "May", monthIndex: 4, activities: 18, distance: 65.4),
        MonthlyActivity(month: "Jun", monthIndex: 5, activities: 22, distance: 89.2),
        MonthlyActivity(month: "Jul", monthIndex: 6, activities: 25, distance: 102.5),
        MonthlyActivity(month: "Aug", monthIndex: 7, activities: 19, distance: 74.8),
        MonthlyActivity(month: "Sep", monthIndex: 8, activities: 16, distance: 61.3),
        MonthlyActivity(month: "Oct", monthIndex: 9, activities: 21, distance: 82.6),
        MonthlyActivity(month: "Nov", monthIndex: 10, activities: 14, distance: 53.9),
        MonthlyActivity(month: "Dec", monthIndex: 11, activities: 10, distance: 38.4)
    ]
    
    // Selection states for each chart
    @State private var selectedActivitiesMonth: MonthlyActivity?
    @State private var selectedMileageMonth: MonthlyActivity?
    @State private var isActivitiesDragging = false
    @State private var isMileageDragging = false
    
    private var totalActivities: Int {
        monthlyData.reduce(0) { $0 + $1.activities }
    }
    
    private var totalDistance: Double {
        monthlyData.reduce(0) { $0 + $1.distance }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your Overview")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                // MARK: - Activities Chart Section
                ChartSection(
                    title: "Activities",
                    icon: "figure.run",
                    accentColor: .orange
                ) {
                    ActivitiesHeaderView(
                        selectedMonth: selectedActivitiesMonth,
                        totalActivities: totalActivities
                    )
                } chart: {
                    InteractiveLineChartInt(
                        monthlyData: monthlyData,
                        selectedMonth: $selectedActivitiesMonth,
                        isDragging: $isActivitiesDragging,
                        valueKeyPath: \.activities,
                        gradientColors: [.orange, .yellow],
                        accentColor: .orange
                    )
                }
                
                // MARK: - Mileage Chart Section
                ChartSection(
                    title: "Mileage",
                    icon: "road.lanes",
                    accentColor: .blue
                ) {
                    MileageHeaderView(
                        selectedMonth: selectedMileageMonth,
                        totalDistance: totalDistance
                    )
                } chart: {
                    InteractiveLineChart(
                        monthlyData: monthlyData,
                        selectedMonth: $selectedMileageMonth,
                        isDragging: $isMileageDragging,
                        valueKeyPath: \.distance,
                        gradientColors: [.blue, .cyan],
                        accentColor: .blue
                    )
                }
                
                // Activity breakdown cards
                ActivityBreakdownView(monthlyData: monthlyData)
                    .padding(.horizontal)
                
                Spacer(minLength: 30)
            }
            .padding(.top)
        }
    }
}

// MARK: - Chart Section Container
struct ChartSection<Header: View, ChartContent: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    @ViewBuilder let header: () -> Header
    @ViewBuilder let chart: () -> ChartContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section title
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(accentColor)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            // Header with stats
            header()
                .padding(.horizontal)
            
            // Chart
            chart()
                .frame(height: 200)
                .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Activities Header
struct ActivitiesHeaderView: View {
    let selectedMonth: MonthlyActivity?
    let totalActivities: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selectedMonth?.month ?? "2026 Total")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(selectedMonth?.activities ?? totalActivities)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("workouts")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMonth?.id)
    }
}

// MARK: - Mileage Header
struct MileageHeaderView: View {
    let selectedMonth: MonthlyActivity?
    let totalDistance: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(selectedMonth?.month ?? "2026 Total")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", selectedMonth?.distance ?? totalDistance))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("miles")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedMonth?.id)
    }
}

// MARK: - Interactive Line Chart
struct InteractiveLineChart<T: BinaryFloatingPoint>: View {
    let monthlyData: [MonthlyActivity]
    @Binding var selectedMonth: MonthlyActivity?
    @Binding var isDragging: Bool
    let valueKeyPath: KeyPath<MonthlyActivity, T>
    let gradientColors: [Color]
    let accentColor: Color
    
    var body: some View {
        Chart(monthlyData) { data in
            // Area fill
            AreaMark(
                x: .value("Month", data.month),
                y: .value("Value", Double(data[keyPath: valueKeyPath]))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [gradientColors[0].opacity(0.4), gradientColors[0].opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            // Line
            LineMark(
                x: .value("Month", data.month),
                y: .value("Value", Double(data[keyPath: valueKeyPath]))
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            
            // Selection indicator
            if let selected = selectedMonth, selected.month == data.month {
                // Vertical rule line
                RuleMark(x: .value("Month", data.month))
                    .foregroundStyle(accentColor.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                
                // Outer glow
                PointMark(
                    x: .value("Month", data.month),
                    y: .value("Value", Double(data[keyPath: valueKeyPath]))
                )
                .foregroundStyle(accentColor.opacity(0.3))
                .symbolSize(300)
                
                // Main point
                PointMark(
                    x: .value("Month", data.month),
                    y: .value("Value", Double(data[keyPath: valueKeyPath]))
                )
                .foregroundStyle(accentColor)
                .symbolSize(150)
                
                // Inner white dot
                PointMark(
                    x: .value("Month", data.month),
                    y: .value("Value", Double(data[keyPath: valueKeyPath]))
                )
                .foregroundStyle(.white)
                .symbolSize(50)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                updateSelection(at: value.location, geometry: geometry)
                            }
                            .onEnded { _ in
                                isDragging = false
                                withAnimation(.easeOut(duration: 0.25)) {
                                    selectedMonth = nil
                                }
                            }
                    )
            }
        }
        .sensoryFeedback(.selection, trigger: selectedMonth?.id)
    }
    
    private func updateSelection(at location: CGPoint, geometry: GeometryProxy) {
        let xPosition = location.x
        let plotWidth = geometry.size.width
        let monthWidth = plotWidth / CGFloat(monthlyData.count)
        let index = Int(xPosition / monthWidth)
        
        guard index >= 0, index < monthlyData.count else { return }
        
        let newSelection = monthlyData[index]
        if selectedMonth?.id != newSelection.id {
            selectedMonth = newSelection
        }
    }
}

// MARK: - Wrapper for Int keypath
struct InteractiveLineChartInt: View {
    let monthlyData: [MonthlyActivity]
    @Binding var selectedMonth: MonthlyActivity?
    @Binding var isDragging: Bool
    let valueKeyPath: KeyPath<MonthlyActivity, Int>
    let gradientColors: [Color]
    let accentColor: Color
    
    var body: some View {
        Chart(monthlyData) { data in
            AreaMark(
                x: .value("Month", data.month),
                y: .value("Value", data[keyPath: valueKeyPath])
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [gradientColors[0].opacity(0.4), gradientColors[0].opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            LineMark(
                x: .value("Month", data.month),
                y: .value("Value", data[keyPath: valueKeyPath])
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
            
            if let selected = selectedMonth, selected.month == data.month {
                RuleMark(x: .value("Month", data.month))
                    .foregroundStyle(accentColor.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))
                
                PointMark(
                    x: .value("Month", data.month),
                    y: .value("Value", data[keyPath: valueKeyPath])
                )
                .foregroundStyle(accentColor.opacity(0.3))
                .symbolSize(300)
                
                PointMark(
                    x: .value("Month", data.month),
                    y: .value("Value", data[keyPath: valueKeyPath])
                )
                .foregroundStyle(accentColor)
                .symbolSize(150)
                
                PointMark(
                    x: .value("Month", data.month),
                    y: .value("Value", data[keyPath: valueKeyPath])
                )
                .foregroundStyle(.white)
                .symbolSize(50)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
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
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDragging = true
                                updateSelection(at: value.location, geometry: geometry)
                            }
                            .onEnded { _ in
                                isDragging = false
                                withAnimation(.easeOut(duration: 0.25)) {
                                    selectedMonth = nil
                                }
                            }
                    )
            }
        }
        .sensoryFeedback(.selection, trigger: selectedMonth?.id)
    }
    
    private func updateSelection(at location: CGPoint, geometry: GeometryProxy) {
        let xPosition = location.x
        let plotWidth = geometry.size.width
        let monthWidth = plotWidth / CGFloat(monthlyData.count)
        let index = Int(xPosition / monthWidth)
        
        guard index >= 0, index < monthlyData.count else { return }
        
        let newSelection = monthlyData[index]
        if selectedMonth?.id != newSelection.id {
            selectedMonth = newSelection
        }
    }
}

// MARK: - Activity Breakdown
struct ActivityBreakdownView: View {
    let monthlyData: [MonthlyActivity]
    
    private var bestActivitiesMonth: MonthlyActivity? {
        monthlyData.max(by: { $0.activities < $1.activities })
    }
    
    private var bestMileageMonth: MonthlyActivity? {
        monthlyData.max(by: { $0.distance < $1.distance })
    }
    
    private var averageActivities: Double {
        Double(monthlyData.reduce(0) { $0 + $1.activities }) / Double(monthlyData.count)
    }
    
    private var averageMileage: Double {
        monthlyData.reduce(0) { $0 + $1.distance } / Double(monthlyData.count)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Best Month",
                    value: bestActivitiesMonth?.month ?? "-",
                    subtitle: "\(bestActivitiesMonth?.activities ?? 0) workouts",
                    icon: "trophy.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Top Mileage",
                    value: bestMileageMonth?.month ?? "-",
                    subtitle: String(format: "%.1f miles", bestMileageMonth?.distance ?? 0),
                    icon: "star.fill",
                    color: .blue
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Avg Workouts",
                    value: String(format: "%.0f", averageActivities),
                    subtitle: "per month",
                    icon: "chart.bar.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Avg Mileage",
                    value: String(format: "%.1f", averageMileage),
                    subtitle: "miles/month",
                    icon: "speedometer",
                    color: .purple
                )
            }
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
}
