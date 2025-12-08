import SwiftUI

/// App theme colors based on the SoleSociety brand
enum AppTheme {
    
    // MARK: - Primary Colors
    
    /// Primary tan/beige color from the app icon
    static let primaryTan = Color(red: 196/255, green: 164/255, blue: 132/255) // #C4A484
    
    /// Lighter tan for backgrounds
    static let lightTan = Color(red: 220/255, green: 200/255, blue: 175/255) // #DCC8AF
    
    /// Cream/off-white background
    static let cream = Color(red: 250/255, green: 245/255, blue: 235/255) // #FAF5EB
    
    /// Dark background for login
    static let darkBackground = Color(red: 28/255, green: 28/255, blue: 30/255) // #1C1C1E
    
    /// Secondary dark for gradients
    static let darkSecondary = Color(red: 44/255, green: 44/255, blue: 46/255) // #2C2C2E
    
    // MARK: - Accent Colors
    
    /// Accent tan for buttons and highlights
    static let accentTan = Color(red: 180/255, green: 140/255, blue: 100/255) // #B48C64
    
    /// Dark accent for contrast
    static let accentDark = Color(red: 45/255, green: 35/255, blue: 25/255) // #2D2319
    
    // MARK: - Text Colors
    
    /// Primary text on dark backgrounds
    static let textOnDark = Color.white
    
    /// Secondary text on dark backgrounds
    static let textSecondaryOnDark = Color.white.opacity(0.7)
    
    /// Primary text on light backgrounds
    static let textOnLight = Color(red: 45/255, green: 35/255, blue: 25/255) // #2D2319
    
    /// Secondary text on light backgrounds
    static let textSecondaryOnLight = Color.gray
    
    // MARK: - UI Element Colors
    
    /// Card background
    static let cardBackground = Color.white
    
    /// Input field background on dark
    static let inputFieldDark = Color.white.opacity(0.15)
    
    /// Input field border
    static let inputFieldBorder = Color.white.opacity(0.3)
    
    /// Tab bar background
    static let tabBarBackground = Color.white
    
    /// Selected tab item
    static let tabBarSelected = accentTan
    
    /// Unselected tab item
    static let tabBarUnselected = Color.gray
    
    // MARK: - Gradients
    
    /// Login page gradient
    static let loginGradient = LinearGradient(
        colors: [darkBackground, darkSecondary, darkBackground.opacity(0.95)],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Search view gradient (lighter)
    static let searchGradient = LinearGradient(
        colors: [cream, lightTan.opacity(0.3), cream],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Tan accent gradient for buttons
    static let tanGradient = LinearGradient(
        colors: [primaryTan, accentTan],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Shadows
    
    /// Standard card shadow
    static let cardShadow = Color.black.opacity(0.08)
    
    /// Elevated shadow
    static let elevatedShadow = Color.black.opacity(0.15)
}

// MARK: - View Modifiers

/// Tan pill button style for filter chips
struct TanPillStyle: ViewModifier {
    let isSelected: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.accentTan : AppTheme.cream)
            .foregroundColor(isSelected ? .white : AppTheme.textOnLight)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : AppTheme.primaryTan.opacity(0.3), lineWidth: 1)
            )
    }
}

/// Dark input field style
struct DarkInputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(AppTheme.inputFieldDark)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.inputFieldBorder, lineWidth: 1)
            )
    }
}

extension View {
    func tanPillStyle(isSelected: Bool) -> some View {
        modifier(TanPillStyle(isSelected: isSelected))
    }
    
    func darkInputFieldStyle() -> some View {
        modifier(DarkInputFieldStyle())
    }
}
