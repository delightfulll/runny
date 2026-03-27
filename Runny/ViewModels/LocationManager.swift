//
//  LocationManager.swift
//  Runny
//
//  Created by Vinay Honne on 2/12/26.
//

import Foundation
import CoreLocation
import MapKit

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    var userLocation: CLLocationCoordinate2D?
    var totalDistance: Double = 0.0 // in kilometers
    var routeCoordinates: [CLLocationCoordinate2D] = []
    
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private var lastLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // Update every 5 meters for better accuracy
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        lastLocation = nil // reset so we don't get a bogus distance jump on resume
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        lastLocation = nil
    }
    
    func resetDistance() {
        totalDistance = 0.0
        lastLocation = nil
        routeCoordinates = []
    }
    
    // MARK: - CLLocationManagerDelegate methods below
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Accumulate distance between consecutive GPS points
        if let last = lastLocation {
            let deltaMeters = location.distance(from: last)
            // Ignore implausible jumps (>50 m/s ≈ 180 km/h) that indicate bad GPS readings
            let deltaSeconds = location.timestamp.timeIntervalSince(last.timestamp)
            if deltaSeconds > 0 && (deltaMeters / deltaSeconds) < 50 {
                totalDistance += deltaMeters / 1000.0
            }
        }
        lastLocation = location
        routeCoordinates.append(location.coordinate)
        userLocation = location.coordinate
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdatingLocation()
        case .denied, .restricted:
            // Handle denied access
            break
        case .notDetermined:
            requestPermission()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
