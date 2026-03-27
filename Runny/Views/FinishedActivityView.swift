//
//  FinishedActivityView.swift
//  Runny
//
//  Created by Vinay Honne  on 2/8/26.
//

import SwiftUI
import MapKit

struct FinishedActivityView: View {
    @State private var difficulty: Difficulty = .mid
    @State private var showFullMap = false
    @ObservedObject var activityStats: ActivityViewModel
    @Binding var showScreen: Bool
    @EnvironmentObject var userData: UserDataViewModel


    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Good Job for Getting after it!")
                            .font(.largeTitle.bold())
                        Text("Your Results")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                    .navigationBarBackButtonHidden(true)
                    .padding(.horizontal)

                    // Metric Card Builder function-like pattern in-place
                    Group {
                        // Total Distance
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Text("Total Distance")
                                    .font(.headline)
                                Image(systemName: "road.lanes")
                                    .font(.headline.bold())
                                Spacer()
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                HStack {
                                    Text(activityStats.formattedDistance)
                                        .font(.title2.bold())
                                    Spacer()
                                }
                                .padding(16)
                            }
                            .frame(maxWidth: .infinity, minHeight: 90)
                        }

                        // Total Activity Time
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Text("Total Activity Time")
                                    .font(.headline)
                                Image(systemName: "clock.fill")
                                    .font(.headline.bold())
                                Spacer()
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                HStack {
                                    Text(activityStats.formattedTime)
                                        .font(.title2.bold())
                                    Spacer()
                                }
                                .padding(16)
                            }
                            .frame(maxWidth: .infinity, minHeight: 90)
                        }

                        // Average Pace (running and biking only)
                        if activityStats.currentActivity.type == .running || activityStats.currentActivity.type == .biking {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Text("Average Pace")
                                        .font(.headline)
                                    Image(systemName: "tachometer")
                                        .font(.headline.bold())
                                    Spacer()
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color(red: 255/255, green: 218/255, blue: 149/255))
                                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                                    HStack {
                                        Text(activityStats.formattedPace)
                                            .font(.title2.bold())
                                        Spacer()
                                    }
                                    .padding(16)
                                }
                                .frame(maxWidth: .infinity, minHeight: 90)
                            }
                        }

                        // Route Map Card (not shown for weightlifting)
                        if !activityStats.routeCoordinates.isEmpty && activityStats.currentActivity.type != .weightlifting {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    Text("Route")
                                        .font(.headline)
                                    Image(systemName: "map.fill")
                                        .font(.headline.bold())
                                    Spacer()
                                    Text("Tap to expand")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                RouteMapView(coordinates: activityStats.routeCoordinates)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .onTapGesture { showFullMap = true }
                            }
                            .sheet(isPresented: $showFullMap) {
                                NavigationStack {
                                    RouteMapView(coordinates: activityStats.routeCoordinates)
                                        .ignoresSafeArea()
                                        .navigationTitle("Route")
                                        .navigationBarTitleDisplayMode(.inline)
                                        .toolbar {
                                            ToolbarItem(placement: .confirmationAction) {
                                                Button("Done") { showFullMap = false }
                                            }
                                        }
                                }
                            }
                        }

                        // Difficulty
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Text("Difficulty")
                                    .font(.headline)
                                Image(systemName: "flame.fill")
                                    .font(.headline.bold())
                                Spacer()
                                Text("Tap to change")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(difficulty.color.opacity(0.25))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .strokeBorder(difficulty.color, lineWidth: 2)
                                    )
                                    .shadow(color: difficulty.color.opacity(0.2), radius: 8, x: 0, y: 4)
                                HStack {
                                    Text(difficulty.label)
                                        .font(.title2.bold())
                                        .foregroundStyle(difficulty.color)
                                    Spacer()
                                }
                                .padding(16)
                            }
                            .frame(maxWidth: .infinity, minHeight: 90)
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.2)) {
                                    difficulty = difficulty.next()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Done Button
                    Button {
                        activityStats.currentActivity.difficulty = difficulty
                        activityStats.saveWorkout(to: userData)
                        showScreen = false
                        
                    } label: {
                        Text("Done")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 52)
                            .background(
                                LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .clipShape(Capsule())
                            .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 6)
                            .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
