//
//  RecentsView.swift
//  Runny
//
//  Created by Vinay Honne  on 1/21/26.
//

import SwiftUI

struct RecentsView: View {
    @EnvironmentObject var userData: UserDataViewModel

    var body: some View {
        NavigationStack {
            Group {
                if userData.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if userData.recentActivities.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run.circle")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.5))
                        Text("Psst, You don't have any recorded activities.")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Get after it!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        Text("Your Past Activities")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        ForEach(userData.recentActivities) { activity in
                            ZStack {
                                NavigationLink(destination: ActivityDetailView(activity: activity)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                ActivityCard(activity: activity)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    userData.deleteActivity(id: activity.id)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        userData.loadFromServer()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if userData.recentActivities.isEmpty {
                    userData.loadFromServer()
                }
            }
        }
    }
}

// MARK: - Activity Card Component
struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            HStack(spacing: 14) {
                // Activity icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 50, height: 50)
                    Image(systemName: activity.icon)
                        .font(.system(size: 24, weight: .semibold))
                }
                
                // Activity details
                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.typeName)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text(activity.formattedDistance)
                        Text("•")
                        Text(activity.formattedTime)
                        if activity.type == .running || activity.type == .biking {
                            Text("•")
                            Text(activity.formattedPace)
                        }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
    }
}

#Preview {
    RecentsView()
        .environmentObject(UserDataViewModel())
}