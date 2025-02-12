import SwiftUI
import GoogleMaps

// MARK: - GoogleMapView.swift - SwiftUI Integration
struct GoogleMapView: UIViewControllerRepresentable {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var geofenceManager: GeofenceManager
    @Binding var isDrawingEnabled: Bool
    
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController(locationManager: locationManager,
                                 geofenceManager: geofenceManager,
                                 isDrawingEnabled: isDrawingEnabled)
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.isDrawingEnabled = isDrawingEnabled
        uiViewController.updateMapGestures()
    }
}
