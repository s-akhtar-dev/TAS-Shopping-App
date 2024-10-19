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
    @State private var groceryState: String = ""
    @State private var storeAddress: String = ""
    @State private var groceryList: [String] = [""]

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("State", text: $groceryState)
                    TextField("Store Address", text: $storeAddress)
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
        }
    }
}

#Preview {
    TASContentView()
}
