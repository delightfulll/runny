//
//  UserDataViewModel.swift
//  Runny
//
//  Created by Vinay Honne  on 2/8/26.
//

import Foundation
import Combine

struct WeekDayStatus: Identifiable {
    let id: Date
    let date: Date
    let label: String
    let done: Bool
    let isToday: Bool
}

class UserDataViewModel: ObservableObject {

    @Published var user: User = User(id: "", name: "You", email: "", yesterdayStrain: 0, dailyStreak: 0, recovery: 100)
    @Published var recentActivities: [Activity] = []
    @Published var weeklyActivities: [Activity] = []
    @Published var currentStrain: Double = 0.0
    @Published var currentRecovery: Double = 0.0
    @Published var dailyStreak: Int = 0
    @Published var weeklyDistance: Double = 0.0
    @Published var weeklyWorkouts: Int = 0
    @Published var monthlyDistance: Double = 0.0
    @Published var isLoading: Bool = false

    // MARK: - Week streak (Sun–Sat, one green circle per day with any activity)

    var weekActivityDays: [WeekDayStatus] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
        let labels = ["S", "M", "T", "W", "T", "F", "S"]

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: weekInterval.start) else { return nil }
            let dayStart = calendar.startOfDay(for: date)
            let done = recentActivities.contains { calendar.isDate($0.date, inSameDayAs: dayStart) }
            return WeekDayStatus(
                id: dayStart,
                date: dayStart,
                label: labels[offset],
                done: done,
                isToday: calendar.isDate(dayStart, inSameDayAs: today)
            )
        }
    }

    // MARK: - Whoop-style strain (0–21)

    /// Training load for a single activity before the strain curve is applied.
    static func load(for activity: Activity) -> Double {
        let minutes = activity.time / 60.0

        let typeFactor: Double
        switch activity.type {
        case .running:       typeFactor = 1.0
        case .biking:        typeFactor = 0.8
        case .weightlifting: typeFactor = 0.9
        case .walking:       typeFactor = 0.4
        }

        let difficultyFactor: Double
        switch activity.difficulty {
        case .light:  difficultyFactor = 0.6
        case .mid:    difficultyFactor = 1.0
        case .allOut: difficultyFactor = 1.5
        }

        var load = minutes * typeFactor * difficultyFactor

        // Pace bonus for fast runs / rides (min/mile). Lower pace = harder.
        if let pace = activity.averagePace, pace > 0,
           activity.type == .running || activity.type == .biking {
            if pace < 7.0 {
                load *= 1.2
            } else if pace < 9.0 {
                load *= 1.1
            }
        }

        return load
    }

    /// Maps cumulative load onto a Whoop-like 0–21 curve.
    static func strain(fromLoad load: Double) -> Double {
        guard load > 0 else { return 0 }
        return 21.0 * (1.0 - exp(-load / 43.0))
    }

    /// Strain for a single activity at a given difficulty (used by the finish screen).
    static func strain(for activity: Activity, difficulty: Difficulty? = nil) -> Double {
        var copy = activity
        if let difficulty { copy.difficulty = difficulty }
        return strain(fromLoad: load(for: copy))
    }

    // Fetch user profile and activities from the server
    func loadFromServer() {
        Task {
            await MainActor.run { isLoading = true }
            do {
                async let userResult = APIService.fetchUser()
                async let activitiesResult = APIService.fetchActivities()

                let (fetchedUser, fetchedActivities) = try await (userResult, activitiesResult)

                await MainActor.run {
                    user = fetchedUser
                    recentActivities = fetchedActivities
                    weeklyActivities = Array(fetchedActivities.prefix(7))
                    weeklyDistance = fetchedActivities
                        .filter { isThisWeek($0.date) }
                        .compactMap { $0.distance }
                        .reduce(0, +)
                    weeklyWorkouts = fetchedActivities.filter { isThisWeek($0.date) }.count
                    dailyStreak = weekActivityDays.filter(\.done).count
                    user.dailyStreak = dailyStreak
                    calculateStrain()
                    isLoading = false
                }
            } catch {
                await MainActor.run { isLoading = false }
                print("❌ Failed to load from server: \(error)")
            }
        }
    }

    // Save activity locally and post to server
    func saveActivity(activity: Activity) {
        recentActivities.insert(activity, at: 0)
        if recentActivities.count > 30 {
            recentActivities = Array(recentActivities.prefix(30))
        }
        weeklyActivities.insert(activity, at: 0)
        if weeklyActivities.count > 7 {
            weeklyActivities = Array(weeklyActivities.prefix(7))
        }
        weeklyDistance += activity.distance ?? 0
        weeklyWorkouts += 1
        dailyStreak = weekActivityDays.filter(\.done).count
        user.dailyStreak = dailyStreak
        calculateStrain()

        Task {
            do {
                let saved = try await APIService.createActivity(activity: activity)
                await MainActor.run {
                    if saved.id != activity.id {
                        RouteStore.rekey(from: activity.id, to: saved.id)
                    }
                    if let index = recentActivities.firstIndex(where: { $0.id == activity.id }) {
                        recentActivities[index] = saved
                    }
                }
            } catch {
                print("❌ Failed to save activity to server: \(error)")
            }
        }
    }

    func deleteActivity(id: String) {
        recentActivities.removeAll { $0.id == id }
        weeklyActivities.removeAll { $0.id == id }
        dailyStreak = weekActivityDays.filter(\.done).count
        user.dailyStreak = dailyStreak
        calculateStrain()
        Task {
            try? await APIService.deleteActivity(id: id)
        }
    }

    func calculateStrain() {
        let calendar = Calendar.current
        let today = Date()
        let todaysActivities = recentActivities.filter {
            calendar.isDate($0.date, inSameDayAs: today)
        }
        let totalLoad = todaysActivities.reduce(0.0) { $0 + Self.load(for: $1) }
        currentStrain = Self.strain(fromLoad: totalLoad)
    }

    func calculateRecovery() -> Double {
        let yesterdayStrain = getYesterdayStrain()
        return max(0, min(100 - yesterdayStrain * 4.0, 100.0))
    }

    private func getYesterdayStrain() -> Double {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else { return 0.0 }

        let yesterdayActivities = recentActivities.filter {
            calendar.isDate($0.date, inSameDayAs: yesterday)
        }
        let totalLoad = yesterdayActivities.reduce(0.0) { $0 + Self.load(for: $1) }
        return Self.strain(fromLoad: totalLoad)
    }

    private func isThisWeek(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
