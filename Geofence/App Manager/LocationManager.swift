//import SwiftUI
//import GoogleMaps
//import CoreLocation
//
//// MARK: - LocationManager.swift - Tracks User Location
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    private var locationManager = CLLocationManager()
//    @Published var userLocation: CLLocationCoordinate2D?
//
//    ///Closure to notify about location updates
//    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    ///Mark:- method to update user location
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        
//        DispatchQueue.main.async {
//            self.userLocation = location.coordinate
//            self.onLocationUpdate?(location.coordinate)
//        }
//    }
//}

import SwiftUI
import GoogleMaps
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    private var bestLocation: CLLocation?

    var onLocationUpdate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 7

        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(restartLocationUpdates), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func restartLocationUpdates() {
        locationManager.startUpdatingLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        if locationManager.accuracyAuthorization == .reducedAccuracy {
            locationManager.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "FullAccuracyLocation")
        }

        if bestLocation == nil || location.horizontalAccuracy < bestLocation!.horizontalAccuracy {
            bestLocation = location
        }

        if let best = bestLocation, best.horizontalAccuracy < 75 {
            DispatchQueue.main.async {
                self.userLocation = best.coordinate
                self.onLocationUpdate?(best.coordinate)
            }
            bestLocation = nil
        }
    }
}
