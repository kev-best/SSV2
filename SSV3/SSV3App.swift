//
//  SSV3App.swift
//  SSV3
//
//
//  SoleSocietyApp.swift
//  SoleSociety
//

import SwiftUI

@main
struct SSV3App: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

