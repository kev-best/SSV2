//
//  SearchView.swift
//  SoleSociety
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            
                            TextField("Search sneakers...", text: $searchText, onCommit: {
                                viewModel.searchSneakers(keyword: searchText)
                            })
                            .textFieldStyle(PlainTextFieldStyle())
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                    viewModel.clearSearch()
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        
                        // Search Results
                        if viewModel.isSearching {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Search Results")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                                    Text("No results found")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 15),
                                        GridItem(.flexible(), spacing: 15)
                                    ], spacing: 15) {
                                        ForEach(viewModel.searchResults) { sneaker in
                                            NavigationLink(destination: SneakerDetailView(styleID: sneaker.styleID)) {
                                                SneakerCardView(sneaker: sneaker)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        } else {
                            // Most Popular Section
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundColor(.orange)
                                    Text("Most Popular")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .padding(.horizontal)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                } else {
                                    LazyVGrid(columns: [
                                        GridItem(.flexible(), spacing: 15),
                                        GridItem(.flexible(), spacing: 15)
                                    ], spacing: 15) {
                                        ForEach(viewModel.popularSneakers) { sneaker in
                                            NavigationLink(destination: SneakerDetailView(styleID: sneaker.styleID)) {
                                                SneakerCardView(sneaker: sneaker)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            viewModel.loadPopularSneakers()
        }
    }
}

class SearchViewModel: ObservableObject {
    @Published var popularSneakers: [SneakerSearchResult] = []
    @Published var searchResults: [SneakerSearchResult] = []
    @Published var isLoading = false
    @Published var isSearching = false
    
    private let apiService = SneakAPIService.shared
    
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
                let sneakers = try await apiService.getCuratedNike()
                await MainActor.run {
                    self.popularSneakers = sneakers
                    self.isLoading = false
                }
            } catch {
                print("Error loading popular sneakers: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
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
                await MainActor.run {
                    self.searchResults = sneakers
                    self.isLoading = false
                }
            } catch {
                print("Error searching sneakers: \(error)")
                await MainActor.run {
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

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(AuthManager())
    }
}

