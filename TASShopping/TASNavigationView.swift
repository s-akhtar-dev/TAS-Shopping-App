//
//  TASNavigationView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI
import CoreLocation

struct TASNavigationView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let location = locationManager.lastLocation {
                Text("Current Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            } else {
                Text("Tracking Location...")
            }
        }
        .onAppear {
            locationManager.startTracking()
        }
        .onDisappear {
            locationManager.stopTracking()
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        manager.startUpdatingLocation()
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
    }
}

#Preview {
    TASNavigationView()
}
