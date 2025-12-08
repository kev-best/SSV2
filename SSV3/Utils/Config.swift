//
//  Config.swift
//  SSV3
//
//  Created by csuftitan on 12/6/25.
//


//
//  Config.swift
//  SoleSociety
//
//  Configuration file for API keys and app settings
//

import Foundation

enum Config {
    // MARK: - API Configuration
    
    /// Kicks.dev API Key
    /// Get your key from: https://kicks.dev/dashboard
    static var kicksAPIKey: String {
        // Option 1: Load from Info.plist (Recommended for production)
        if let key = Bundle.main.infoDictionary?["KICKS_API_KEY"] as? String, !key.isEmpty {
            return key
        }
        
        // Option 2: Load from xcconfig file
        #if DEBUG
        // Development key - replace with your test key
        let devKey = "ENTER_YOUR_DEV_API_KEY_HERE"
        return devKey
        #else
        // Production key - should come from Info.plist
        fatalError("Production API key not configured in Info.plist")
        #endif
    }
    
    // MARK: - API Endpoints
    
    static let kicksAPIBaseURL = "https://api.kicks.dev"
    static let apiTimeout: TimeInterval = 15.0
    
    // MARK: - App Settings
    
    static let defaultSearchLimit = 20
    static let defaultBrandLimit = 10
    static let maxRetries = 3
}

// MARK: - Usage Example
/*
 In SneakAPIService.swift:
 
 private let apiKey = Config.kicksAPIKey
 private let baseURL = URL(string: Config.kicksAPIBaseURL)!
 */
