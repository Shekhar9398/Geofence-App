
import SwiftUI
import GoogleMaps
import GooglePlaces

@available(iOS 15.0, *)
@main
struct GeofenceApp: App {
    ///Mark:- Add API Key here
    var googleApiKey = "AIzaSyAFHB2cAT1jaLZI5ZBDflAGx0xadAd2mUw"
    
    ///Mark: Initialize the GoogleMaps Services (afrer adding queryItem in Info.plist)
    init(){
        GMSServices.provideAPIKey(googleApiKey)
        GMSPlacesClient.provideAPIKey(googleApiKey)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}




    
