//
//  SneakerDetailView.swift
//  SoleSociety
//

import SwiftUI

struct SneakerDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: SneakerDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(styleID: String) {
        _viewModel = StateObject(wrappedValue: SneakerDetailViewModel(styleID: styleID))
    }
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let sneaker = viewModel.sneaker {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Image Gallery
                        TabView {
                            ForEach(sneaker.imageLinks, id: \.self) { imageUrl in
                                AsyncImage(url: URL(string: imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .overlay(
                                            ProgressView()
                                        )
                                }
                            }
                        }
                        .frame(height: 300)
                        .tabViewStyle(PageTabViewStyle())
                        
                        VStack(alignment: .leading, spacing: 15) {
                            // Sneaker Name
                            Text(sneaker.shoeName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Brand and Colorway
                            if let brand = sneaker.brand {
                                HStack {
                                    Text(brand)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    if let colorway = sneaker.colorway {
                                        Text("•")
                                            .foregroundColor(.secondary)
                                        Text(colorway)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            
                            // Prices
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Prices")
                                    .font(.headline)
                                
                                if let retailPrice = sneaker.retailPrice {
                                    HStack {
                                        Text("Retail:")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("$\(retailPrice)")
                                            .fontWeight(.semibold)
                                    }
                                }
                                
                                if let lowestResell = sneaker.lowestResellPrice {
                                    Divider()
                                    
                                    if let stockx = lowestResell.stockX {
                                        PriceRow(site: "StockX", price: stockx, link: sneaker.resellLinks?.stockX)
                                    }
                                    
                                    if let goat = lowestResell.goat {
                                        PriceRow(site: "GOAT", price: goat, link: sneaker.resellLinks?.goat)
                                    }
                                    
                                    if let fc = lowestResell.flightClub {
                                        PriceRow(site: "Flight Club", price: fc, link: sneaker.resellLinks?.flightClub)
                                    }
                                    
                                    if let sg = lowestResell.stadiumGoods {
                                        PriceRow(site: "Stadium Goods", price: sg, link: sneaker.resellLinks?.stadiumGoods)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(10)
                            
                            // Release Date
                            if let releaseDate = sneaker.releaseDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.secondary)
                                    Text("Release Date: \(releaseDate)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Style ID
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.secondary)
                                Text("Style ID: \(sneaker.styleID)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Description
                            if let description = sneaker.description {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Description")
                                        .font(.headline)
                                    
                                    Text(description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Like Button
                            Button(action: {
                                if let userId = authManager.currentUser?.id {
                                    viewModel.toggleLike(userId: userId)
                                    authManager.refreshCurrentUser()
                                }
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(viewModel.isLiked ? .red : .gray)
                                    Text(viewModel.isLiked ? "Liked" : "Like")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isLiked ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                }
            } else {
                Text("Failed to load sneaker details")
                    .foregroundColor(.secondary)
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

struct PriceRow: View {
    let site: String
    let price: Int
    let link: String?
    
    var body: some View {
        HStack {
            Text(site)
                .foregroundColor(.secondary)
            Spacer()
            Text("$\(price)")
                .fontWeight(.semibold)
            
            if let link = link, let url = URL(string: link) {
                Link(destination: url) {
                    Image(systemName: "arrow.up.right.square")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

class SneakerDetailViewModel: ObservableObject {
    @Published var sneaker: Sneaker?
    @Published var isLoading = false
    @Published var isLiked = false
    
    let styleID: String
    private let apiService = SneakAPIService.shared
    private let db = DatabaseManager.shared
    
    init(styleID: String) {
        self.styleID = styleID
    }
    
    func loadSneaker(userId: String) {
        isLoading = true
        
        // Check if liked
        isLiked = db.isLiked(styleID: styleID, userId: userId)
        
        // Using mock data for now
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //     self.sneaker = self.apiService.getMockSneakerDetail(styleID: self.styleID)
        //     self.isLoading = false
        // }
        
        // TODO: Replace with actual API call when backend is ready
        Task {
            do {
                let sneaker = try await apiService.getProductPrices(styleID: styleID, source: "stockx")
                await MainActor.run {
                    self.sneaker = sneaker
                    self.isLoading = false
                }
            } catch {
                print("Error loading sneaker: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func toggleLike(userId: String) {
        isLiked = db.toggleLike(styleID: styleID, userId: userId)
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

