//
//  GroceryStore.swift
//  TASShopping
//
//  Created by Sarah Akhtar on 10/19/24.
//

import Foundation
import SwiftUI

struct Store: Identifiable {
    let id = UUID()
    var name: String
    var address: String
    var state: String
    var dateAdded: Date
    var groceryList: [String]
}

class GroceryStoreModel: ObservableObject {
    @Published var stores: [Store] = []
    @Published var groceryList: [String] = ["Bed", "Baby", "Clothes", "Chips", "Seasonal", "Pet"]
    @Published var image: UIImage = UIImage()
    @Published var isDoneShopping: Bool = false
    @Published var isLoading: Bool = false
    private var routeImages: [UUID: UIImage] = [:]

    let baseUrl = "https://oj35b6kjt7.execute-api.us-west-2.amazonaws.com/default/"
    let apiKey = "ZSW7wbMB6E9UHbBaCcqOg9CYJ5js4NgD1p6osB0G"

    init() { }
    
    func addStore(name: String, address: String, groceryList: [String]? = nil, state: String) {
        let newStore = Store(name: name, address: address, state: state, dateAdded: Date(), groceryList: groceryList ?? [""])
        stores.append(newStore)
    }
    
    func routeImage(for store: Store) -> UIImage? {
        return routeImages[store.id]
    }

    func fetchRoute(for store: Store) {
        print(store.state)
        print(store.address)
        print(store.groceryList)
        // Step 1: Get Categories
        getCategories(for: store) { categories in
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
                self.createRoute(for: store, groceryDic: groceryDic)
            }
        }
    }

    private func getCategories(for store: Store, completion: @escaping ([String]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)get_categories") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = ["state": store.state, "address": store.address]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(response?.description ?? "Unknown error")")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let categories = jsonResponse["labels"] as? [String] {
                    completion(categories)
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
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

    private func createRoute(for store: Store, groceryDic: [String: [String]]) {
        guard let url = URL(string: "\(baseUrl)create_route") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = ["state": store.state, "address": store.address, "grocery_dic": groceryDic]
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

    
    func removeItem(from store: Store, item: String) {
        if let index = stores.firstIndex(where: { $0.id == store.id }) {
            stores[index].groceryList.removeAll { $0 == item }
        }
    }
    
    func addItem(to store: Store, item: String) {
        if let index = stores.firstIndex(where: { $0.id == store.id }) {
            stores[index].groceryList.append(item)
        }
    }
}
