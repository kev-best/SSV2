//
//  Sneaker.swift
//  SoleSociety
//

import Foundation

// Sneaker.swift
struct Sneaker: Identifiable {
    var id: String { styleID }
    let styleID: String
    let shoeName: String
    let brand: String?
    let colorway: String?
    let retailPrice: Int?
    let releaseDate: String?
    let imageLinks: [String]
    let resellLinks: ResellLinks?
    let lowestResellPrice: LowestResellPrice?
    let resellPrices: [String: [String: Int]]
    let description: String?

    struct ResellLinks: Codable {
        let stockX: String?
        let goat: String?
        let flightClub: String?
        let stadiumGoods: String?
    }
    struct LowestResellPrice: Codable {
        let stockX: Int?
        let goat: Int?
        let flightClub: Int?
        let stadiumGoods: Int?
    }
}


// For API search results that don't have full details
// SneakerSearchResult.swift (or wherever you defined it)
struct SneakerSearchResult: Identifiable {
    var id: String { styleID }
    let styleID: String
    let shoeName: String
    let colorway: String?
    let thumbnail: String?
    let displayPrice: String
    let source: String // "stockx" or "goat"
    
}


