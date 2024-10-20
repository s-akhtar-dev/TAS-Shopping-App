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

    func fetchRoute(for store: Store, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            print(store.id)
            print(store.name)
            print(store.address)
            print(store.state)
            print(store.dateAdded)
            print(store.groceryList)
            
            self.isLoading = true
            self.getCategories(for: store) { categories in
                guard let categories = categories else {
                    print("Error fetching categories")
                    self.isLoading = false
                    completion()
                    return
                }
                
                self.categorizeItems(categories: categories, groceryList: store.groceryList) { groceryDic in
                    guard let groceryDic = groceryDic else {
                        print("Error categorizing items")
                        self.isLoading = false
                        completion()
                        return
                    }
                    
                    self.createRoute(groceryDic: groceryDic, for: store) {
                        self.isLoading = false
                        completion()
                    }
                }
            }
        }
    }

        private func getCategories(for store: Store, completion: @escaping ([String]?) -> Void) {
            guard let url = URL(string: "\(baseUrl)/get_categories") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

            // Convert state and address to lowercase as per API requirements
            let body: [String: Any] = [
                "state": store.state.lowercased(),
                "address": store.address
            ]
            
            print("Categories Request Body:", body) // Add logging
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Network Error:", error) // Add error logging
                    completion(nil)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response Status Code:", httpResponse.statusCode) // Add status code logging
                }
                
                if let data = data {
                    print("Raw Response Data:", String(data: data, encoding: .utf8) ?? "Invalid data") // Add response logging
                    
                    if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let categories = jsonResponse["labels"] as? [String] {
                        print("Parsed Categories:", categories) // Add parsed data logging
                        completion(categories)
                    } else {
                        print("Failed to parse JSON response") // Add parsing error logging
                        completion(nil)
                    }
                } else {
                    print("No data received") // Add no data logging
                    completion(nil)
                }
            }.resume()
        }

    private func categorizeItems(categories: [String], groceryList: [String], completion: @escaping ([String: [String]]?) -> Void) {
        guard let url = URL(string: "\(baseUrl)/categorize_items") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = [
            "categories": categories,
            "grocery_list": groceryList
        ]
        
        print("Categorize Items Request Body:", body)
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network Error in categorizeItems:", error)
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("categorizeItems Response Status Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                print("categorizeItems Raw Response Data:", String(data: data, encoding: .utf8) ?? "Invalid data")
                
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: [String]] {
                    print("Parsed categorizeItems Response:", jsonResponse)
                    completion(jsonResponse)
                } else {
                    print("Failed to parse categorizeItems JSON response")
                    completion(nil)
                }
            } else {
                print("No data received from categorizeItems")
                completion(nil)
            }
        }.resume()
    }

    private func createRoute(groceryDic: [String: [String]], for store: Store, completion: @escaping () -> Void) {
        print("Creating a route...")
        guard let url = URL(string: "\(baseUrl)/create_route") else {
            print("Invalid URL for createRoute")
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")

        let body: [String: Any] = [
            "state": store.state.lowercased(),
            "address": store.address,
            "grocery_dic": groceryDic
        ]
        
        print("Create Route Request Body:", body)
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network Error in createRoute:", error)
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("createRoute Response Status Code:", httpResponse.statusCode)
            }
            
            if let data = data {
                print("createRoute Raw Response Data:", String(data: data, encoding: .utf8) ?? "Invalid data")
                
                if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let base64Image = jsonResponse["image"] as? String,
                   let imageData = Data(base64Encoded: base64Image) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData) ?? UIImage()
                        self.routeImages[store.id] = image
                        self.image = image
                        print("Successfully created and stored route image")
                        completion()
                    }
                } else {
                    print("Failed to parse createRoute JSON response or create image")
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } else {
                print("No data received from createRoute")
                DispatchQueue.main.async {
                    completion()
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
