//
//  User.swift
//  SoleSociety
//

import Foundation

struct User: Codable, Identifiable {
    let id: String // userId
    let username: String
    let password: String // In production, this should be hashed
    var likedSneakerStyleIDs: [String]
    
    init(username: String, password: String) {
        self.id = UUID().uuidString
        self.username = username
        self.password = password
        self.likedSneakerStyleIDs = []
    }
}

