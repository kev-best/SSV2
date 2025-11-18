//
//  DatabaseManager.swift
//  SoleSociety
//

import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let usersKey = "sole_society_users"
    private let currentUserKey = "sole_society_current_user"
    
    private init() {
        // Initialize with some mock users if none exist
        if getUsers().isEmpty {
            initializeMockData()
        }
    }
    
    // MARK: - User Management
    
    func getUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    func saveUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    func createUser(username: String, password: String) -> User? {
        var users = getUsers()
        
        // Check if username already exists
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            return nil
        }
        
        let newUser = User(username: username, password: password)
        users.append(newUser)
        saveUsers(users)
        return newUser
    }
    
    func authenticateUser(username: String, password: String) -> User? {
        let users = getUsers()
        return users.first { $0.username.lowercased() == username.lowercased() && $0.password == password }
    }
    
    func getCurrentUser() -> User? {
        guard let userId = UserDefaults.standard.string(forKey: currentUserKey) else {
            return nil
        }
        let users = getUsers()
        return users.first { $0.id == userId }
    }
    
    func setCurrentUser(_ user: User) {
        UserDefaults.standard.set(user.id, forKey: currentUserKey)
    }
    
    func clearCurrentUser() {
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    // MARK: - Liked Sneakers Management
    
    func toggleLike(styleID: String, userId: String) -> Bool {
        var users = getUsers()
        guard let index = users.firstIndex(where: { $0.id == userId }) else {
            return false
        }
        
        var user = users[index]
        if user.likedSneakerStyleIDs.contains(styleID) {
            user.likedSneakerStyleIDs.removeAll { $0 == styleID }
        } else {
            user.likedSneakerStyleIDs.append(styleID)
        }
        
        users[index] = user
        saveUsers(users)
        return user.likedSneakerStyleIDs.contains(styleID)
    }
    
    func isLiked(styleID: String, userId: String) -> Bool {
        let users = getUsers()
        guard let user = users.first(where: { $0.id == userId }) else {
            return false
        }
        return user.likedSneakerStyleIDs.contains(styleID)
    }
    
    func getLikedStyleIDs(userId: String) -> [String] {
        let users = getUsers()
        guard let user = users.first(where: { $0.id == userId }) else {
            return []
        }
        return user.likedSneakerStyleIDs
    }
    
    // MARK: - Mock Data
    
    private func initializeMockData() {
        var testUser = User(username: "demo", password: "password")
        testUser.likedSneakerStyleIDs = ["FY2903", "FY4176"]
        
        let users = [testUser]
        saveUsers(users)
    }
}

