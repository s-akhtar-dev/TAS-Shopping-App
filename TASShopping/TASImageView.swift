//
//  TASImageView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASImageView: View {
    @ObservedObject var groceryStoreModel: GroceryStoreModel
    @State private var showImage: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Button("Generate Route Image") {
                groceryStoreModel.fetchRoute()
                showImage = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if showImage {
                Image(uiImage: groceryStoreModel.image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .transition(.opacity)
                    .onTapGesture {
                        printImageName()
                    }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Route Image")
    }

    func printImageName() {
        print(groceryStoreModel.image.description)
    }
}

#Preview {
    TASImageView(groceryStoreModel: GroceryStoreModel())
}
