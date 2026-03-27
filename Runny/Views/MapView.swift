//
//  MapView.swift
//  Runny
//
//  Created by Vinay Honne  on 2/8/26.
//

import SwiftUI
import MapKit

struct MapView: View {
    var locationManager: LocationManager
    
    var body: some View {
        Map(position: .constant(.region(locationManager.region))) {
            // Show user location marker
            if let userLocation = locationManager.userLocation {
                Annotation("You",coordinate: userLocation) {
                    ZStack {
                        Circle()
                            .fill(.red)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(.white)
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .frame(width: 300, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MapView(locationManager: LocationManager())
}
