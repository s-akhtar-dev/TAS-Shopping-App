//
//  TASStoreAddView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/19/24.
//

import SwiftUI
import MapKit

struct TASAddStoreView: View {
    @ObservedObject var groceryStoreModel: GroceryStoreModel
    @State private var selectedState = ""
    @State private var searchText = ""
    @State private var stores: [MKMapItem] = []
    @State private var groceryList: [String] = []
    @State private var selectedStore: MKMapItem?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3318, longitude: -122.0312),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @Environment(\.presentationMode) var presentationMode

    let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
                  "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts",
                  "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico",
                  "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
                  "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select State")) {
                    Picker("State", selection: $selectedState) {
                        ForEach(states, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }
                }

                Section(header: Text("Search Target Store")) {
                    TextField("Enter city or address", text: $searchText)
                        .onChange(of: searchText) { _ in searchStores() }

                    if !stores.isEmpty {
                        Picker("Select Store", selection: $selectedStore) {
                            ForEach(stores, id: \.self) { store in
                                Text("\(store.name ?? "Unknown Store") (\(formatAddress(store.placemark)))").tag(store as MKMapItem?)
                            }
                        }
                        .onChange(of: selectedStore) { newValue in
                            if let store = newValue {
                                updateRegion(for: store)
                            }
                        }
                    } else if !searchText.isEmpty {
                        Text("No Target stores found in this area")
                    }
                }

                if let store = selectedStore {
                    Section(header: Text("Selected Store")) {
                        Text(store.name ?? "").bold()
                        Text(formatAddress(store.placemark))
                        
                        Map(coordinateRegion: $region, annotationItems: [IdentifiablePlace(id: UUID(), location: store.placemark.coordinate)]) { place in
                            MapMarker(coordinate: place.location, tint: .red)
                        }
                        .frame(height: 200)
                        .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Add Target Store 🎯")
            .navigationBarItems(trailing: Button("Done") {
                if let store = selectedStore {
                    groceryStoreModel.addStore(name: store.name ?? "",
                                               address: formatAddress(store.placemark),
                                               groceryList: groceryList, state: selectedState)
                }
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                groceryList = groceryStoreModel.groceryList
            }
        }
    }

    func searchStores() {
        guard !selectedState.isEmpty && !searchText.isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Target in \(searchText), \(selectedState)"
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else { return }
            self.stores = response.mapItems.filter { $0.name?.lowercased().contains("target") ?? false }
            if let firstStore = self.stores.first {
                self.selectedStore = firstStore
                self.updateRegion(for: firstStore)
            }
        }
    }

    func updateRegion(for store: MKMapItem) {
        region = MKCoordinateRegion(
            center: store.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }

    func formatAddress(_ placemark: MKPlacemark) -> String {
        let zipPlus4Mapping: [String: String] = [
            "95330": "95330-8535", // Lathrop
            "95035": "95035-1538", // Milpitas
            "95129": "95129-1211", // Cupertino
            "94085": "94085-3110", // Sunnyvale
            "91324": "91324-3343", // Chatsworth
            "92612": "92612-2545", // Irvine
            "95823": "95823-4702", // Sacramento
            "92821": "92821-2705", // Brea
            "91762": "91762-1718", // Ontario
            "90210": "90210-2808", // Beverly Hills
            "92123": "92123-1508", // San Diego
            "91306": "91306-2041", // Winnetka
            "92651": "92651-2042", // Laguna Beach
            "91361": "91361-1348", // Westlake Village
            "94040": "94040-1405", // Mountain View
            "92507": "92507-4965", // Riverside
            "90806": "90806-2113", // Long Beach
            "92508": "92508-5500", // Riverside
            "93003": "93003-1765", // Ventura
            "94621": "94621-1304", // Oakland
            "91730": "91730-5598", // Rancho Cucamonga
            "90815": "90815-1117", // Long Beach
            "95050": "95050-1138", // Santa Clara
            "92115": "92115-4608", // San Diego
            "95834": "95834-3228", // Sacramento
            "94066": "94066-2424", // San Bruno
            "92126": "92126-1918", // San Diego
            "91764": "91764-5002", // Ontario
            "92630": "92630-2802", // Lake Forest
            "94043": "94043-1245", // Mountain View
            "95003": "95003-5800", // Watsonville
            "96002": "96002-0420", // Redding
            "90802": "90802-4713", // Long Beach
            "94022": "94022-1204", // Los Altos
            "95060": "95060-5471", // Santa Cruz
            "92648": "92648-6221", // Huntington Beach
            "91761": "91761-1053", // Ontario
        ]

        
        let number = placemark.subThoroughfare ?? ""
            let street = placemark.thoroughfare ?? ""
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let postalCode = placemark.postalCode ?? ""
            
            // Get the ZIP+4 code from the mapping
            let fullPostalCode = zipPlus4Mapping[postalCode] ?? postalCode
            
            return "\(number) \(street), \(city), \(state) \(fullPostalCode)"
    }
}

struct IdentifiablePlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
}

