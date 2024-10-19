//
//  TASImageView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASImageView: View {
    @ObservedObject var groceryStoreModel: GroceryStoreModel
    
    var body: some View {
        VStack {
            Image(uiImage: groceryStoreModel.image)
                .resizable()
                .scaledToFit()
        }
        .navigationTitle("Route Image")
        .onAppear { groceryStoreModel.fetchRoute(forAPI: "") }
    }
}

#Preview {
    TASImageView(groceryStoreModel: GroceryStoreModel())
}
