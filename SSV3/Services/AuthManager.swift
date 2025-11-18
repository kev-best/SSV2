//
//  AuthManager.swift
//  SoleSociety
//

import Foundation
import SwiftUI

class AuthManager: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUser: User?
    
    private let db = DatabaseManager.shared
    
    init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        if let user = db.getCurrentUser() {
            currentUser = user
            isLoggedIn = true
        }
    }
    
    func login(username: String, password: String) -> Bool {
        if let user = db.authenticateUser(username: username, password: password) {
            db.setCurrentUser(user)
            currentUser = user
            isLoggedIn = true
            return true
        }
        return false
    }
    
    func register(username: String, password: String) -> Bool {
        if let user = db.createUser(username: username, password: password) {
            db.setCurrentUser(user)
            currentUser = user
            isLoggedIn = true
            return true
        }
        return false
    }
    
    func logout() {
        db.clearCurrentUser()
        currentUser = nil
        isLoggedIn = false
    }
    
    func refreshCurrentUser() {
        if let userId = currentUser?.id {
            let users = db.getUsers()
            currentUser = users.first { $0.id == userId }
        }
    }
}

