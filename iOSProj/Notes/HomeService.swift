//
//  HomeService.swift
//  Notes
//
//  Created by Surya on 31/03/24.
//

import Foundation

class HomeService {
    let url = URL(string: "http://localhost:3000/notes")!
    
    func fetchNotes() async throws -> [Note] {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let notes = try decoder.decode([Note].self, from: data)
            return notes
        } catch {
            print("Error fetching notes: \(error)")
            throw error
        }
    }
    
    func create(text: String) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let dict = [
            "note": text
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

        request.httpBody = jsonData
        
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
            throw NSError(domain: "com.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create note"])
        }
    }
    
    func update(id: String, text: String) async throws {
           var request = URLRequest(url: url.appendingPathComponent(id))
           request.httpMethod = "PATCH"
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           let dict = [
               "note": text
           ]
           let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

           request.httpBody = jsonData
           
           let (_, response) = try await URLSession.shared.data(for: request)
           guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
               throw NSError(domain: "com.yourapp", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to update note"])
           }
       }
       
       func delete(id: String) async throws {
           var request = URLRequest(url: url.appendingPathComponent(id))
           request.httpMethod = "DELETE"
           
           let (_, response) = try await URLSession.shared.data(for: request)
           guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 204 else {
               throw NSError(domain: "com.yourapp", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to delete note"])
           }
       }
}
