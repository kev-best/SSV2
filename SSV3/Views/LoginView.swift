//
//  LoginView.swift
//  SoleSociety
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            // Background gradient - dark with subtle tan tint
            LinearGradient(
                gradient: Gradient(colors: [
                    AppTheme.darkBackground,
                    Color(red: 35/255, green: 30/255, blue: 25/255),
                    AppTheme.darkSecondary
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle tan accent overlay at bottom
            VStack {
                Spacer()
                AppTheme.primaryTan.opacity(0.15)
                    .frame(height: 300)
                    .blur(radius: 100)
            }
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "shoeprints.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: AppTheme.primaryTan.opacity(0.5), radius: 20)
                    
                    Text("SoleSociety")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Track Your Kicks")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.primaryTan)
                }
                .padding(.bottom, 40)
                .scaleEffect(appearAnimation ? 1 : 0.8)
                .opacity(appearAnimation ? 1 : 0)
                
                // Login Form
                VStack(spacing: 20) {
                    // Username field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(AppTheme.primaryTan)
                            .frame(width: 30)
                        
                        TextField("", text: $username, prompt: Text("Username").foregroundColor(.white.opacity(0.7)))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.primaryTan.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Password field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(AppTheme.primaryTan)
                            .frame(width: 30)
                        
                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.7)))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.primaryTan.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Login/Register Button
                    Button(action: handleAuth) {
                        Text(isRegistering ? "Create Account" : "Login")
                            .font(.headline)
                            .foregroundColor(AppTheme.darkBackground)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.white, AppTheme.cream],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: AppTheme.primaryTan.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.top, 10)
                    
                    // Toggle between login and register
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isRegistering.toggle()
                            showError = false
                        }
                    }) {
                        Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.primaryTan)
                    }
                    
                    // Error message
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }
                    
                    // Demo credentials hint
                    if !isRegistering {
                        VStack(spacing: 5) {
                            Text("Demo Credentials:")
                                .font(.caption)
                                .foregroundColor(AppTheme.primaryTan.opacity(0.7))
                            Text("Username: demo | Password: password")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 40)
                .offset(y: appearAnimation ? 0 : 30)
                .opacity(appearAnimation ? 1 : 0)
            }
            .padding(.vertical, 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appearAnimation = true
            }
        }
    }
    
    private func handleAuth() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both username and password"
            showError = true
            return
        }
        
        let success: Bool
        if isRegistering {
            success = authManager.register(username: username, password: password)
            if !success {
                errorMessage = "Username already exists"
                showError = true
            }
        } else {
            success = authManager.login(username: username, password: password)
            if !success {
                errorMessage = "Invalid username or password"
                showError = true
            }
        }
        
        if success {
            username = ""
            password = ""
            showError = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager())
    }
}

