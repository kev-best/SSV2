import Foundation
import Combine

class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let db = DatabaseManager.shared
    private let persistence = PersistenceManager.shared
    
    init() {
        // Load saved state on app launch
        restoreSession()
    }
    
    func login(username: String, password: String) -> Bool {
        guard let user = db.getUser(username: username, password: password) else {
            return false
        }
        
        currentUser = user
        isAuthenticated = true
        
        // Save login state
        persistence.saveCurrentUserID(user.id)
        
        return true
    }
    
    func register(username: String, password: String) -> Bool {
        let user = User(username: username, password: password)
        let success = db.createUser(user)
        
        if success {
            currentUser = user
            isAuthenticated = true
            persistence.saveCurrentUserID(user.id)
        }
        
        return success
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        persistence.clearCurrentUser()
    }
    
    func refreshCurrentUser() {
        guard let userId = currentUser?.id else { return }
        currentUser = db.getUserById(userId)
    }
    
    // Restore session on app launch
    private func restoreSession() {
        guard let userId = persistence.loadCurrentUserID(),
              let user = db.getUserById(userId) else {
            return
        }
        
        currentUser = user
        isAuthenticated = true
    }
}
