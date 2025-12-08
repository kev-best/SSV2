import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let currentUserKey = "current_user_id"
    private var users: [User] = []
    
    private init() {
        // Load saved users on init
        users = PersistenceManager.shared.loadUsers()
        
        // Initialize with mock data if no users exist
        if users.isEmpty {
            initializeMockData()
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Whenever users change, save them
    private func saveChanges() {
        PersistenceManager.shared.saveUsers(users)
    }
    
    /// Get all users (helper method for compatibility)
    private func getUsers() -> [User] {
        return users
    }
    
    /// Save users (helper method for compatibility)
    private func saveUsers(_ users: [User]) {
        self.users = users
        saveChanges()
    }
    
    // MARK: - User Management
    
    func createUser(_ user: User) -> Bool {
        guard !users.contains(where: { $0.username == user.username }) else {
            return false
        }
        users.append(user)
        saveChanges()
        return true
    }
    
    func getUser(username: String, password: String) -> User? {
        return users.first { $0.username.lowercased() == username.lowercased() && $0.password == password }
    }
    
    func getUserById(_ id: String) -> User? {
        return users.first { $0.id == id }
    }
    
    func authenticateUser(username: String, password: String) -> User? {
        return users.first { $0.username.lowercased() == username.lowercased() && $0.password == password }
    }
    
    // MARK: - Current User Session Management
    
    func getCurrentUser() -> User? {
        guard let userId = UserDefaults.standard.string(forKey: currentUserKey) else {
            return nil
        }
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
        guard let index = users.firstIndex(where: { $0.id == userId }) else {
            return false
        }
        
        if users[index].likedSneakerStyleIDs.contains(styleID) {
            users[index].likedSneakerStyleIDs.removeAll { $0 == styleID }
        } else {
            users[index].likedSneakerStyleIDs.append(styleID)
        }
        
        saveChanges()
        return users[index].likedSneakerStyleIDs.contains(styleID)
    }
    
    func isLiked(styleID: String, userId: String) -> Bool {
        guard let user = users.first(where: { $0.id == userId }) else {
            return false
        }
        return user.likedSneakerStyleIDs.contains(styleID)
    }
    
    func getLikedStyleIDs(userId: String) -> [String] {
        guard let user = users.first(where: { $0.id == userId }) else {
            return []
        }
        return user.likedSneakerStyleIDs
    }
    
    // MARK: - User Preferences
    
    func updateShoeSize(userId: String, size: String) {
        guard let index = users.firstIndex(where: { $0.id == userId }) else {
            return
        }
        users[index].shoeSize = size
        saveChanges()
    }
    
    func getShoeSize(userId: String) -> String? {
        return users.first(where: { $0.id == userId })?.shoeSize
    }
    
    // MARK: - Mock Data
    
    private func initializeMockData() {
        var testUser = User(username: "demo", password: "password", shoeSize: "10")
        testUser.likedSneakerStyleIDs = ["FY2903", "FY4176"]
        
        users = [testUser]
        saveChanges()
    }
}
