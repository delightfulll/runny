//
//  UserDataViewModel.swift
//  Runny
//
//  Created by Vinay Honne  on 2/8/26.
//

import Foundation
import Combine

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
                    dailyStreak = fetchedUser.dailyStreak
                    recentActivities = fetchedActivities
                    weeklyActivities = Array(fetchedActivities.prefix(7))
                    weeklyDistance = fetchedActivities
                        .filter { isThisWeek($0.date) }
                        .compactMap { $0.distance }
                        .reduce(0, +)
                    weeklyWorkouts = fetchedActivities.filter { isThisWeek($0.date) }.count
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
        calculateStreak()

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
        Task {
            try? await APIService.deleteActivity(id: id)
        }
    }

    func calculateStrain() {
        var strainScore: Double = 0.0
        let calendar = Calendar.current
        let today = Date()

        let todaysActivities = recentActivities.filter { activity in
            calendar.isDate(activity.date, inSameDayAs: today)
        }

        for activity in todaysActivities {
            let durationMinutes = activity.time / 60.0

            let difficultyMultiplier: Double
            switch activity.difficulty {
            case .light:  difficultyMultiplier = 0.7
            case .mid:    difficultyMultiplier = 1.0
            case .allOut: difficultyMultiplier = 1.5
            }

            var activityStrain: Double = 0.0
            switch activity.type {
            case .running:       activityStrain += durationMinutes * 1.5
            case .biking:        activityStrain += durationMinutes * 1.0
            case .weightlifting: activityStrain += durationMinutes * 1.8
            case .walking:       activityStrain += durationMinutes * 0.6
            }

            if activity.type == .running || activity.type == .biking || activity.type == .walking {
                activityStrain += (activity.distance ?? 0) * 2.0
            }

            strainScore += activityStrain * difficultyMultiplier
        }

        currentStrain = min(strainScore, 100.0)
    }

    func calculateRecovery() -> Double {
        let yesterdayStrain = getYesterdayStrain()
        return min(100 - yesterdayStrain, 100.0)
    }

    func calculateStreak() {
        if dailyStreak >= 7 {
            dailyStreak = 1
        } else {
            dailyStreak += 1
        }
        user.dailyStreak = dailyStreak
    }

    private func getYesterdayStrain() -> Double {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) else { return 0.0 }

        let yesterdayActivities = recentActivities.filter {
            calendar.isDate($0.date, inSameDayAs: yesterday)
        }

        var strain: Double = 0.0
        for activity in yesterdayActivities {
            strain += (activity.time / 60.0) * 1.5
        }
        return min(strain, 100.0)
    }

    private func isThisWeek(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
