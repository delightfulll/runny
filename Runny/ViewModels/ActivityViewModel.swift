//
//  ActivityViewModel.swift
//  Runny
//
//  Created by Vinay Honne  on 2/8/26.
//

import Foundation
import Combine
import CoreLocation


class ActivityViewModel: ObservableObject {
    
    // Current activity user selects
    @Published var currentActivity: Activity
    
    // Timer state
    @Published var isTimerRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var elapsedTime: Int = 0
    
    // Activity metrics
    @Published var distance: Double = 0.0
    @Published var currentPace: Double = 0.0
    @Published var averagePace: Double = 0.0
    @Published var calories: Int = 0
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    
    private var timer: Timer?
    private var startTime: Date?
    
    init(currentActivity: Activity) {
        self.currentActivity = currentActivity
    }
    
    // Start tracking the workout
    func startWorkout() {
        guard !isTimerRunning else { return }
        
        isTimerRunning = true
        isPaused = false
        startTime = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
            self.updateMetrics()
        }
    }
    
    // Pause the workout
    func pauseWorkout() {
        guard isTimerRunning, !isPaused else { return }
        
        isPaused = true
        timer?.invalidate()
        timer = nil
    }
    
    // Resume the workout
    func resumeWorkout() {
        guard isPaused else { return }
        
        isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
            self.updateMetrics()
        }
    }
    
    // Stop the workout completely
    func stopWorkout() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        isPaused = false
    }
    
    // Update activity metrics during workout
    private func updateMetrics() {
        #if targetEnvironment(simulator)
        // Simulate movement in the Xcode Simulator (real GPS isn't available).
        // Speeds: running ~10 km/h, biking ~20 km/h, weightlifting ~0 km/h.
        let simulatedSpeedKmPerSec: Double
        switch currentActivity.type {
        case .running:       simulatedSpeedKmPerSec = 10.0 / 3600.0
        case .biking:        simulatedSpeedKmPerSec = 20.0 / 3600.0
        case .weightlifting: simulatedSpeedKmPerSec = 0.0
        case .walking:       simulatedSpeedKmPerSec = 5.0 / 3600.0
        }
        distance += simulatedSpeedKmPerSec

        // Simulate a GPS trail by nudging coordinates slightly each second.
        let baseCoord = routeCoordinates.last ?? CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let nudge = simulatedSpeedKmPerSec / 111.0 // ~111 km per degree latitude
        routeCoordinates.append(CLLocationCoordinate2D(
            latitude: baseCoord.latitude + nudge,
            longitude: baseCoord.longitude + nudge * 0.3
        ))
        #endif
        
        // Calculate average pace (min/mile)
        let distanceInMiles = distance * 0.621371
        if distanceInMiles > 0 {
            averagePace = Double(elapsedTime) / 60.0 / distanceInMiles
        }
        
        // Estimate calories based on activity type and time
        calories = estimateCalories()
    }
    
    // Estimate calories burned based on activity type
    private func estimateCalories() -> Int {
        let minutes = Double(elapsedTime) / 60.0
        
        switch currentActivity.type {
        case .running:       return Int(minutes * 10.0)
        case .biking:        return Int(minutes * 8.0)
        case .weightlifting: return Int(minutes * 6.0)
        case .walking:       return Int(minutes * 4.0)
        }
    }
    
    // Update distance manually or from location tracking
    func updateDistance(_ newDistance: Double) {
        distance = newDistance
    }


    // Save the completed workout to the shared user data
    func saveWorkout(to userData: UserDataViewModel) {
        stopWorkout()

        let distanceInMiles = distance * 0.621371
        let hasDistance = currentActivity.type != .weightlifting
        currentActivity.distance = hasDistance ? distanceInMiles : nil
        currentActivity.time = TimeInterval(elapsedTime)
        currentActivity.date = startTime ?? Date()
        currentActivity.calories = calories

        if hasDistance && distanceInMiles > 0 {
            currentActivity.averagePace = (TimeInterval(elapsedTime) / 60.0) / distanceInMiles
        } else {
            currentActivity.averagePace = nil
        }

        RouteStore.save(route: routeCoordinates, forActivityId: currentActivity.id)
        userData.saveActivity(activity: currentActivity)
        userData.calculateStrain()
    }
    
    // Reset the workout without saving
    func resetWorkout() {
        stopWorkout()
        elapsedTime = 0
        distance = 0.0
        currentPace = 0.0
        averagePace = 0.0
        calories = 0
        startTime = nil
        routeCoordinates = []
    }
    
    // Format elapsed time as HH:MM:SS
    var formattedTime: String {
        let hours = elapsedTime / 3600
        let minutes = (elapsedTime % 3600) / 60
        let seconds = elapsedTime % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // Format distance with units
    var formattedDistance: String {
        return String(format: "%.2f mi", distance * 0.621371)
    }
    
    // Format pace
    var formattedPace: String {
        if averagePace > 0 {
            let minutes = Int(averagePace)
            let seconds = Int((averagePace - Double(minutes)) * 60)
            return String(format: "%d:%02d /mi", minutes, seconds)
        }
        return "--:-- /mi"
    }
    
}
