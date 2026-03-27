//
//  RouteStore.swift
//  Runny
//

import Foundation
import CoreLocation

private struct RouteCoordinate: Codable {
    let latitude: Double
    let longitude: Double
}

enum RouteStore {
    static func save(route: [CLLocationCoordinate2D], forActivityId id: String) {
        guard !route.isEmpty else { return }
        let coords = route.map { RouteCoordinate(latitude: $0.latitude, longitude: $0.longitude) }
        if let data = try? JSONEncoder().encode(coords) {
            UserDefaults.standard.set(data, forKey: "route_\(id)")
        }
    }

    static func load(forActivityId id: String) -> [CLLocationCoordinate2D] {
        guard let data = UserDefaults.standard.data(forKey: "route_\(id)"),
              let coords = try? JSONDecoder().decode([RouteCoordinate].self, from: data) else {
            return []
        }
        return coords.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    /// Moves a saved route from one activity ID key to another (e.g. client ID → server ID).
    static func rekey(from oldId: String, to newId: String) {
        guard let data = UserDefaults.standard.data(forKey: "route_\(oldId)") else { return }
        UserDefaults.standard.set(data, forKey: "route_\(newId)")
        UserDefaults.standard.removeObject(forKey: "route_\(oldId)")
    }
}
