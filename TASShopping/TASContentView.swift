//
//  ContentView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASContentView: View {
    @StateObject private var groceryStoreModel = GroceryStoreModel()
    @State private var showingAddStore = false
    @State private var selectedTabIndex = 0

    var body: some View {
        TabView(selection: $selectedTabIndex) {
            NavigationView {
                VStack {
                    if groceryStoreModel.stores.isEmpty {
                        Text("Create New List")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    } else {
                        List {
                            ForEach(groceryStoreModel.stores) { store in
                                NavigationLink(destination: TASGroceryListView(store: store, groceryStoreModel: groceryStoreModel)) {
                                    VStack(alignment: .leading) {
                                        Text(store.name)
                                            .font(.headline)
                                        Text(store.address)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("My Grocery Lists")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddStore = true }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showingAddStore) {
                    TASAddStoreView(groceryStoreModel: groceryStoreModel)
                }
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            .tag(0)
            
            NavigationView {
               TASImageView(groceryStoreModel: groceryStoreModel)
           }
           .tabItem {
               Image(systemName: "map.fill")
               Text("Routes")
           }
            .tag(1)
        }
    }
}

#Preview {
    TASContentView()
}
