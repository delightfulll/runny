//
//  RunnyModel.swift
//  Runny
//
//  Created by Vinay Honne  on 2/5/26.
//

import Foundation
import SwiftUI

enum TypeActivity: String, Codable, Equatable {
    case running = "running"
    case biking = "biking"
    case weightlifting = "weightlifting"
    case walking = "walking"
}

enum Difficulty: String, Codable, CaseIterable {
    case light = "easy"
    case mid = "mid"
    case allOut = "hard"

    var label: String {
        switch self {
        case .light: return "Light Work"
        case .mid: return "Mid"
        case .allOut: return "All Out"
        }
    }

    var color: Color {
        switch self {
        case .light: return .green
        case .mid: return .yellow
        case .allOut: return .red
        }
    }

    func next() -> Difficulty {
        let all = Difficulty.allCases
        let currentIndex = all.firstIndex(of: self)!
        let nextIndex = all.index(after: currentIndex)
        return nextIndex < Difficulty.allCases.endIndex ? Difficulty.allCases[nextIndex] : Difficulty.allCases[0]
    }
}

struct Activity: Identifiable, Codable {
    var id: String
    var userId: String
    var type: TypeActivity
    var distance: Double?       // nil for weightlifting
    var time: TimeInterval      // in seconds
    var date: Date
    var calories: Int
    var difficulty: Difficulty
    var averagePace: Double?    // min/mile, nil for weightlifting

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case distance
        case time
        case date
        case calories
        case difficulty
        case averagePace = "average_pace"
    }

    var formattedPace: String {
        guard let pace = averagePace, pace > 0 else { return "--:--/mi" }
        let minutes = Int(pace)
        let seconds = Int((pace - Double(minutes)) * 60)
        return String(format: "%d'%02d\"/mi", minutes, seconds)
    }

    var formattedTime: String {
        let totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var formattedDistance: String {
        guard let d = distance else { return "N/A" }
        return String(format: "%.2f mi", d)
    }

    var icon: String {
        switch type {
        case .running: return "figure.run"
        case .biking: return "figure.outdoor.cycle"
        case .weightlifting: return "figure.strengthtraining.traditional"
        case .walking: return "figure.walk"
        }
    }

    var typeName: String {
        switch type {
        case .running: return "Running"
        case .biking: return "Biking"
        case .weightlifting: return "Weightlifting"
        case .walking: return "Walking"
        }
    }
}
