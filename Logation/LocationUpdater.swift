//
//  LocationUpdater.swift
//  Logation
//
//  Created by Subedi, Rikesh on 10/03/21.
//

import Foundation
import CoreLocation
class LocationUpdater:NSObject {
    var lastLocation: CLLocation?
    var dedicatedCallback: ((CLLocation)->Void)? = nil
    public static let shared = LocationUpdater()
    var locationManager: CLLocationManager
    private override init() {
        locationManager = CLLocationManager.init()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestAlwaysAuthorization()
    }

    func startUpdating(callback: ((CLLocation)->Void)? = nil) {
        self.dedicatedCallback = callback
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    private func locationUpdated() {
        if let location = self.lastLocation {
            self.dedicatedCallback?(location)
        }
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationUpdater: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            self.lastLocation = locations[0]
            self.stopUpdating()
            self.locationUpdated()
        }
    }
}
