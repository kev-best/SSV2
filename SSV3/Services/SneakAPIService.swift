import Foundation

final class SneakAPIService {
    static let shared = SneakAPIService()
    private init() {}

    // Base points to your Node proxy
    private let baseURL = URL(string: "http://localhost:3000/api")!
    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - DTOs that mirror our proxy responses

    // Search list wrapper
    struct ListResponse<T: Decodable>: Decodable {
        let data: [T]
    }

    // Detail wrapper
    struct DetailResponse<T: Decodable>: Decodable {
        let data: T
    }

    struct SneakerDTO: Decodable {
        let styleID: String
        let shoeName: String
        let brand: String?
        let colorway: String?
        let retailPrice: Int?
        let releaseDate: String?
        let imageLinks: [String]
        let resellLinks: ResellLinksDTO?
        let lowestResellPrice: LowestDTO?
        let resellPrices: [String: [String: Int]]  // size -> { stockX/goat : price }
        let thumbnail: String?
        let description: String?
        let source: String?
    }

    struct ResellLinksDTO: Decodable {
        let stockX: String?
        let goat: String?
        let flightClub: String?
        let stadiumGoods: String?
    }

    struct LowestDTO: Decodable {
        let stockX: Int?
        let goat: Int?
        let flightClub: Int?
        let stadiumGoods: Int?
    }

    // MARK: - Public API used by the app

    /// Replace old "most popular" with curated lists: 5 Nike from StockX, 5 Nike from GOAT
    func getCuratedNike() async throws -> [SneakerSearchResult] {
        async let sx = fetchProducts(source: "stockx", brand: "Nike", limit: 5)
        async let goat = fetchProducts(source: "goat", brand: "Nike", limit: 5)
        let (a, b) = try await (sx, goat)
        // Interleave so UI looks balanced in the grid
        return interleave(a, b)
    }

    /// Search by keyword across StockX + GOAT (you can keep your current UX and call this)
    func search(keyword: String, limit: Int = 20) async throws -> [SneakerSearchResult] {
        async let sx = fetchProducts(source: "stockx", query: keyword, limit: limit)
        async let goat = fetchProducts(source: "goat", query: keyword, limit: limit)
        let (a, b) = try await (sx, goat)
        return (a + b)
    }

    /// Detail
    func getProductPrices(styleID: String, source: String) async throws -> Sneaker {
        let url = baseURL.appendingPathComponent("product").appendingPathComponent(styleID)
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "source", value: source)]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        let dto = try jsonDecoder.decode(DetailResponse<SneakerDTO>.self, from: data).data
        return dto.toDomain()
    }

    // MARK: - Private

    private func fetchProducts(source: String, query: String? = nil, brand: String? = nil, limit: Int = 20) async throws -> [SneakerSearchResult] {
        var comps = URLComponents(url: baseURL.appendingPathComponent("products"), resolvingAgainstBaseURL: false)!
        var items = [URLQueryItem(name: "source", value: source),
                     URLQueryItem(name: "limit", value: String(limit))]
        if let q = query, !q.isEmpty { items.append(.init(name: "query", value: q)) }
        if let b = brand, !b.isEmpty { items.append(.init(name: "brand", value: b)) }
        comps.queryItems = items

        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        let list = try jsonDecoder.decode(ListResponse<SneakerDTO>.self, from: data).data
        return list.map { $0.toSearchResult() }
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


extension SneakAPIService.SneakerDTO {
    func toSearchResult() -> SneakerSearchResult {
        // displayPrice preference: stockX first, then GOAT
        let price = lowestResellPrice?.stockX ?? lowestResellPrice?.goat
        let priceStr = price != nil ? "$\(price!)" : "—"
        return SneakerSearchResult(
            styleID: styleID,
            shoeName: shoeName,
            colorway: colorway,
            thumbnail: thumbnail ?? imageLinks.first,
            displayPrice: priceStr,
            source: source ?? "stockx" // default
        )
    }

    func toDomain() -> Sneaker {
        Sneaker(
            styleID: styleID,
            shoeName: shoeName,
            brand: brand,
            colorway: colorway,
            retailPrice: retailPrice,
            releaseDate: releaseDate,
            imageLinks: imageLinks,
            resellLinks: Sneaker.ResellLinks(
                stockX: resellLinks?.stockX,
                goat: resellLinks?.goat,
                flightClub: resellLinks?.flightClub,
                stadiumGoods: resellLinks?.stadiumGoods
            ),
            lowestResellPrice: Sneaker.LowestResellPrice(
                stockX: lowestResellPrice?.stockX,
                goat: lowestResellPrice?.goat,
                flightClub: lowestResellPrice?.flightClub,
                stadiumGoods: lowestResellPrice?.stadiumGoods
            ),
            resellPrices: resellPrices,
            description: description
        )
    }
}
