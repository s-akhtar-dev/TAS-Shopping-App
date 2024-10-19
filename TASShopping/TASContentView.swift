//
//  ContentView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI
import MapKit

struct TASContentView: View {
    @StateObject private var groceryStoreModel = GroceryStoreModel()
    @StateObject private var locationManager = LocationManager()
    @State private var groceryState: String = "california"
    @State private var storeAddress: String = "16858 Golden Valley Pkwy, Lathrop, CA 95330-8535"
    @State private var groceryList: [String] = ["bedding", "baby", "girls", 
                                                "snacks", "seasonal", "pets"]
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0312),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State private var storeLocation: LocationItem? // Changed to use LocationItem
    @State private var showingMap = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("State", text: $groceryState)
                    HStack {
                        TextField("Store Address", text: $storeAddress)
                        Button(action: {
                            showingMap = true
                        }) {
                            Image(systemName: "map")
                        }
                    }
                    ForEach(groceryList.indices, id: \.self) { index in
                        TextField("Item \(index + 1)", text: $groceryList[index])
                    }
                    Button(action: {
                        groceryList.append("")
                    }) {
                        Text("Add Item")
                    }
                }
                NavigationLink(destination: TASImageView(groceryStoreModel: groceryStoreModel)) {
                    Text("Generate Route")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Shopping List")
            .sheet(isPresented: $showingMap) {
                MapView(region: $region, storeLocation: $storeLocation, storeAddress: $storeAddress)
            }
            .onAppear {
                locationManager.requestLocation()
                updateGroceryStoreModel()
            }
            .onChange(of: locationManager.lastLocation) { location in
                if let location = location {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
            .onDisappear {
                updateGroceryStoreModel()
            }
        }
    }
    
    func updateGroceryStoreModel() {
        groceryStoreModel.state = groceryState
        groceryStoreModel.address = storeAddress
        groceryStoreModel.groceryList = groceryList
    }
}

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var storeLocation: LocationItem?
    @Binding var storeAddress: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: storeLocation.map { [$0] } ?? []) { locationItem in
                MapPin(coordinate: locationItem.coordinate, tint: .red)
            }
            .overlay(
                Circle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: 32, height: 32)
            )
            .gesture(
                DragGesture()
                    .onEnded { _ in
                        storeLocation = LocationItem(coordinate: region.center)
                        updateAddress()
                    }
            )
            
            VStack {
                Spacer()
                Button("Confirm Location") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.bottom)
            }
        }
    }
    
    func updateAddress() {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)) { placemarks, error in
            if let placemark = placemarks?.first {
                storeAddress = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode
                ].compactMap { $0 }.joined(separator: ", ")
            }
        }
    }
}

// Struct to wrap CLLocationCoordinate2D and conform to Identifiable
struct LocationItem: Identifiable {
    let id = UUID() // Unique identifier for each instance
    var coordinate: CLLocationCoordinate2D
}

#Preview {
    TASContentView()
}
