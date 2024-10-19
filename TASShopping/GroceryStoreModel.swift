//
//  GroceryStore.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/19/24.
//

import Foundation
import SwiftUI

class GroceryStoreModel: ObservableObject {
    @Published var state: String = "california"
    @Published var address: String = "16858 Golden Valley Pkwy, Lathrop, CA 95330-8535"
    @Published var groceryList: [String] = ["bedding", "baby", "girls", "snacks", "seasonal", "pets"]
    @Published var image: UIImage = UIImage()
    @Published var isDoneShopping: Bool = false

    let baseUrl = "https://oj35b6kjt7.execute-api.us-west-2.amazonaws.com/default/"
    let apiKey = "ZSW7wbMB6E9UHbBaCcqOg9CYJ5js4NgD1p6osB0G"

    init() { }

    func fetchRoute() {
        // Step 1: Get Categories
        getCategories { categories in
            guard let categories = categories else {
                print("Error fetching categories")
                return
            }
            
            // Step 2: Categorize Items
            self.categorizeItems(categories: categories) { groceryDic in
                guard let groceryDic = groceryDic else {
                    print("Error categorizing items")
                    return
                }
                
                // Step 3: Create Route and fetch Image
                self.createRoute(groceryDic: groceryDic)
            }
        }
    }

    private func getCategories(completion: @escaping ([String]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)get_categories") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = ["state": state, "address": address]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let categories = jsonResponse["labels"] as? [String] {
                    completion(categories)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func categorizeItems(categories: [String], completion: @escaping ([String: [String]]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)categorize_items") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = ["categories": categories, "grocery_list": groceryList]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
                    completion(jsonResponse)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }

    private func createRoute(groceryDic: [String: [String]]) {
        guard let url = URL(string: "\(baseUrl)create_route") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = ["state": state, "address": address, "grocery_dic": groceryDic]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let base64Image = jsonResponse["image"] as? String,
                   let imageData = Data(base64Encoded: base64Image) {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: imageData) ?? UIImage()
                    }
                }
            }
        }.resume()
    }
}
