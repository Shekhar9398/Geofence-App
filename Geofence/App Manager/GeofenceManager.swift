import GoogleMaps
import CoreLocation

///Mark:- GeofenceManager
class GeofenceManager: ObservableObject {
    @Published private var geofenceCoordinates: [[CLLocationCoordinate2D]] = []
    @Published private var geofencePolygons: [GMSPolygon] = []
    @Published private var geofenceMarkers: [GMSMarker] = []
    private var geofenceNumbers: [GMSPolygon: Int] = [:] // ✅ Store geofence numbers
    @Published var selectedGeofence: GMSPolygon?

    @Published var isUserInsideGeofence: Bool = false  // ✅ Track if user is inside a geofence

    //Adding coordinates to "[[CLLocationCoordinate2D]]" array
    func startDrawing() {
        geofenceCoordinates.append([])
    }

    //Append coordinate at last index of array
    func addCoordinate(_ coordinate: CLLocationCoordinate2D) {
        geofenceCoordinates[geofenceCoordinates.count - 1].append(coordinate)
    }

    ///Mark:- Only draw when coordinates (or touches) are more than 2
    func finishDrawing(on mapView: GMSMapView) {
        guard let lastGeofence = geofenceCoordinates.last, lastGeofence.count > 2 else { return }
        
        let path = GMSMutablePath()
        for coordinate in lastGeofence {
            path.add(coordinate)
        }
        
        let polygon = GMSPolygon(path: path)
        polygon.fillColor = getRandomColor().withAlphaComponent(0.4)
        polygon.strokeColor = .black
        polygon.strokeWidth = 3
        polygon.map = mapView
        polygon.isTappable = true
        geofencePolygons.append(polygon)

        let geofenceNumber = geofencePolygons.count
        geofenceNumbers[polygon] = geofenceNumber

        if let centerCoordinate = calculateGeofenceCenter(coordinates: lastGeofence) {
            let geofenceMarker = GMSMarker(position: centerCoordinate)
            geofenceMarker.title = "Geofence \(geofenceNumber)"
            geofenceMarker.icon = GMSMarker.markerImage(with: .systemMint)
            geofenceMarker.map = mapView
            geofenceMarkers.append(geofenceMarker)
        }
    }

    ///Mark:- Load existing geofences (Polygons) on the map
    func loadGeofences(on mapView: GMSMapView) {
        for polygon in geofencePolygons {
            polygon.map = mapView
        }
    }

    func getSelectedGeofenceNumber() -> Int? {
        if let selected = selectedGeofence {
            return geofenceNumbers[selected]
        }
        return nil
    }

    ///Mark:- Clear the selected Geofence
    func clearSelectedGeofence() {
        if let selected = selectedGeofence, let index = geofencePolygons.firstIndex(of: selected) {
            selected.map = nil
            geofencePolygons.remove(at: index)

            if index < geofenceMarkers.count {
                geofenceMarkers[index].map = nil
                geofenceMarkers.remove(at: index)
            }

            geofenceCoordinates.remove(at: index)
            geofenceNumbers.removeValue(forKey: selected)
            selectedGeofence = nil
        }
    }

    ///Mark:- Check if the user is inside any geofence
    func isUserInsideAnyGeofence(userLocation: CLLocationCoordinate2D) -> Bool {
        for polygon in geofencePolygons {
            if isPointInsidePolygon(point: userLocation, polygon: polygon) {
                return true
            }
        }
        return false
    }

    ///Mark:- Helper function to check if a point is inside a polygon
    private func isPointInsidePolygon(point: CLLocationCoordinate2D, polygon: GMSPolygon) -> Bool {
        guard let path = polygon.path else { return false }
        let bounds = GMSCoordinateBounds(path: path)
        return bounds.contains(point)
    }

    ///Mark:- Calculate geofence center for mint marker placement
    private func calculateGeofenceCenter(coordinates: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else { return nil }
        let latSum = coordinates.map { $0.latitude }.reduce(0, +)
        let lngSum = coordinates.map { $0.longitude }.reduce(0, +)
        return CLLocationCoordinate2D(latitude: latSum / Double(coordinates.count),
                                      longitude: lngSum / Double(coordinates.count))
    }

    ///Mark:- Generate a random color for geofence fill
    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.blue, .green, .purple, .orange, .cyan, .magenta, .yellow, .red]
        return colors.randomElement() ?? .blue
    }
}
