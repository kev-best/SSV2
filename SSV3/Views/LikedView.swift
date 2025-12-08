//
//  LikedView.swift
//  SoleSociety
//

import SwiftUI

struct LikedView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = LikedViewModel()
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
                
                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(AppTheme.accentTan)
                        Text("Loading your collection...")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.textSecondaryOnLight)
                    }
                } else if viewModel.likedSneakers.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 70, weight: .light))
                            .foregroundColor(AppTheme.primaryTan.opacity(0.5))
                        
                        VStack(spacing: 8) {
                            Text("No Liked Sneakers")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(AppTheme.textOnLight)
                            
                            Text("Start exploring and like sneakers\nto build your collection!")
                                .font(.system(size: 15))
                                .foregroundColor(AppTheme.textSecondaryOnLight)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 40)
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(viewModel.likedSneakers, id: \.styleID) { sneaker in
                                NavigationLink(destination: SneakerDetailView(styleID: sneaker.styleID)) {
                                    LikedSneakerCard(sneaker: sneaker)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .opacity(appearAnimation ? 1 : 0)
                    }
                }
            }
            .navigationTitle("Liked")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                if let userId = authManager.currentUser?.id {
                    viewModel.loadLikedSneakers(userId: userId)
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    appearAnimation = true
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
        
        // Load liked sneakers from API
         Task {
             // Use TaskGroup for concurrent loading with proper error handling
             let results = await withTaskGroup(of: Sneaker?.self) { group in
                 for styleID in styleIDs {
                     group.addTask {
                         do {
                             // Try GOAT first (has more details)
                             return try await self.apiService.getGoatProduct(slug: styleID)
                         } catch {
                             print("⚠️ GOAT failed for \(styleID), trying StockX: \(error)")
                             // Fallback to StockX
                             do {
                                 return try await self.apiService.getStockXProduct(slug: styleID)
                             } catch {
                                 print("❌ Both APIs failed for \(styleID): \(error)")
                                 return nil
                             }
                         }
                     }
                 }
                 
                 var loadedSneakers: [Sneaker] = []
                 for await result in group {
                     if let sneaker = result {
                         loadedSneakers.append(sneaker)
                     }
                 }
                 return loadedSneakers
             }
             
             await MainActor.run {
                 self.likedSneakers = results
                 self.isLoading = false
             }
         }
    }
}

struct LikedSneakerCard: View {
    let sneaker: Sneaker
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Container
            ZStack {
                // Gradient background
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
                AsyncImage(url: URL(string: sneaker.imageLinks.first ?? "")) { phase in
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
                // Sneaker Name
                Text(sneaker.shoeName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textOnLight)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 36, alignment: .top)
                
                // Colorway
                if let colorway = sneaker.colorway, !colorway.isEmpty {
                    Text(colorway)
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(AppTheme.textSecondaryOnLight)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Price with heart indicator
                HStack(alignment: .center, spacing: 4) {
                    if let lowestPrice = sneaker.lowestResellPrice?.stockX ?? sneaker.lowestResellPrice?.goat {
                        Text("$\(lowestPrice)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textOnLight)
                    } else {
                        Text("—")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textSecondaryOnLight)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.red.opacity(0.8))
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

struct LikedView_Previews: PreviewProvider {
    static var previews: some View {
        LikedView()
            .environmentObject(AuthManager())
    }
}
