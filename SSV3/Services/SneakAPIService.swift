import Foundation

final class SneakAPIService {
    static let shared = SneakAPIService()
    private init() {}

    // API Configuration - uses Config.swift for secure key management
    private let apiKey = Config.kicksAPIKey
    private let baseURL = URL(string: Config.kicksAPIBaseURL)!
    private let timeout = Config.apiTimeout
    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - DTOs that match Kicks.dev API responses

    // List wrapper
    struct ListResponse<T: Decodable>: Decodable {
        let data: [T]
    }

    // Detail wrapper
    struct DetailResponse<T: Decodable>: Decodable {
        let data: T
    }

    struct KicksProductDTO: Decodable {
        // StockX fields
        let slug: String?
        let id: String?
        let title: String?
        let model: String?
        let brand: String?
        let category: String?
        let gallery: [String]?
        let image: String?
        let link: String?
        let minPrice: Int?
        let maxPrice: Int?
        let avgPrice: Int?
        let description: String?
        let productType: String?
        let gender: String?
        
        // GOAT fields (when applicable)
        let name: String?
        let colorway: String?
        let images: [String]?
        let imageUrl: String?
        let variants: [VariantDTO]?
        let retailPrices: RetailPricesDTO?
        let releaseDate: String?
        
        enum CodingKeys: String, CodingKey {
            case slug, id, title, model, brand, category, gallery, image, link, description
            case minPrice  // decoder's convertFromSnakeCase handles min_price -> minPrice
            case maxPrice  // decoder's convertFromSnakeCase handles max_price -> maxPrice
            case avgPrice  // decoder's convertFromSnakeCase handles avg_price -> avgPrice
            case productType  // decoder's convertFromSnakeCase handles product_type -> productType
            case gender
            case name, colorway, images
            case imageUrl  // decoder's convertFromSnakeCase handles image_url -> imageUrl
            case variants
            case retailPrices  // decoder's convertFromSnakeCase handles retail_prices -> retailPrices
            case releaseDate  // decoder's convertFromSnakeCase handles release_date -> releaseDate
        }
        
        // Custom decoding to handle both String and Int IDs from different APIs
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // Decode ID field - can be String or Int
            if let idString = try? container.decode(String.self, forKey: .id) {
                self.id = idString
            } else if let idInt = try? container.decode(Int.self, forKey: .id) {
                self.id = String(idInt)
            } else {
                self.id = nil
            }
            
            // Decode all other fields normally
            self.slug = try? container.decode(String.self, forKey: .slug)
            self.title = try? container.decode(String.self, forKey: .title)
            self.model = try? container.decode(String.self, forKey: .model)
            self.brand = try? container.decode(String.self, forKey: .brand)
            self.category = try? container.decode(String.self, forKey: .category)
            self.gallery = try? container.decode([String].self, forKey: .gallery)
            self.image = try? container.decode(String.self, forKey: .image)
            self.link = try? container.decode(String.self, forKey: .link)
            
            // Decode pricing - API returns Double values, convert to Int
            if let minInt = try? container.decode(Int.self, forKey: .minPrice) {
                self.minPrice = minInt
            } else if let minDouble = try? container.decode(Double.self, forKey: .minPrice) {
                self.minPrice = Int(minDouble)
            } else {
                self.minPrice = nil
            }
            
            if let maxInt = try? container.decode(Int.self, forKey: .maxPrice) {
                self.maxPrice = maxInt
            } else if let maxDouble = try? container.decode(Double.self, forKey: .maxPrice) {
                self.maxPrice = Int(maxDouble)
            } else {
                self.maxPrice = nil
            }
            
            if let avgInt = try? container.decode(Int.self, forKey: .avgPrice) {
                self.avgPrice = avgInt
            } else if let avgDouble = try? container.decode(Double.self, forKey: .avgPrice) {
                self.avgPrice = Int(avgDouble)
            } else {
                self.avgPrice = nil
            }
            
            self.description = try? container.decode(String.self, forKey: .description)
            self.productType = try? container.decode(String.self, forKey: .productType)
            self.gender = try? container.decode(String.self, forKey: .gender)
            self.name = try? container.decode(String.self, forKey: .name)
            self.colorway = try? container.decode(String.self, forKey: .colorway)
            self.images = try? container.decode([String].self, forKey: .images)
            self.imageUrl = try? container.decode(String.self, forKey: .imageUrl)
            self.variants = try? container.decode([VariantDTO].self, forKey: .variants)
            self.retailPrices = try? container.decode(RetailPricesDTO.self, forKey: .retailPrices)
            self.releaseDate = try? container.decode(String.self, forKey: .releaseDate)
        }
        
        // Helper to determine if this is a sneaker/shoe product
        func isSneaker() -> Bool {
            let productTypeLower = (productType ?? "").lowercased()
            let nameLower = (name ?? title ?? "").lowercased()
            let categoryLower = (category ?? "").lowercased()
            
            // Exclude non-sneaker items
            let excludedTypes = ["apparel", "clothing", "hoodie", "jacket", "shirt", "pants",
                               "shorts", "accessories", "bag", "hat", "cap"]
            let excludedKeywords = ["hoodie", "jacket", "fleece", "windrunner", "crewneck",
                                   "sweatshirt", "tee", "t-shirt", "pants", "shorts"]
            
            // Check if it's explicitly marked as sneakers
            if productTypeLower == "sneakers" || productTypeLower == "shoes" {
                return true
            }
            
            // Exclude if product type matches excluded categories
            for excluded in excludedTypes {
                if productTypeLower.contains(excluded) {
                    return false
                }
            }
            
            // Exclude if name contains non-shoe keywords
            for keyword in excludedKeywords {
                if nameLower.contains(keyword) {
                    return false
                }
            }
            
            // Include common shoe categories
            let shoeKeywords = ["air", "jordan", "dunk", "force", "yeezy", "boost",
                              "slide", "sandal", "trainer", "runner", "sneaker",
                              "shoe", "foamposite", "react", "zoom"]
            
            for keyword in shoeKeywords {
                if nameLower.contains(keyword) || categoryLower.contains(keyword) {
                    return true
                }
            }
            
            // Default: assume it's a sneaker if we can't determine otherwise
            // (API is primarily for sneakers)
            return !nameLower.isEmpty
        }
        
        // Helper to check if product has pricing data
        func hasPrice() -> Bool {
            // Check for StockX prices
            if let minPrice = minPrice, minPrice > 0 {
                return true
            }
            
            if let avgPrice = avgPrice, avgPrice > 0 {
                return true
            }
            
            // Check for GOAT variant prices (less strict - just need variants to exist)
            if let variants = variants, !variants.isEmpty {
                // Check if ANY variant has a price > 0
                let hasPrices = variants.contains { variant in
                    if let ask = variant.lowestAsk, ask > 0 {
                        return true
                    }
                    return false
                }
                if hasPrices {
                    return true
                }
                
                // Even if no prices yet, return true if variants exist
                // (they might get populated later)
                return true
            }
            
            return false
        }
    }
    
    struct VariantDTO: Decodable {
        let size: String?
        let lowestAsk: Int?
        let available: Bool?
        
        // Custom decoder to handle lowestAsk as either Int or Double from API
        enum CodingKeys: String, CodingKey {
            case size
            case lowestAsk
            case available
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            size = try container.decodeIfPresent(String.self, forKey: .size)
            available = try container.decodeIfPresent(Bool.self, forKey: .available)
            
            // Handle lowestAsk as Double (per API schema) and convert to Int
            if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: .lowestAsk) {
                lowestAsk = Int(doubleValue)
            } else if let intValue = try? container.decodeIfPresent(Int.self, forKey: .lowestAsk) {
                lowestAsk = intValue
            } else {
                lowestAsk = nil
            }
        }
    }
    
    struct RetailPricesDTO: Decodable {
        let usd: String?
        
        enum CodingKeys: String, CodingKey {
            case usd = "USD"
        }
    }

    // MARK: - Public API

    /// Search StockX only
    func searchStockX(keyword: String, limit: Int = 20) async throws -> [SneakerSearchResult] {
        return try await fetchProducts(source: "stockx", query: keyword, limit: limit, userShoeSize: nil)
    }
    
    /// Search GOAT only
    func searchGoat(keyword: String, limit: Int = 20, userShoeSize: String? = nil) async throws -> [SneakerSearchResult] {
        return try await fetchProducts(source: "goat", query: keyword, limit: limit, userShoeSize: userShoeSize)
    }
    
    /// Search both StockX and GOAT
    func searchBoth(keyword: String, limit: Int = 20, userShoeSize: String? = nil) async throws -> (stockx: [SneakerSearchResult], goat: [SneakerSearchResult]) {
        async let sx = fetchProducts(source: "stockx", query: keyword, limit: limit, userShoeSize: nil)
        async let goat = fetchProducts(source: "goat", query: keyword, limit: limit, userShoeSize: userShoeSize)
        let (stockxResults, goatResults) = try await (sx, goat)
        return (stockxResults, goatResults)
    }

    /// Get curated Nike sneakers from StockX
    func getCuratedStockX(limit: Int = 10) async throws -> [SneakerSearchResult] {
        return try await fetchProducts(source: "stockx", brand: "Nike", limit: limit, userShoeSize: nil)
    }
    
    /// Get curated Nike sneakers from GOAT
    func getCuratedGoat(limit: Int = 10, userShoeSize: String? = nil) async throws -> [SneakerSearchResult] {
        return try await fetchProducts(source: "goat", brand: "Nike", limit: limit, userShoeSize: userShoeSize)
    }
    
    /// Get curated Nike sneakers from both sources
    func getCuratedBoth(limit: Int = 10, userShoeSize: String? = nil) async throws -> (stockx: [SneakerSearchResult], goat: [SneakerSearchResult]) {
        async let sx = fetchProducts(source: "stockx", brand: "Nike", limit: limit, userShoeSize: nil)
        async let goat = fetchProducts(source: "goat", brand: "Nike", limit: limit, userShoeSize: userShoeSize)
        let (stockxResults, goatResults) = try await (sx, goat)
        return (stockxResults, goatResults)
    }

    /// Fetch products by specific brand from StockX
    func fetchStockXByBrand(brand: String, limit: Int = 20) async throws -> [SneakerSearchResult] {
        return try await fetchProducts(source: "stockx", brand: brand, limit: limit, userShoeSize: nil)
    }
    
    /// Fetch products by specific brand from GOAT
    func fetchGoatByBrand(brand: String, limit: Int = 20, userShoeSize: String? = nil) async throws -> [SneakerSearchResult] {
        return try await fetchProducts(source: "goat", brand: brand, limit: limit, userShoeSize: userShoeSize)
    }
    
    /// Fetch products by specific brand from both sources
    func fetchBothByBrand(brand: String, limit: Int = 20, userShoeSize: String? = nil) async throws -> (stockx: [SneakerSearchResult], goat: [SneakerSearchResult]) {
        async let sx = fetchProducts(source: "stockx", brand: brand, limit: limit, userShoeSize: nil)
        async let goat = fetchProducts(source: "goat", brand: brand, limit: limit, userShoeSize: userShoeSize)
        let (stockxResults, goatResults) = try await (sx, goat)
        return (stockxResults, goatResults)
    }

    /// Get detailed product information from StockX by slug
    func getStockXProduct(slug: String) async throws -> Sneaker {
        guard let dto = await fetchStockXDetail(slug: slug) else {
            throw APIError.invalidResponse
        }
        return convertStockXToSneaker(dto: dto)
    }
    
    /// Get detailed product information from GOAT by slug
    func getGoatProduct(slug: String) async throws -> Sneaker {
        guard let dto = await fetchGoatDetail(slug: slug) else {
            throw APIError.invalidResponse
        }
        return convertGoatToSneaker(dto: dto)
    }
    /// Fetch detail from StockX API
    private func fetchStockXDetail(slug: String) async -> KicksProductDTO? {
        do {
            // StockX detail uses slug in path
            let endpoint = "v3/stockx/products/\(slug)"
            
            // Build URL manually to match API docs exactly
            let urlString = "\(Config.kicksAPIBaseURL)/\(endpoint)?display[traits]&display[variants]&display[hidden_variants]&display[identifiers]&display[prices]&display[statistics]&market&currency"
            
            guard let url = URL(string: urlString) else {
                print("⚠️ StockX: Failed to create URL")
                return nil
            }
            
            var request = URLRequest(url: url)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            request.timeoutInterval = timeout
            
            print("📡 StockX Detail: \(slug)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("⚠️ StockX detail failed: HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil
            }
            
            // StockX detail endpoint returns single object wrapped in DetailResponse
            let detailResponse = try jsonDecoder.decode(DetailResponse<KicksProductDTO>.self, from: data)
            let product = detailResponse.data
            
            print("✅ StockX: \(product.title ?? slug) - $\(product.minPrice ?? 0)-$\(product.maxPrice ?? 0) (avg: $\(product.avgPrice ?? 0))")
            
            return product
        } catch {
            print("⚠️ StockX detail error: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Fetch detail from GOAT API
    private func fetchGoatDetail(slug: String) async -> KicksProductDTO? {
        do {
            let endpoint = "v3/goat/products"
            var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
            
            // Use slugs parameter for exact match
            components.queryItems = [
                URLQueryItem(name: "slugs", value: slug),
                URLQueryItem(name: "currency", value: "USD"),
                URLQueryItem(name: "display[variants]", value: "true"),
                URLQueryItem(name: "limit", value: "1")
            ]
            
            var request = URLRequest(url: components.url!)
            request.setValue(apiKey, forHTTPHeaderField: "Authorization")
            request.timeoutInterval = timeout
            
            print("📡 GOAT Detail: \(slug)")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("⚠️ GOAT detail failed: HTTP \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return nil
            }
            
            // GOAT API can return either a single object or an array depending on parameters
            // Try to decode as DetailResponse first, then fall back to ListResponse
            var product: KicksProductDTO?
            
            if let detailResponse = try? jsonDecoder.decode(DetailResponse<KicksProductDTO>.self, from: data) {
                product = detailResponse.data
            } else if let listResponse = try? jsonDecoder.decode(ListResponse<KicksProductDTO>.self, from: data) {
                product = listResponse.data.first
            } else {
                print("⚠️ Failed to decode GOAT response")
                return nil
            }
            
            guard let product = product else {
                print("⚠️ No product data in GOAT response")
                return nil
            }
            
            let variantCount = product.variants?.count ?? 0
            print("✅ GOAT: \(product.title ?? product.name ?? slug) - \(variantCount) sizes")
            
            return product
        } catch {
            print("⚠️ GOAT detail fetch error: \(error)")
            return nil
        }
    }
    
    /// Convert StockX DTO to Sneaker model
    private func convertStockXToSneaker(dto: KicksProductDTO) -> Sneaker {
        let styleID = dto.slug ?? dto.id ?? ""
        let sku = dto.id // StockX uses ID as SKU
        let shoeName = dto.title ?? dto.model ?? ""
        let brand = dto.brand
        let colorway = dto.category
        
        // Retail price - StockX doesn't typically have this
        let retailPrice: Int? = nil
        
        // Release date
        let releaseDate = dto.releaseDate
        
        // Images
        var imageLinks = dto.gallery ?? []
        if imageLinks.isEmpty, let image = dto.image {
            imageLinks = [image]
        }
        
        // Resell links
        let resellLinks = Sneaker.ResellLinks(
            stockX: dto.link,
            goat: nil
        )
        
        // Lowest resell price
        let lowestResellPrice = Sneaker.LowestResellPrice(
            stockX: dto.minPrice,
            goat: nil
        )
        
        // No size-specific pricing from StockX
        let resellPrices: [String: [String: Int]] = [:]
        
        // Description
        let description = dto.description
        
        return Sneaker(
            styleID: styleID,
            sku: sku,
            shoeName: shoeName,
            brand: brand,
            colorway: colorway,
            retailPrice: retailPrice,
            releaseDate: releaseDate,
            imageLinks: imageLinks,
            resellLinks: resellLinks,
            lowestResellPrice: lowestResellPrice,
            resellPrices: resellPrices,
            description: description,
            source: .stockx,
            stockXMinPrice: dto.minPrice,
            stockXMaxPrice: dto.maxPrice,
            stockXAvgPrice: dto.avgPrice
        )
    }
    
    /// Convert GOAT DTO to Sneaker model
    private func convertGoatToSneaker(dto: KicksProductDTO) -> Sneaker {
        let styleID = dto.slug ?? dto.id ?? ""
        let sku = dto.id // GOAT uses ID as SKU
        let shoeName = dto.name ?? dto.title ?? dto.model ?? ""
        let brand = dto.brand
        let colorway = dto.colorway
        
        // Retail price
        var retailPrice: Int?
        if let retailPrices = dto.retailPrices, let usdString = retailPrices.usd {
            retailPrice = Int(usdString)
        }
        
        // Release date
        let releaseDate = dto.releaseDate
        
        // Images
        var imageLinks = dto.images ?? []
        if imageLinks.isEmpty, let imageUrl = dto.imageUrl {
            imageLinks = [imageUrl]
        }
        if imageLinks.isEmpty, let image = dto.image {
            imageLinks = [image]
        }
        
        // Resell links
        let resellLinks = Sneaker.ResellLinks(
            stockX: nil,
            goat: dto.link
        )
        
        // Lowest resell price from variants
        var goatLowest: Int?
        if let variants = dto.variants, !variants.isEmpty {
            let prices = variants.compactMap { $0.lowestAsk }
            goatLowest = prices.min()
        }
        
        let lowestResellPrice = Sneaker.LowestResellPrice(
            stockX: nil,
            goat: goatLowest
        )
        
        // Size-specific pricing from GOAT variants
        var resellPrices: [String: [String: Int]] = [:]
        if let variants = dto.variants {
            for variant in variants {
                guard let size = variant.size, let price = variant.lowestAsk else {
                    continue
                }
                resellPrices[size] = ["goat": price]
            }
        }
        
        // Description
        let description = dto.description
        
        return Sneaker(
            styleID: styleID,
            sku: sku,
            shoeName: shoeName,
            brand: brand,
            colorway: colorway,
            retailPrice: retailPrice,
            releaseDate: releaseDate,
            imageLinks: imageLinks,
            resellLinks: resellLinks,
            lowestResellPrice: lowestResellPrice,
            resellPrices: resellPrices,
            description: description,
            source: .goat,
            stockXMinPrice: nil,
            stockXMaxPrice: nil,
            stockXAvgPrice: nil
        )
    }

    // MARK: - Private Methods

    private func fetchProducts(
        source: String,
        query: String? = nil,
        brand: String? = nil,
        limit: Int = 20,
        userShoeSize: String? = nil
    ) async throws -> [SneakerSearchResult] {
        
        let endpoint = source == "stockx" ? "v3/stockx/products" : "v3/goat/products"
        let url = baseURL.appendingPathComponent(endpoint)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "page", value: "1")
        ]
        
        // Add currency parameter
        queryItems.append(URLQueryItem(name: "currency", value: "USD"))
        
        // Add StockX-specific parameters
        if source == "stockx" {
            queryItems.append(URLQueryItem(name: "market", value: "US"))
            queryItems.append(URLQueryItem(name: "display[prices]", value: "true"))
        }
        // GOAT uses display[variants] parameter (bracket notation per API docs)
        else {
            queryItems.append(URLQueryItem(name: "display[variants]", value: "true"))
        }
        
        if let q = query, !q.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: q))
        }
        
        if let b = brand, !b.isEmpty {
            queryItems.append(URLQueryItem(name: "filters", value: "brand = '\(b)'"))
        }
        
        components.queryItems = queryItems
        
        var request = URLRequest(url: components.url!)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        let list = try jsonDecoder.decode(ListResponse<KicksProductDTO>.self, from: data).data
        
        // Filter to only include sneakers/shoes
        let sneakers = list.filter { $0.isSneaker() }
        
        print("🔍 Search results: \(sneakers.count) sneakers found")
        if source == "goat" {
            print("   User shoe size: \(userShoeSize ?? "not set")")
        }
        
        // Sort: prioritize sneakers with prices
        let sortedSneakers = sneakers.sorted { sneaker1, sneaker2 in
            let hasPrice1 = sneaker1.hasPrice()
            let hasPrice2 = sneaker2.hasPrice()
            
            // If one has price and other doesn't, prioritize the one with price
            if hasPrice1 != hasPrice2 {
                return hasPrice1
            }
            
            // If both have prices or both don't, maintain original order
            return false
        }
        
        let withPrices = sortedSneakers.filter { $0.hasPrice() }.count
        let withoutPrices = sortedSneakers.count - withPrices
        print("💰 Pricing: \(withPrices) with prices, \(withoutPrices) without prices")
        
        return sortedSneakers.map { $0.toSearchResult(source: source, userShoeSize: userShoeSize) }
    }

    private func interleave<T>(_ a: [T], _ b: [T]) -> [T] {
        var out: [T] = []
        let n = max(a.count, b.count)
        for i in 0..<n {
            if i < a.count { out.append(a[i]) }
            if i < b.count { out.append(b[i]) }
        }
        return out
    }
}

// MARK: - Extensions

extension SneakAPIService.KicksProductDTO {
    func toSearchResult(source: String, userShoeSize: String? = nil) -> SneakerSearchResult {
        // Determine the style ID (slug) and SKU (id)
        let styleID = slug ?? id ?? ""
        let sku = id
        
        // Get the shoe name (StockX vs GOAT fields)
        let shoeName = title ?? name ?? model ?? ""
        
        // Get colorway
        let colorway = self.colorway ?? category
        
        // Get images
        let imageArray = gallery ?? images ?? []
        let singleImage = image ?? imageUrl
        let thumbnail = imageArray.first ?? singleImage
        
        // PRICING LOGIC:
        // - StockX: use avg_price
        // - GOAT: use user's shoe size if available, otherwise smallest size
        var displayPrice: String = "—"
        
        if source == "stockx" {
            // For StockX: use avg_price
            if let avgPrice = avgPrice, avgPrice > 0 {
                displayPrice = "$\(avgPrice)"
            } else if let minPrice = minPrice, minPrice > 0 {
                // Fallback to min price if avg not available
                displayPrice = "$\(minPrice)"
            }
        } else {
            // For GOAT: use user's shoe size if available
            if let userSize = userShoeSize,
               let variants = variants,
               let userVariant = variants.first(where: { $0.size == userSize }),
               let price = userVariant.lowestAsk,
               price > 0 {
                // User's size price found
                displayPrice = "$\(price)"
                print("   ✅ \(shoeName) - User size \(userSize): $\(price)")
            } else {
                // Debug why price not found
                if userShoeSize == nil {
                    print("   ⚠️ \(shoeName) - No user shoe size set")
                } else if variants == nil || variants?.isEmpty == true {
                    print("   ⚠️ \(shoeName) - No variants available (variants: \(variants?.count ?? 0))")
                } else if let userSize = userShoeSize, let variants = variants {
                    let availableSizes = variants.compactMap { $0.size }.joined(separator: ", ")
                    print("   ⚠️ \(shoeName) - User size \(userSize) not found. Available: [\(availableSizes)]")
                }
                
                // Fallback: use smallest size price
                if let variants = variants, !variants.isEmpty {
                    let sortedVariants = variants
                        .filter { $0.lowestAsk != nil && $0.lowestAsk! > 0 }
                        .sorted { first, second in
                            guard let size1 = first.size, let size2 = second.size else { return false }
                            return (Double(size1) ?? 0) < (Double(size2) ?? 0)
                        }
                    
                    if let firstVariant = sortedVariants.first, let price = firstVariant.lowestAsk {
                        displayPrice = "$\(price)"
                        print("   → Using smallest size \(firstVariant.size ?? "?"): $\(price)")
                    }
                }
            }
        }
        
        // Determine source enum
        let sneakerSource: SneakerSource = source == "stockx" ? .stockx : .goat
        
        return SneakerSearchResult(
            styleID: styleID,
            sku: sku,
            shoeName: shoeName,
            colorway: colorway,
            thumbnail: thumbnail,
            displayPrice: displayPrice,
            source: sneakerSource
        )
    }
}

// MARK: - Error Types

enum APIError: Error, LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Dynamic Coding Key

struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }
}
