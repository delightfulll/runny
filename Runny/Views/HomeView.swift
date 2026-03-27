//
//  ContentView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/18/26.
//

import SwiftUI



struct HomeView: View {
    @EnvironmentObject var userData: UserDataViewModel
    @EnvironmentObject var auth: AuthViewModel
    
    var date: Date = Date()
    
    var body: some View {
        NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome, \(auth.userName)")
                        .font(.largeTitle.bold())
                    Text(date.formatted(Date.FormatStyle()
                        .month(.abbreviated)
                        .day(.twoDigits)
                        .weekday(.abbreviated)))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Strain & Recovery Card
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    HStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Recovery")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.8))
                                    .frame(width: 56, height: 56)
                                Text("\(Int(userData.calculateRecovery()))")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                        VStack(spacing: 8) {
                            Text("Today's Strain")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.85))
                                    .frame(width: 56, height: 56)
                                Text("\(Int(userData.currentStrain))")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity, minHeight: 110)
                .padding(.horizontal)
                
                // Daily Streak Card
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    VStack(spacing: 12) {
                        Text("Daily Streak")
                            .font(.headline)
                        HStack(spacing: 12) {
                            ForEach(0..<7, id: \.self) { index in
                                Circle()
                                    .fill(index < userData.dailyStreak ? Color.green : Color.gray)
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
                    .padding(16)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // Most Recent Activity Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Most Recent Activity")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if let recentActivity = userData.recentActivities.first {
                        NavigationLink {
                            ActivityDetailView(activity: recentActivity)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                HStack(spacing: 12) {
                                    Image(systemName: recentActivity.icon)
                                        .font(.system(size: 28, weight: .semibold))
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(recentActivity.typeName)
                                            .font(.headline)
                                        Text("\(recentActivity.formattedDistance) • \(recentActivity.formattedTime) • \(recentActivity.formattedPace)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(16)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Empty state
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.gray.opacity(0.1))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                            VStack(spacing: 8) {
                                Image(systemName: "figure.run.circle")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.gray)
                                Text("No activities yet")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Start your first workout!")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                        }
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 16)
            }
            .padding(.bottom, 24)
        }
        .onAppear {
            userData.calculateStrain()
        }
        }
    }
}
