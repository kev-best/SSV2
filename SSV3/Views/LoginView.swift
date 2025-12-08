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
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "shoeprints.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("SoleSociety")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Track Your Kicks")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
                
                // Login Form
                VStack(spacing: 20) {
                    // Username field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .frame(width: 30)
                        
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Password field
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        
                        SecureField("Password", text: $password)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Login/Register Button
                    Button(action: handleAuth) {
                        Text(isRegistering ? "Create Account" : "Login")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    // Toggle between login and register
                    Button(action: {
                        isRegistering.toggle()
                        showError = false
                    }) {
                        Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    // Error message
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Demo credentials hint
                    if !isRegistering {
                        VStack(spacing: 5) {
                            Text("Demo Credentials:")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            Text("Username: demo | Password: password")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 50)
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

