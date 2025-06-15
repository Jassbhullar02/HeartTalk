//
//  OpenAIService.swift
//  HeartTalk
//
//  Created by Jaspreet Bhullar on 01/06/25.
//

import Foundation

class CohereAPIService {
    
    // MARK: - Properties
    private let endpoint = "https://api.cohere.ai/v1/chat"
    private let apiKey: String
    
    /// ⚠️ IMPORTANT SETUP REQUIRED ⚠️
    /// To use this app, create a file named `APIKeys.plist` in the main bundle.
    /// Then, add your Cohere API key to it with the following format:
    ///
    /// <dict>
    ///     <key>COHERE_API_KEY</key>
    ///     <string>your-api-key-here</string>
    /// </dict>
    ///
    /// ❗️Note: This file is intentionally excluded from version control (e.g., .gitignore)
    /// so everyone must create their own copy locally.
    /// You can get your API key from https://dashboard.cohere.com/
    
    init?() {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["COHERE_API_KEY"] as? String else {
            #if DEBUG
            fatalError("❌ API Key not found. Make sure APIKeys.plist is added.")
            #else
            print("❌ API Key missing.")
            #endif
            return nil
        }
        self.apiKey = key
    }
    
    // MARK: - Public Functions
    func sendMessage(_ message: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "message": message
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let text = json["text"] as? String else {
                completion(nil)
                return
            }
            completion(text)
        }.resume()
    }
}
