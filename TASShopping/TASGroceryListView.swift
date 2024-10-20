//
//  TASGroceryListView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/19/24.
//

import SwiftUI

struct TASGroceryListView: View {
    let store: Store
    @ObservedObject var groceryStoreModel: GroceryStoreModel
    @State private var newItem = ""
    @State private var showingAlert = false
    @State private var newAddress = ""

    var body: some View {
        VStack {
            Form {
                ForEach(groceryStoreModel.groceryList, id: \.self) { item in
                    HStack {
                        Text(item)
                        Spacer()
                        Button(action: { removeItem(item) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                    }
                }

                HStack {
                    TextField("Add new item", text: $newItem)
                    Button("Add") {
                        addItem()
                    }
                }
                
                Section(header: Text("Store Address")) {
                    TextField("Update address", text: $newAddress)
                    Button("Update Address") { }
                }
            }
        }
        .navigationTitle(store.name)
        .navigationBarItems(trailing:
            Button(action: {
                showingAlert = true
            }) {
                Text("Save Grocery List")
                    .bold()
                    .padding(8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        )
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Saved!"), message: Text("Go to Routes in the tab bar to generate the route."), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            newAddress = store.address
        }
    }

    func addItem() {
        if !newItem.isEmpty {
            groceryStoreModel.groceryList.append(newItem)
            newItem = ""
        }
    }

    func removeItem(_ item: String) {
        groceryStoreModel.groceryList.removeAll { $0 == item }
    }
}

#Preview {
    TASGroceryListView(store: Store(name: "", address: "", state: "", dateAdded: Date(), groceryList: []), groceryStoreModel: GroceryStoreModel())
}
