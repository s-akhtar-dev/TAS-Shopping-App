//
//  GroceryStore.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/19/24.
//

import Foundation
import SwiftUI

class GroceryStoreModel: ObservableObject {
    @Published var state: String = "DefaultState"
    @Published var address: String = "DefaultAddress"
    @Published var groceryList: [String] = ["DefaultList"]
    @Published var image: UIImage = UIImage()
    @Published var isDoneShopping: Bool = false
    
    init(state: String, address: String, groceryList: [String], image: UIImage, isDoneShopping: Bool) {
        self.state = state
        self.address = address
        self.groceryList = groceryList
        self.image = image
        self.isDoneShopping = isDoneShopping
    }
    
    init() { }
    
    func fetchRoute(forAPI developerKey: String) {
        let url = URL(string: "https://oj35b6kjt7.execute-api.us-west-2.amazonaws.com/default/create_route")!
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(developerKey, forHTTPHeaderField: "x-api-key")
        
        let body: [String: Any] = ["state": state, "address": address, "grocery_list": groceryList]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let base64Image = jsonResponse["image"] as? String,
                   let imageData = Data(base64Encoded: base64Image) {
                    self.image = UIImage(data: imageData)!
                }
            }
        }.resume()
    }
}
