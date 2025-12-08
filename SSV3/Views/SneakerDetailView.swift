//
//  SneakerDetailView.swift
//  SoleSociety
//

import SwiftUI

struct SneakerDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: SneakerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(styleID: String, source: String = "stockx") {
        _viewModel = StateObject(wrappedValue: SneakerDetailViewModel(styleID: styleID, source: source))
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                    Text("Loading sneaker details...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(.orange.opacity(0.8))
                    
                    VStack(spacing: 8) {
                        Text("Oops!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(errorMessage)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button("Try Again") {
                        if let userId = authManager.currentUser?.id {
                            viewModel.loadSneaker(userId: userId)
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 40)
            } else if let sneaker = viewModel.sneaker {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Image Gallery
                        ZStack {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.gray.opacity(0.08),
                                            Color.gray.opacity(0.02)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            
                            TabView {
                                ForEach(sneaker.imageLinks, id: \.self) { imageUrl in
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .padding(20)
                                        case .failure:
                                            VStack(spacing: 12) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 50))
                                                    .foregroundColor(.gray.opacity(0.4))
                                                Text("Image unavailable")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                            .frame(height: 320)
                            .tabViewStyle(PageTabViewStyle())
                        }
                        .frame(height: 320)
                        
                        // Content Container
                        VStack(alignment: .leading, spacing: 20) {
                            // Sneaker Name and Brand
                            VStack(alignment: .leading, spacing: 8) {
                                Text(sneaker.shoeName)
                                    .font(.system(size: 28, weight: .bold))
                                    .lineSpacing(2)
                                
                                HStack(spacing: 6) {
                                    if let brand = sneaker.brand {
                                        Text(brand.uppercased())
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.black)
                                            .cornerRadius(6)
                                    }
                                    
                                    if let colorway = sneaker.colorway {
                                        Text(colorway)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Pricing Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Pricing")
                                    .font(.system(size: 18, weight: .bold))
                                
                                // Retail Price
                                if let retailPrice = sneaker.retailPrice {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Retail Price")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                            Text("$\(retailPrice)")
                                                .font(.system(size: 22, weight: .bold))
                                        }
                                        Spacer()
                                        Image(systemName: "tag.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.black.opacity(0.2))
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                                
                                // StockX Min/Max Pricing
                                if sneaker.stockXMinPrice != nil || sneaker.stockXMaxPrice != nil {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("StockX")
                                                .font(.system(size: 15, weight: .semibold))
                                            Spacer()
                                            if let link = sneaker.resellLinks?.stockX {
                                                Link(destination: URL(string: link)!) {
                                                    Image(systemName: "arrow.up.right.square.fill")
                                                        .foregroundColor(.black.opacity(0.5))
                                                        .font(.system(size: 18))
                                                }
                                            }
                                        }
                                        
                                        HStack(spacing: 16) {
                                            // Min Price
                                            if let minPrice = sneaker.stockXMinPrice {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Lowest Ask")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                    Text("$\(minPrice)")
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundColor(.green)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            
                                            // Max Price
                                            if let maxPrice = sneaker.stockXMaxPrice {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Highest Ask")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                    Text("$\(maxPrice)")
                                                        .font(.system(size: 20, weight: .bold))
                                                        .foregroundColor(.red.opacity(0.8))
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                                
                                // GOAT Size-Specific Pricing
                                if !sneaker.resellPrices.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Text("GOAT")
                                                .font(.system(size: 15, weight: .semibold))
                                            Spacer()
                                            if let link = sneaker.resellLinks?.goat {
                                                Link(destination: URL(string: link)!) {
                                                    Image(systemName: "arrow.up.right.square.fill")
                                                        .foregroundColor(.black.opacity(0.5))
                                                        .font(.system(size: 18))
                                                }
                                            }
                                        }
                                        
                                        // Size Selector Component
                                        SizePriceSelector(
                                            resellPrices: sneaker.resellPrices,
                                            userShoeSize: authManager.currentUser?.shoeSize
                                        )
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                } else if sneaker.stockXMinPrice == nil && sneaker.stockXMaxPrice == nil && sneaker.resellPrices.isEmpty {
                                    // No pricing available from either source
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Resale Pricing")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.secondary)
                                                Text("Not Available")
                                                    .font(.system(size: 16, weight: .medium))
                                                    .foregroundColor(.orange)
                                            }
                                            Spacer()
                                            Image(systemName: "exclamationmark.circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(.orange.opacity(0.6))
                                        }
                                        
                                        // Show link to visit website
                                        if let link = sneaker.source == .stockx ? sneaker.resellLinks?.stockX : sneaker.resellLinks?.goat {
                                            Link(destination: URL(string: link)!) {
                                                HStack {
                                                    Text("Visit \(sneaker.source == .stockx ? "StockX" : "GOAT") for pricing")
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.blue)
                                                    Image(systemName: "arrow.up.right")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding(.top, 4)
                                        }
                                    }
                                    .padding()
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Details Section
                            VStack(alignment: .leading, spacing: 12) {
                                if let releaseDate = sneaker.releaseDate {
                                    DetailRow(icon: "calendar", label: "Release Date", value: releaseDate)
                                }
                                
                                DetailRow(icon: "tag", label: "Style ID", value: sneaker.styleID)
                            }
                            
                            // Description
                            if let description = sneaker.description {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("About")
                                        .font(.system(size: 18, weight: .bold))
                                    
                                    Text(description)
                                        .font(.system(size: 15))
                                        .foregroundColor(.secondary)
                                        .lineSpacing(4)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            
                            // Like Button
                            Button(action: {
                                if let userId = authManager.currentUser?.id {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        viewModel.toggleLike(userId: userId)
                                    }
                                    authManager.refreshCurrentUser()
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.isLiked ? .red : .black)
                                    Text(viewModel.isLiked ? "Saved to Liked" : "Add to Liked")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(viewModel.isLiked ? .red : .black)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    viewModel.isLiked
                                    ? Color.red.opacity(0.1)
                                    : Color.black.opacity(0.05)
                                )
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(20)
                    }
                }
                .ignoresSafeArea(edges: .top)
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 70, weight: .light))
                        .foregroundColor(.gray.opacity(0.5))
                    
                    VStack(spacing: 8) {
                        Text("Sneaker Not Found")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("This sneaker couldn't be loaded")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userId = authManager.currentUser?.id {
                viewModel.loadSneaker(userId: userId)
            }
        }
    }
}

// Modern Price Row Component
struct ModernPriceRow: View {
            let site: String
            let price: Int
            let link: String?
            
            var body: some View {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(site)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        Text("Lowest Ask")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("$\(price)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    if let link = link, let url = URL(string: link) {
                        Link(destination: url) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        
// Detail Row Helper Component
struct DetailRow: View {
            let icon: String
            let label: String
            let value: String
            
            var body: some View {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(width: 24)
                    
                    Text(label)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        
class SneakerDetailViewModel: ObservableObject {
    @Published var sneaker: Sneaker?
    @Published var isLoading = false
    @Published var isLiked = false
    @Published var errorMessage: String?
    
    let styleID: String
    let source: String
    private let apiService = SneakAPIService.shared
    private let db = DatabaseManager.shared
    
    init(styleID: String, source: String = "stockx") {
        self.styleID = styleID
        self.source = source
    }
    
    func loadSneaker(userId: String) {
        isLoading = true
        errorMessage = nil
        
        // Check if liked
        isLiked = db.isLiked(styleID: styleID, userId: userId)
        
        print("🔄 Loading sneaker details for: \(styleID) from \(source)")
        
        Task {
            do {
                let sneaker: Sneaker
                
                // Call the appropriate API based on source
                if source == "stockx" {
                    sneaker = try await apiService.getStockXProduct(slug: styleID)
                } else {
                    // source == "goat"
                    sneaker = try await apiService.getGoatProduct(slug: styleID)
                }
                
                await MainActor.run {
                    print("✅ Successfully loaded sneaker: \(sneaker.shoeName)")
                    self.sneaker = sneaker
                    self.isLoading = false
                }
            } catch {
                print("❌ Error loading sneaker: \(error)")
                await MainActor.run {
                    self.errorMessage = "Unable to load sneaker details. Please visit the website to view this product."
                    self.isLoading = false
                }
            }
        }
    }
    
    func toggleLike(userId: String) {
        isLiked = db.toggleLike(styleID: styleID, userId: userId)
    }
}
        
// MARK: - Size Price Selector Component
        
struct SizePriceSelector: View {
            let resellPrices: [String: [String: Int]]
            let userShoeSize: String?
            
            @State private var searchSize: String = ""
            @State private var showingAllSizes = true
            
            // Sort sizes numerically
            private var sortedSizes: [(String, Int)] {
                let sizePrice = resellPrices.compactMap { (size, prices) -> (String, Int)? in
                    guard let goatPrice = prices["goat"] else { return nil }
                    return (size, goatPrice)
                }
                
                return sizePrice.sorted { first, second in
                    // Try to convert to Double for numeric sorting
                    if let num1 = Double(first.0), let num2 = Double(second.0) {
                        return num1 < num2
                    }
                    // Fallback to string comparison
                    return first.0 < second.0
                }
            }
            
            // Filtered sizes based on search
            private var filteredSizes: [(String, Int)] {
                if searchSize.isEmpty {
                    return sortedSizes
                }
                return sortedSizes.filter { $0.0.contains(searchSize) }
            }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    // Show user's size info if available
                    if let userSize = userShoeSize {
                        HStack {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            Text("Your size: US \(userSize)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // Search bar for size
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                        
                        TextField("Search size...", text: $searchSize)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 14))
                            .keyboardType(.decimalPad)
                        
                        if !searchSize.isEmpty {
                            Button(action: { searchSize = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .font(.system(size: 14))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                    
                    // Sizes list with ScrollViewReader to scroll to user's size
                    if filteredSizes.isEmpty {
                        Text("No sizes found")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollViewReader { proxy in
                            ScrollView {
                                VStack(spacing: 8) {
                                    ForEach(filteredSizes, id: \.0) { size, price in
                                        SizePriceRow(
                                            size: size,
                                            price: price,
                                            isUserSize: size == userShoeSize
                                        )
                                        .id(size) // Add ID for scrolling
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(maxHeight: 300)
                            .onAppear {
                                // Scroll to user's size when view appears
                                if let userSize = userShoeSize {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation {
                                            proxy.scrollTo(userSize, anchor: .center)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
// MARK: - Size Price Row Component
        
struct SizePriceRow: View {
            let size: String
            let price: Int
            let isUserSize: Bool
            
            var body: some View {
                HStack {
                    // Size
                    Text("US \(size)")
                        .font(.system(size: 15, weight: isUserSize ? .semibold : .regular))
                        .foregroundColor(isUserSize ? .white : .primary)
                    
                    if isUserSize {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Price
                    Text("$\(price)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isUserSize ? .white : .black)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isUserSize ? Color.black : Color.gray.opacity(0.05))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isUserSize ? Color.black : Color.clear, lineWidth: 2)
                )
            }
        }
        
struct SneakerDetailView_Previews: PreviewProvider {
            static var previews: some View {
                NavigationView {
                    SneakerDetailView(styleID: "FY2903")
                        .environmentObject(AuthManager())
                }
            }
        }
