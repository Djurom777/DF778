import SwiftUI

extension Color {
    // Primary Colors
    static let backgroundPrimary = Color(hex: "#3e4464")
    static let backgroundSecondary = Color(hex: "#4a5178")
    static let accentYellow = Color(hex: "#fcc418")
    static let accentGreen = Color(hex: "#3cc45b")
    
    // Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.8)
    static let textTertiary = Color(white: 0.6)
    
    // Status Colors
    static let statusSuccess = Color(hex: "#10B981")
    static let statusWarning = Color(hex: "#F59E0B")
    static let statusError = Color(hex: "#EF4444")
    static let statusInfo = Color(hex: "#3B82F6")
    
    // Utility
    static let cardBackground = Color(hex: "#525a84")
    static let divider = Color(white: 0.3)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}