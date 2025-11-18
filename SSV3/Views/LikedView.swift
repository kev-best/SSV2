//
//  LikedView.swift
//  SoleSociety
//

import SwiftUI

struct LikedView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = LikedViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.likedSneakers.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Liked Sneakers")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Start exploring and like sneakers to see them here!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 15),
                            GridItem(.flexible(), spacing: 15)
                        ], spacing: 15) {
                            ForEach(viewModel.likedSneakers, id: \.styleID) { sneaker in
                                NavigationLink(destination: SneakerDetailView(styleID: sneaker.styleID)) {
                                    LikedSneakerCard(sneaker: sneaker)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Liked")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let userId = authManager.currentUser?.id {
                    viewModel.loadLikedSneakers(userId: userId)
                }
            }
        }
    }
}

class LikedViewModel: ObservableObject {
    @Published var likedSneakers: [Sneaker] = []
    @Published var isLoading = false
    
    private let apiService = SneakAPIService.shared
    private let db = DatabaseManager.shared
    
    func loadLikedSneakers(userId: String) {
        isLoading = true
        
        let styleIDs = db.getLikedStyleIDs(userId: userId)
        
        // Using mock data for now
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.likedSneakers = styleIDs.map { styleID in
//                self.apiService.getMockSneakerDetail(styleID: styleID)
//            }
//            self.isLoading = false
//        }
        
        // TODO: Replace with actual API calls when backend is ready
         Task {
             var sneakers: [Sneaker] = []
             for styleID in styleIDs {
                 do {
                     // Try stockx first, fallback to goat if needed
                     let sneaker = try await apiService.getProductPrices(styleID: styleID, source: "stockx")
                     sneakers.append(sneaker)
                 } catch {
                     print("Error loading sneaker \(styleID): \(error)")
                 }
             }
             await MainActor.run {
                 self.likedSneakers = sneakers
                 self.isLoading = false
             }
         }
    }
}

struct LikedSneakerCard: View {
    let sneaker: Sneaker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sneaker Image
            AsyncImage(url: URL(string: sneaker.imageLinks.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 120)
            .cornerRadius(10)
            
            // Sneaker Info
            VStack(alignment: .leading, spacing: 4) {
                Text(sneaker.shoeName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                if let colorway = sneaker.colorway {
                    Text(colorway)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let lowestPrice = sneaker.lowestResellPrice?.stockX ?? sneaker.lowestResellPrice?.goat {
                    Text("$\(lowestPrice)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                } else {
                    Text("—")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct LikedView_Previews: PreviewProvider {
    static var previews: some View {
        LikedView()
            .environmentObject(AuthManager())
    }
}

