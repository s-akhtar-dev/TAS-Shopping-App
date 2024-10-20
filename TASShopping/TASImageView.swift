//
//  TASImageView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASImageView: View {
    @ObservedObject var groceryStoreModel: GroceryStoreModel
    @State private var selectedStore: Store?
    @State private var showingImageSheet = false

    var body: some View {
        List {
            ForEach(groceryStoreModel.stores) { store in
                VStack(alignment: .leading) {
                    Text(store.name)
                        .font(.headline)
                    Text(store.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Button("Generate Image") {
                        selectedStore = store
                        groceryStoreModel.fetchRoute(for: store) // No need for a completion handler here
                        showingImageSheet = true // Show the sheet right away
                    }
                    .padding(.top, 5)
                    .foregroundColor(.green)
                }
                .padding(.vertical, 5)
            }
        }
        .navigationTitle("Saved Routes")
        .sheet(isPresented: $showingImageSheet) {
            if let store = selectedStore {
                ImageSheetView(groceryStoreModel: groceryStoreModel, store: store)
            }
        }
    }
}

struct ImageSheetView: View {
    @ObservedObject var groceryStoreModel: GroceryStoreModel
    let store: Store
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                if groceryStoreModel.isLoading {
                    ProgressView("Generating route image...")
                } else if let image = groceryStoreModel.routeImage(for: store) {
                    ZoomableImageView(image: image)
                } else {
                    Button("Load Image") {
                        groceryStoreModel.fetchRoute(for: store)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("Route Image")
        }
        .onAppear {
            // Set loading state
            groceryStoreModel.isLoading = true
            groceryStoreModel.fetchRoute(for: store)
        }
        .onDisappear {
            // Reset loading state when leaving the view
            groceryStoreModel.isLoading = false
        }
    }
}

struct ZoomableImageView: View {
    let image: UIImage
    @State private var scale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .frame(width: geometry.size.width * scale, height: geometry.size.height * scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = value.magnitude
                            }
                    )
            }
        }
    }
}

#Preview {
    TASImageView(groceryStoreModel: GroceryStoreModel())
}
