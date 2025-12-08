//
//  SneakerCardView.swift
//  SoleSociety
//

import SwiftUI

struct SneakerCardView: View {
    let sneaker: SneakerSearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Sneaker Image
            AsyncImage(url: URL(string: sneaker.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(AppTheme.cream)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(AppTheme.primaryTan.opacity(0.4))
                    )
            }
            .frame(height: 120)
            .cornerRadius(10)
            
            // Sneaker Info
            VStack(alignment: .leading, spacing: 4) {
                Text(sneaker.shoeName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.textOnLight)
                    .lineLimit(2)
                
                if let colorway = sneaker.colorway {
                    Text(colorway)
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondaryOnLight)
                        .lineLimit(1)
                }
                
                Text(sneaker.displayPrice)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(sneaker.displayPrice == "—" ? AppTheme.textSecondaryOnLight : AppTheme.textOnLight)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: AppTheme.primaryTan.opacity(0.12), radius: 5, x: 0, y: 2)
    }
}

