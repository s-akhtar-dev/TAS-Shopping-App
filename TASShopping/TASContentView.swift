//
//  ContentView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASContentView: View {
    @State private var groceryList: [String] = []
    @State private var storeAddress: String = ""
    @State private var state: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    TextField("State", text: $state)
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
                NavigationLink(destination: TASImageView(state: state, address: storeAddress, groceryList: groceryList)) {
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
