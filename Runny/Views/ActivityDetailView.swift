//
//  ActivityDetailView.swift
//  Runny
//
//  Created by Vinay Honne on 2/12/26.
//

import SwiftUI
import MapKit

struct ActivityDetailView: View {
    let activity: Activity
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var showFullMap = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                // Header with activity type
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 60, height: 60)
                        Image(systemName: activity.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.typeName)
                            .font(.title.bold())
                        Text(activity.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Main stats cards
                VStack(spacing: 16) {
                    // Distance Card
                    if activity.type == .running || activity.type == .biking || activity.type == .walking {
                        MetricCard(
                            title: "Total Distance",
                            value: activity.formattedDistance,
                            icon: "road.lanes"
                        )
                    }
                    
                    // Time Card
                    MetricCard(
                        title: "Total Time",
                        value: activity.formattedTime,
                        icon: "clock.fill"
                    )

                    // Pace Card (running and biking only)
                    if activity.type == .running || activity.type == .biking {
                        MetricCard(
                            title: "Average Pace",
                            value: activity.formattedPace,
                            icon: "speedometer"
                        )
                    }
                    
                    // Calories Card
                    if activity.calories > 0 {
                        MetricCard(
                            title: "Calories Burned",
                            value: "\(activity.calories) cal",
                            icon: "flame.fill"
                        )
                    }

                    // Difficulty Card
                    MetricCard(
                        title: "Difficulty",
                        value: activity.difficulty.label,
                        icon: "flame.fill",
                        difficultyColor: activity.difficulty.color)

                    // Route Map Card (not shown for weightlifting)
                    if !routeCoordinates.isEmpty && activity.type != .weightlifting {
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
                            RouteMapView(coordinates: routeCoordinates)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onTapGesture { showFullMap = true }
                        }
                        .sheet(isPresented: $showFullMap) {
                            NavigationStack {
                                RouteMapView(coordinates: routeCoordinates)
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
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Activity Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            routeCoordinates = RouteStore.load(forActivityId: activity.id)
        }
    }
}

// MARK: - Route Map Component

struct RouteMapView: View {
    let coordinates: [CLLocationCoordinate2D]

    private var region: MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        let lats = coordinates.map { $0.latitude }
        let lons = coordinates.map { $0.longitude }
        let centerLat = (lats.min()! + lats.max()!) / 2
        let centerLon = (lons.min()! + lons.max()!) / 2
        let spanLat = max((lats.max()! - lats.min()!) * 1.5, 0.002)
        let spanLon = max((lons.max()! - lons.min()!) * 1.5, 0.002)
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon)
        )
    }

    var body: some View {
        Map(position: .constant(.region(region))) {
            MapPolyline(coordinates: coordinates)
                .stroke(.red, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            if let start = coordinates.first {
                Annotation("", coordinate: start) {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
            if let end = coordinates.last, coordinates.count > 1 {
                Annotation("", coordinate: end) {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(.white, lineWidth: 2))
                }
            }
        }
        .disabled(true)
    }
}

// MARK: - Metric Card Component
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    var difficultyColor: Color? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.headline)
                Image(systemName: icon)
                    .font(.headline.bold())
                Spacer()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(difficultyColor ?? Color(red: 255/255, green: 218/255, blue: 149/255))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                
                HStack {
                    Text(value)
                        .font(.title2.bold())
                    Spacer()
                }
                .padding(16)
            }
            .frame(maxWidth: .infinity, minHeight: 70)
        }
    }
}

