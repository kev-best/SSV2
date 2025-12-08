//
//  Sneaker.swift
//  SoleSociety
//

import Foundation

// API Source Enum
enum SneakerSource: String, Codable {
    case stockx = "stockx"
    case goat = "goat"
}

// Sneaker.swift
struct Sneaker: Identifiable {
    var id: String { styleID }
    let styleID: String // Maps to 'slug' for both APIs
    let sku: String? // Actual SKU field
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
    let source: SneakerSource // Which API this sneaker is from
    
    // StockX specific min/max/avg pricing
    let stockXMinPrice: Int?
    let stockXMaxPrice: Int?
    let stockXAvgPrice: Int?

    struct ResellLinks: Codable {
        let stockX: String?
        let goat: String?
    }
    
    struct LowestResellPrice: Codable {
        let stockX: Int?
        let goat: Int?
    }
}

// For API search results that don't have full details
struct SneakerSearchResult: Identifiable {
    var id: String { styleID }
    let styleID: String // Maps to slug
    let sku: String?
    let shoeName: String
    let colorway: String?
    let thumbnail: String?
    let displayPrice: String // Formatted price to display
    let source: SneakerSource // "stockx" or "goat"
}

