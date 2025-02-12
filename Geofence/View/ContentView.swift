import SwiftUI
import GoogleMaps

/// MARK: - ContentView.swift - Main UI
struct ContentView: View {
    @State private var openGoogleMap = false

    var body: some View {
      
        NavigationView{
            ///Mark:- Navigate to MainView
            NavigationLink(destination: MainView(), isActive: $openGoogleMap){
                
            }
            
            ///Mark:- Button to Navigate
            VStack {
                Button {
                    withAnimation {
                        openGoogleMap = true
                    }
                    
                } label: {
                    VStack{
                        Image(systemName: "bonjour")
                            .imageScale(.large)
                            .foregroundColor(.red)
                        
                        Text("Create Geofence")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.mint)
                    }
                }
                .padding()
                .overlay{
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green, lineWidth: 2)
                }
            }
            .navigationTitle("Welcome to Geofence App")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea()
        }
      }
    }

