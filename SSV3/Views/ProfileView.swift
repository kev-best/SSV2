//
//  ProfileView.swift
//  SoleSociety
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profile Header
                        VStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.gray)
                            
                            if let user = authManager.currentUser {
                                Text(user.username)
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                Text("User ID: \(user.id)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // Stats
                                HStack(spacing: 40) {
                                    VStack {
                                        Text("\(user.likedSneakerStyleIDs.count)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        Text("Liked")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .padding(.top)
                        
                        // Options
                        VStack(spacing: 0) {
                            ProfileOptionRow(
                                icon: "info.circle",
                                title: "About",
                                iconColor: .blue
                            )
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            ProfileOptionRow(
                                icon: "gearshape",
                                title: "Settings",
                                iconColor: .gray
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Logout Button
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                Text("Logout")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authManager.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
}

