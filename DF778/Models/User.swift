import Foundation

struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var profileImageURL: String?
    var role: UserRole
    var preferences: UserPreferences
    var createdAt: Date
    var lastActiveAt: Date
    
    enum UserRole: String, CaseIterable, Codable {
        case admin = "admin"
        case manager = "manager"
        case member = "member"
        case viewer = "viewer"
    }
}

struct UserPreferences: Codable {
    var enableNotifications: Bool = true
    var workStartTime: String = "09:00"
    var workEndTime: String = "17:00"
    var enableLifestyleIntegration: Bool = true
    var preferredBreakInterval: Int = 90 // minutes
    var enableFinancialInsights: Bool = true
    var theme: AppTheme = .dark
    var language: String = "en"
    
    enum AppTheme: String, CaseIterable, Codable {
        case light = "light"
        case dark = "dark"
        case auto = "auto"
    }
}