//
//  SearchView.swift
//  SoleSociety
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemGroupedBackground),
                        Color(UIColor.systemBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Modern Search Bar
                        HStack(spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
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
                                            .foregroundColor(.gray.opacity(0.6))
                                            .font(.system(size: 16))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                            )
                            
                            if isSearchFocused {
                                Button("Cancel") {
                                    searchText = ""
                                    viewModel.clearSearch()
                                    isSearchFocused = false
                                }
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                        
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
                        }
                        
                        // Search Results or Popular Section
                        if viewModel.isSearching {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Search Results")
                                        .font(.system(size: 24, weight: .bold))
                                    Spacer()
                                    Text("\(viewModel.searchResults.count) found")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                
                                if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                                    VStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray.opacity(0.5))
                                        Text("No results found")
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.secondary)
                                        Text("Try different keywords")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary.opacity(0.7))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                } else {
                                    modernSneakerGrid(sneakers: viewModel.searchResults)
                                }
                            }
                        } else {
                            // Most Popular Section
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 8) {
                                    Image(systemName: viewModel.selectedCategory == "All" ? "flame.fill" : "star.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.selectedCategory == "All" ? .orange : .black)
                                    Text(viewModel.selectedCategory == "All" ? "Most Popular" : viewModel.selectedCategory)
                                        .font(.system(size: 24, weight: .bold))
                                }
                                .padding(.horizontal, 20)
                                
                                if viewModel.isLoading {
                                    VStack(spacing: 12) {
                                        ProgressView()
                                        Text("Loading sneakers...")
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 60)
                                } else {
                                    modernSneakerGrid(sneakers: viewModel.popularSneakers)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.loadPopularSneakers()
        }
    }
    
    @ViewBuilder
    private func modernSneakerGrid(sneakers: [SneakerSearchResult]) -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(sneakers) { sneaker in
                NavigationLink(destination: SneakerDetailView(styleID: sneaker.styleID)) {
                    ModernSneakerCard(sneaker: sneaker)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
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
                                Color.gray.opacity(0.05),
                                Color.gray.opacity(0.1)
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
                                .foregroundColor(.gray.opacity(0.4))
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
                        .foregroundColor(sneaker.displayPrice == "—" ? .gray : .black)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(height: 100)
        }
        .frame(height: 240)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

class SearchViewModel: ObservableObject {
    @Published var popularSneakers: [SneakerSearchResult] = []
    @Published var searchResults: [SneakerSearchResult] = []
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var selectedCategory: String = "All"
    
    private let apiService = SneakAPIService.shared
    
    let categories = ["All", "Nike", "Jordan", "Adidas", "Yeezy", "New Balance", "Puma", "Reebok"]
    
    func loadPopularSneakers() {
        isLoading = true
        
        // Using mock data for now
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //     self.popularSneakers = self.apiService.getMockPopularSneakers()
        //     self.isLoading = false
        // }
        
        // TODO: Replace with actual API call when backend is ready
        Task {
            do {
                let sneakers: [SneakerSearchResult]
                
                // If a specific brand is selected, fetch that brand's sneakers
                if selectedCategory != "All" {
                    sneakers = try await apiService.fetchProductsByBrand(brand: selectedCategory, limit: 20)
                } else {
                    // For "All", get curated mix from multiple brands
                    sneakers = try await apiService.getCuratedNike()
                }
                
                // Filter out sneakers without valid prices or images
                let validSneakers = sneakers.filter {
                    !$0.shoeName.isEmpty &&
                    $0.thumbnail != nil &&
                    !$0.thumbnail!.isEmpty &&
                    $0.displayPrice != "—" // Exclude sneakers without pricing
                }
                
                await MainActor.run {
                    self.popularSneakers = validSneakers
                    self.isLoading = false
                }
            } catch {
                print("Error loading popular sneakers: \(error)")
                await MainActor.run {
                    // On error, show empty list rather than crashing
                    self.popularSneakers = []
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
        
        // Using mock data filtered by keyword for now
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //     self.searchResults = self.apiService.getMockPopularSneakers().filter {
        //         $0.shoeName.lowercased().contains(keyword.lowercased())
        //     }
        //     self.isLoading = false
        // }
        
        // TODO: Replace with actual API call when backend is ready
        Task {
            do {
                let sneakers = try await apiService.search(keyword: keyword, limit: 20)
                // Filter out invalid sneakers and those without prices
                let validSneakers = sneakers.filter {
                    !$0.shoeName.isEmpty &&
                    $0.thumbnail != nil &&
                    !$0.thumbnail!.isEmpty &&
                    $0.displayPrice != "—" // Exclude sneakers without pricing
                }
                await MainActor.run {
                    self.searchResults = validSneakers
                    self.isLoading = false
                }
            } catch {
                print("Error searching sneakers: \(error)")
                await MainActor.run {
                    // On error, show empty results
                    self.searchResults = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func clearSearch() {
        isSearching = false
        searchResults = []
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
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.black : Color.white)
                        .shadow(color: Color.black.opacity(isSelected ? 0.15 : 0.08), radius: 8, x: 0, y: 2)
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
