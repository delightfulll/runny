//
//  User.swift
//  Runny
//
//  Created by Vinay Honne  on 2/8/26.
//

import Foundation

struct User: Codable {
    var id: String
    let name: String
    let email: String
    var yesterdayStrain: Double
    var dailyStreak: Int
    var recovery: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case yesterdayStrain = "yesterday_strain"
        case dailyStreak = "daily_streak"
        case recovery
    }
}
