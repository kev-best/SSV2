//
//  PersistenceManager.swift
//  SSV3
//
//  Created by csuftitan on 12/6/25.
//


import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private init() {}
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private let usersKey = "saved_users"
    private let currentUserKey = "current_user_id"
    
    // MARK: - Users
    
    func saveUsers(_ users: [User]) {
        if let encoded = try? JSONEncoder().encode(users) {
            defaults.set(encoded, forKey: usersKey)
        }
    }
    
    func loadUsers() -> [User] {
        guard let data = defaults.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    // MARK: - Current User
    
    func saveCurrentUserID(_ id: String) {
        defaults.set(id, forKey: currentUserKey)
    }
    
    func loadCurrentUserID() -> String? {
        defaults.string(forKey: currentUserKey)
    }
    
    func clearCurrentUser() {
        defaults.removeObject(forKey: currentUserKey)
    }
}
