//
//  ProfileView.swift
//  SoleSociety
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutAlert = false
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
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 20) {
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [AppTheme.accentDark, AppTheme.accentTan]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: AppTheme.primaryTan.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            if let user = authManager.currentUser {
                                VStack(spacing: 6) {
                                    Text(user.username)
                                        .font(.system(size: 26, weight: .bold))
                                        .foregroundColor(AppTheme.textOnLight)
                                    
                                    Text("Member since \(formatDate())")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppTheme.textSecondaryOnLight)
                                }
                                
                                // Stats Card
                                HStack(spacing: 0) {
                                    StatItem(
                                        value: "\(user.likedSneakerStyleIDs.count)",
                                        label: "Liked",
                                        icon: "heart.fill"
                                    )
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: AppTheme.primaryTan.opacity(0.12), radius: 10, x: 0, y: 4)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -15)
                        
                        // Shoe Size Section
                        if let user = authManager.currentUser {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "ruler.fill")
                                        .foregroundColor(AppTheme.accentTan)
                                        .font(.system(size: 16))
                                    
                                    Text("My Shoe Size")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.textOnLight)
                                    
                                    Spacer()
                                }
                                
                                ShoeSizePickerView(
                                    currentSize: user.shoeSize,
                                    userId: user.id
                                )
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: AppTheme.primaryTan.opacity(0.1), radius: 8, x: 0, y: 2)
                            .padding(.horizontal, 20)
                            .opacity(appearAnimation ? 1 : 0)
                            .offset(y: appearAnimation ? 0 : 10)
                        }
                        
                        // Options Section
                        VStack(spacing: 0) {
                            ModernOptionRow(
                                icon: "info.circle.fill",
                                title: "About",
                                iconColor: AppTheme.accentTan
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            ModernOptionRow(
                                icon: "gearshape.fill",
                                title: "Settings",
                                iconColor: AppTheme.textSecondaryOnLight
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: AppTheme.primaryTan.opacity(0.1), radius: 8, x: 0, y: 2)
                        .padding(.horizontal, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 10)
                        
                        // Logout Button
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                                    .font(.system(size: 18))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: AppTheme.primaryTan.opacity(0.1), radius: 8, x: 0, y: 2)
                            )
                        }
                        .padding(.horizontal, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 10)
                        
                        // App Version
                        Text("SoleSociety v1.0")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textSecondaryOnLight.opacity(0.6))
                            .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Sign Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                    appearAnimation = true
                }
            }
        }
    }
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: Date())
    }
}

// Modern Option Row Component
struct ModernOptionRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textOnLight)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textSecondaryOnLight.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}

// Stat Item Component
struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.red.opacity(0.8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.textOnLight)
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondaryOnLight)
            }
        }
    }
}

// MARK: - Shoe Size Picker Component

struct ShoeSizePickerView: View {
    let currentSize: String?
    let userId: String
    
    @State private var selectedSize: String
    @EnvironmentObject var authManager: AuthManager
    
    private let shoeSizes = [
        "6", "6.5", "7", "7.5", "8", "8.5", "9", "9.5",
        "10", "10.5", "11", "11.5", "12", "12.5", "13", "13.5", "14", "15"
    ]
    
    init(currentSize: String?, userId: String) {
        self.currentSize = currentSize
        self.userId = userId
        _selectedSize = State(initialValue: currentSize ?? "10")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set your preferred shoe size to see personalized pricing")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondaryOnLight)
            
            Menu {
                ForEach(shoeSizes, id: \.self) { size in
                    Button(action: {
                        selectedSize = size
                        updateShoeSize(size)
                    }) {
                        HStack {
                            Text("US \(size)")
                            if size == selectedSize {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text("US \(selectedSize)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.textOnLight)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentTan)
                }
                .padding()
                .background(AppTheme.cream)
                .cornerRadius(10)
            }
        }
    }
    
    private func updateShoeSize(_ size: String) {
        DatabaseManager.shared.updateShoeSize(userId: userId, size: size)
        authManager.refreshCurrentUser()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
}
