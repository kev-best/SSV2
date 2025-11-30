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
                            
                            // Price Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Pricing")
                                    .font(.system(size: 18, weight: .bold))
                                
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
                                
                                if let lowestResell = sneaker.lowestResellPrice {
                                    VStack(spacing: 0) {
                                        if let stockx = lowestResell.stockX {
                                            ModernPriceRow(site: "StockX", price: stockx, link: sneaker.resellLinks?.stockX)
                                        }
                                        
                                        if let goat = lowestResell.goat {
                                            Divider().padding(.leading, 16)
                                            ModernPriceRow(site: "GOAT", price: goat, link: sneaker.resellLinks?.goat)
                                        }
                                        
                                        if let fc = lowestResell.flightClub {
                                            Divider().padding(.leading, 16)
                                            ModernPriceRow(site: "Flight Club", price: fc, link: sneaker.resellLinks?.flightClub)
                                        }
                                        
                                        if let sg = lowestResell.stadiumGoods {
                                            Divider().padding(.leading, 16)
                                            ModernPriceRow(site: "Stadium Goods", price: sg, link: sneaker.resellLinks?.stadiumGoods)
                                        }
                                    }
                                    .background(Color.white)
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
    private let apiService = SneakAPIService.shared
    private let db = DatabaseManager.shared
    
    init(styleID: String) {
        self.styleID = styleID
    }
    
    func loadSneaker(userId: String) {
        isLoading = true
        errorMessage = nil
        
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
                    self.errorMessage = "Unable to load sneaker details. Please try again."
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
