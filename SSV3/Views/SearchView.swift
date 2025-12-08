//
//  SearchView.swift
//  SoleSociety
//

import SwiftUI

enum SearchSource: String, CaseIterable {
    case stockx = "StockX"
    case goat = "GOAT"
    case both = "Both"
}

struct SearchView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var selectedSource: SearchSource = .both
    @State private var appearAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern tan-themed gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppTheme.cream,
                        AppTheme.lightTan.opacity(0.3),
                        AppTheme.cream
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Source Tabs (StockX, GOAT, Both)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(SearchSource.allCases, id: \.self) { source in
                                    SourceTabButton(
                                        title: source.rawValue,
                                        isSelected: selectedSource == source,
                                        action: {
                                            selectedSource = source
                                            viewModel.selectedSource = source
                                            if !viewModel.isSearching {
                                                viewModel.loadPopularSneakers()
                                            } else if !searchText.isEmpty {
                                                viewModel.searchSneakers(keyword: searchText)
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -10)
                        
                        // Modern Search Bar
                        HStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(AppTheme.accentTan)
                                    .font(.system(size: 16, weight: .medium))
                                
                                TextField("Search sneakers...", text: $searchText, onCommit: {
                                    viewModel.searchSneakers(keyword: searchText)
                                })
                                .focused($isSearchFocused)
                                .textFieldStyle(PlainTextFieldStyle())
                                .font(.system(size: 16))
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                        viewModel.clearSearch()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(AppTheme.primaryTan)
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: AppTheme.primaryTan.opacity(0.15), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppTheme.primaryTan.opacity(0.2), lineWidth: 1)
                            )
                            
                            if isSearchFocused {
                                Button("Cancel") {
                                    searchText = ""
                                    viewModel.clearSearch()
                                    isSearchFocused = false
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppTheme.accentTan)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -10)
                        
                        // Category Filter (only show when not searching)
                        if !viewModel.isSearching {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.categories, id: \.self) { category in
                                        CategoryChip(
                                            title: category,
                                            isSelected: viewModel.selectedCategory == category,
                                            action: {
                                                viewModel.selectCategory(category)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 8)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : -10)
                        }
                        
                        // Content based on loading state and source
                        if viewModel.isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(AppTheme.accentTan)
                                Text("Loading sneakers...")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppTheme.textSecondaryOnLight)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else if viewModel.isSearching {
                            searchResultsContent
                                .opacity(appearAnimation ? 1 : 0)
                        } else {
                            popularContent
                                .opacity(appearAnimation ? 1 : 0)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            // Set user's shoe size for pricing
            if let user = authManager.currentUser {
                viewModel.userShoeSize = user.shoeSize
            }
            viewModel.selectedSource = selectedSource
            viewModel.loadPopularSneakers()
            
            // Trigger appearance animation
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Search Results Content
    @ViewBuilder
    private var searchResultsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedSource == .both {
                // Show separate sections for StockX and GOAT
                if !viewModel.stockXResults.isEmpty {
                    sectionHeader(title: "From StockX", count: viewModel.stockXResults.count)
                    modernSneakerGrid(sneakers: viewModel.stockXResults)
                }
                
                if !viewModel.goatResults.isEmpty {
                    sectionHeader(title: "From GOAT", count: viewModel.goatResults.count)
                        .padding(.top, viewModel.stockXResults.isEmpty ? 0 : 24)
                    modernSneakerGrid(sneakers: viewModel.goatResults)
                }
                
                if viewModel.stockXResults.isEmpty && viewModel.goatResults.isEmpty {
                    emptySearchState
                }
            } else {
                // Show single section for selected source
                let results = selectedSource == .stockx ? viewModel.stockXResults : viewModel.goatResults
                sectionHeader(title: "Search Results", count: results.count)
                
                if results.isEmpty {
                    emptySearchState
                } else {
                    modernSneakerGrid(sneakers: results)
                }
            }
        }
    }
    
    // MARK: - Popular Content
    @ViewBuilder
    private var popularContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if selectedSource == .both {
                // Show separate sections for StockX and GOAT
                if !viewModel.stockXPopular.isEmpty {
                    sectionHeader(
                        title: "From StockX",
                        count: viewModel.stockXPopular.count,
                        icon: viewModel.selectedCategory == "All" ? "flame.fill" : "star.fill",
                        iconColor: viewModel.selectedCategory == "All" ? .orange : .black
                    )
                    modernSneakerGrid(sneakers: viewModel.stockXPopular)
                }
                
                if !viewModel.goatPopular.isEmpty {
                    sectionHeader(
                        title: "From GOAT",
                        count: viewModel.goatPopular.count,
                        icon: viewModel.selectedCategory == "All" ? "flame.fill" : "star.fill",
                        iconColor: viewModel.selectedCategory == "All" ? .orange : .black
                    )
                    .padding(.top, viewModel.stockXPopular.isEmpty ? 0 : 24)
                    modernSneakerGrid(sneakers: viewModel.goatPopular)
                }
            } else {
                // Show single section for selected source
                let popular = selectedSource == .stockx ? viewModel.stockXPopular : viewModel.goatPopular
                sectionHeader(
                    title: viewModel.selectedCategory == "All" ? "Most Popular" : viewModel.selectedCategory,
                    count: popular.count,
                    icon: viewModel.selectedCategory == "All" ? "flame.fill" : "star.fill",
                    iconColor: viewModel.selectedCategory == "All" ? .orange : .black
                )
                modernSneakerGrid(sneakers: popular)
            }
        }
    }
    
    // MARK: - Helper Views
    @ViewBuilder
    private func sectionHeader(title: String, count: Int, icon: String? = nil, iconColor: Color = .black) -> some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
            }
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(AppTheme.textOnLight)
            Spacer()
            Text("\(count) found")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryOnLight)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var emptySearchState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(AppTheme.primaryTan.opacity(0.5))
            Text("No shoes found")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(AppTheme.textSecondaryOnLight)
            Text("Try different keywords")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textSecondaryOnLight.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    @ViewBuilder
    private func modernSneakerGrid(sneakers: [SneakerSearchResult]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(sneakers) { sneaker in
                NavigationLink(destination: SneakerDetailView(styleID: sneaker.styleID, source: sneaker.source.rawValue)) {
                    ModernSneakerCard(sneaker: sneaker)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

// Source Tab Button Component
struct SourceTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .bold : .semibold))
                .foregroundColor(isSelected ? .white : AppTheme.textOnLight)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accentDark : Color.white)
                        .shadow(color: AppTheme.primaryTan.opacity(isSelected ? 0.3 : 0.15), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : AppTheme.primaryTan.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Modern Sneaker Card Component
struct ModernSneakerCard: View {
    let sneaker: SneakerSearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Container
            ZStack {
                // Image background
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                AppTheme.cream,
                                AppTheme.lightTan.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Sneaker Image
                AsyncImage(url: URL(string: sneaker.thumbnail ?? "")) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(AppTheme.accentTan)
                            .frame(height: 140)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 140)
                            .padding(12)
                    case .failure:
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(AppTheme.primaryTan.opacity(0.4))
                        }
                        .frame(height: 140)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .frame(height: 140)
            
            // Info Container
            VStack(alignment: .leading, spacing: 6) {
                // Brand/Model
                Text(sneaker.shoeName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 36, alignment: .top)
                
                // Colorway
                if let colorway = sneaker.colorway, !colorway.isEmpty {
                    Text(colorway)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Price
                HStack(alignment: .center, spacing: 4) {
                    Text(sneaker.displayPrice)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(sneaker.displayPrice == "—" ? AppTheme.textSecondaryOnLight : AppTheme.textOnLight)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.accentTan)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(height: 100)
        }
        .frame(height: 240)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: AppTheme.primaryTan.opacity(0.12), radius: 12, x: 0, y: 4)
    }
}

class SearchViewModel: ObservableObject {
    @Published var isSearching = false
    @Published var isLoading = false
    @Published var selectedCategory = "All"
    @Published var selectedSource: SearchSource = .both
    
    // Separate results for each source
    @Published var stockXResults: [SneakerSearchResult] = []
    @Published var goatResults: [SneakerSearchResult] = []
    @Published var stockXPopular: [SneakerSearchResult] = []
    @Published var goatPopular: [SneakerSearchResult] = []
    
    var userShoeSize: String?
    
    let categories = ["All", "Nike", "Jordan", "Adidas", "Yeezy"]
    private let apiService = SneakAPIService.shared
    
    func loadPopularSneakers() {
        isLoading = true
        
        Task {
            do {
                switch selectedSource {
                case .stockx:
                    let sneakers = try await fetchStockXSneakers()
                    await MainActor.run {
                        self.stockXPopular = sneakers
                        self.goatPopular = []
                        self.isLoading = false
                    }
                    
                case .goat:
                    let sneakers = try await fetchGoatSneakers()
                    await MainActor.run {
                        self.stockXPopular = []
                        self.goatPopular = sneakers
                        self.isLoading = false
                    }
                    
                case .both:
                    let (stockx, goat) = try await fetchBothSneakers()
                    await MainActor.run {
                        self.stockXPopular = stockx
                        self.goatPopular = goat
                        self.isLoading = false
                    }
                }
            } catch {
                print("❌ Error loading popular sneakers: \(error)")
                await MainActor.run {
                    self.stockXPopular = []
                    self.goatPopular = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
        loadPopularSneakers()
    }
    
    func searchSneakers(keyword: String) {
        guard !keyword.isEmpty else {
            clearSearch()
            return
        }
        
        isSearching = true
        isLoading = true
        
        Task {
            do {
                print("🔍 Searching for: \(keyword) on \(selectedSource.rawValue)")
                
                switch selectedSource {
                case .stockx:
                    let sneakers = try await apiService.searchStockX(keyword: keyword, limit: 20)
                    await MainActor.run {
                        self.stockXResults = filterValid(sneakers)
                        self.goatResults = []
                        self.isLoading = false
                    }
                    
                case .goat:
                    let sneakers = try await apiService.searchGoat(keyword: keyword, limit: 20, userShoeSize: userShoeSize)
                    await MainActor.run {
                        self.stockXResults = []
                        self.goatResults = filterValid(sneakers)
                        self.isLoading = false
                    }
                    
                case .both:
                    let (stockx, goat) = try await apiService.searchBoth(keyword: keyword, limit: 20, userShoeSize: userShoeSize)
                    await MainActor.run {
                        self.stockXResults = filterValid(stockx)
                        self.goatResults = filterValid(goat)
                        self.isLoading = false
                    }
                }
                
                print("✅ Search complete")
            } catch {
                print("❌ Error searching sneakers: \(error)")
                await MainActor.run {
                    self.stockXResults = []
                    self.goatResults = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearSearch() {
        isSearching = false
        stockXResults = []
        goatResults = []
    }
    
    // MARK: - Private Helpers
    
    private func fetchStockXSneakers() async throws -> [SneakerSearchResult] {
        if selectedCategory != "All" {
            return try await apiService.fetchStockXByBrand(brand: selectedCategory, limit: 20)
        } else {
            return try await apiService.getCuratedStockX(limit: 10)
        }
    }
    
    private func fetchGoatSneakers() async throws -> [SneakerSearchResult] {
        if selectedCategory != "All" {
            return try await apiService.fetchGoatByBrand(brand: selectedCategory, limit: 20, userShoeSize: userShoeSize)
        } else {
            return try await apiService.getCuratedGoat(limit: 10, userShoeSize: userShoeSize)
        }
    }
    
    private func fetchBothSneakers() async throws -> (stockx: [SneakerSearchResult], goat: [SneakerSearchResult]) {
        if selectedCategory != "All" {
            return try await apiService.fetchBothByBrand(brand: selectedCategory, limit: 20, userShoeSize: userShoeSize)
        } else {
            return try await apiService.getCuratedBoth(limit: 10, userShoeSize: userShoeSize)
        }
    }
    
    private func filterValid(_ sneakers: [SneakerSearchResult]) -> [SneakerSearchResult] {
        return sneakers.filter {
            let isValid = !$0.shoeName.isEmpty && $0.thumbnail != nil && !$0.thumbnail!.isEmpty
            if !isValid {
                print("⚠️ Filtered out invalid sneaker: \($0.shoeName)")
            }
            return isValid
        }
    }
}

// Category Chip Component
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                .foregroundColor(isSelected ? .white : AppTheme.textOnLight)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? AppTheme.accentTan : Color.white)
                        .shadow(color: AppTheme.primaryTan.opacity(isSelected ? 0.25 : 0.12), radius: 8, x: 0, y: 2)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : AppTheme.primaryTan.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(AuthManager())
    }
}
