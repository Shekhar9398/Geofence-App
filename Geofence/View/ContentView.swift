import SwiftUI
import GoogleMaps

/// MARK: - ContentView.swift - Main UI
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var geofenceManager = GeofenceManager() // ✅ Keep as @StateObject
    @State private var isDrawingEnabled = false
    @State private var showDeleteAlert = false
    @State private var selectedGeofenceNumber: Int?

    var body: some View {
        ZStack {
            GoogleMapView(locationManager: locationManager,
                          geofenceManager: geofenceManager,
                          isDrawingEnabled: $isDrawingEnabled)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    //Toggle Drawing Mode Button
                    Button(action: {
                        isDrawingEnabled.toggle()
                        print("[ContentView.swift] Drawing mode set to \(isDrawingEnabled)")
                    }) {
                        Text(isDrawingEnabled ? "Stop Drawing" : "Start Drawing")
                            .padding()
                            .background(isDrawingEnabled ? Color.red : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        if let geofenceNumber = geofenceManager.getSelectedGeofenceNumber() {
                            selectedGeofenceNumber = geofenceNumber
                            showDeleteAlert = true
                        }
                    }) {
                        Text("Clear Selected Geofence")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Geofence"),
                message: Text("Are you sure you want to delete Geofence \(selectedGeofenceNumber ?? 0)?"),
                primaryButton: .destructive(Text("Delete")) {
                    geofenceManager.clearSelectedGeofence()
                    print("[ContentView] Geofence \(selectedGeofenceNumber!) has been deleted")
                },
                secondaryButton: .cancel()
            )
        }
    }
}
