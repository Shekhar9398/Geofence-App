import UIKit
import GoogleMaps

///Mark:- MapViewController
class MapViewController: UIViewController, GMSMapViewDelegate {
    var mapView: GMSMapView!
    var locationManager: LocationManager
    var geofenceManager: GeofenceManager
    var isDrawingEnabled: Bool
    private var userLocationMarker: GMSMarker?

    private var liveDrawingPath: GMSMutablePath?
    private var liveDrawingPolyline: GMSPolyline?

    init(locationManager: LocationManager, geofenceManager: GeofenceManager, isDrawingEnabled: Bool) {
        self.locationManager = locationManager
        self.geofenceManager = geofenceManager
        self.isDrawingEnabled = isDrawingEnabled
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(
            withLatitude: locationManager.userLocation?.latitude ?? 18.5204,
            longitude: locationManager.userLocation?.longitude ?? 73.8567,
            zoom: 15.0
        )

        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        self.view.addSubview(mapView)

        updateUserLocationMarker()
        geofenceManager.loadGeofences(on: mapView)
        updateMapGestures()
        addDrawingGesture()

        locationManager.onLocationUpdate = { [weak self] newLocation in
            guard let self = self else { return }
            self.updateUserLocationMarker()

            let isInside = self.geofenceManager.isUserInsideAnyGeofence(userLocation: newLocation)

            if isInside && !self.geofenceManager.isUserInsideGeofence {
                self.geofenceManager.isUserInsideGeofence = true
                self.showGeofencePopup()
            } else if !isInside {
                self.geofenceManager.isUserInsideGeofence = false
            }
        }
    }

    func updateMapGestures() {
        mapView.settings.scrollGestures = !isDrawingEnabled
        mapView.settings.zoomGestures = !isDrawingEnabled
        mapView.settings.rotateGestures = !isDrawingEnabled
        mapView.settings.tiltGestures = !isDrawingEnabled
    }

    private func updateUserLocationMarker() {
        guard let userLocation = locationManager.userLocation else { return }

        if let marker = userLocationMarker {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            marker.position = userLocation
            CATransaction.commit()
        } else {
            userLocationMarker = GMSMarker(position: userLocation)
            userLocationMarker?.title = "You are here"
            userLocationMarker?.icon = GMSMarker.markerImage(with: .red)
            userLocationMarker?.map = mapView
        }
    }

    private func addDrawingGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        mapView.addGestureRecognizer(panGesture)
    }

    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard isDrawingEnabled else { return }

        let touchPoint = gesture.location(in: mapView)
        let coordinate = mapView.projection.coordinate(for: touchPoint)

        switch gesture.state {
        case .began:
            geofenceManager.startDrawing()
            geofenceManager.addCoordinate(coordinate)

            liveDrawingPath = GMSMutablePath()
            liveDrawingPath?.add(coordinate)
            liveDrawingPolyline = GMSPolyline(path: liveDrawingPath)
            liveDrawingPolyline?.strokeColor = .blue
            liveDrawingPolyline?.strokeWidth = 3
            liveDrawingPolyline?.map = mapView

        case .changed:
            geofenceManager.addCoordinate(coordinate)
            liveDrawingPath?.add(coordinate)
            liveDrawingPolyline?.path = liveDrawingPath

        case .ended:
            geofenceManager.finishDrawing(on: mapView)
            liveDrawingPolyline?.map = nil
            liveDrawingPolyline = nil
            liveDrawingPath = nil

        default:
            break
        }
    }

    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        if let polygon = overlay as? GMSPolygon {
            geofenceManager.selectedGeofence = polygon
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.locationManager.userLocation = location.coordinate
            self.updateUserLocationMarker()
        }
    }
    
    private func showGeofencePopup() {
        let alert = UIAlertController(title: "Geofence Alert",
                                      message: "You have entered a geofenced area.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
