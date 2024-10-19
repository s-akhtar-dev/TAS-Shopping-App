//
//  TASImageView.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/18/24.
//

import SwiftUI

struct TASImageView: View {
    let state: String
    let address: String
    let groceryList: [String]
    
    @State private var routeImage: UIImage?

    var body: some View {
        VStack {
            if let image = routeImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Generating route...")
                    .onAppear(perform: fetchRoute)
            }
        }
        .navigationTitle("Route Image")
    }

    func fetchRoute() {
        let url = URL(string: "https://oj35b6kjt7.execute-api.us-west-2.amazonaws.com/default/create_route")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Your-API-Key", forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = ["state": state, "address": address, "grocery_list": groceryList]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let base64Image = jsonResponse["image"] as? String,
                   let imageData = Data(base64Encoded: base64Image) {
                    DispatchQueue.main.async {
                        routeImage = UIImage(data: imageData)
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    TASImageView(state: "", address: "", groceryList: [""])
}
