import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primaryBackground = Color(hex: "#3e4464")
    static let primaryAccent = Color(hex: "#fcc418")
    static let primarySuccess = Color(hex: "#3cc45b")
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color(hex: "#3e4464")
    static let backgroundSecondary = Color(hex: "#2a2f47")
    static let backgroundTertiary = Color(hex: "#1a1e2e")
    static let cardBackground = Color(hex: "#4a5073")
    
    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#b8bcc8")
    static let textTertiary = Color(hex: "#9ca3af")
    static let textAccent = Color(hex: "#fcc418")
    
    // MARK: - Accent Colors
    static let accentYellow = Color(hex: "#fcc418")
    static let accentGreen = Color(hex: "#3cc45b")
    static let accentBlue = Color(hex: "#3b82f6")
    static let accentPurple = Color(hex: "#8b5cf6")
    static let accentRed = Color(hex: "#ef4444")
    static let accentOrange = Color(hex: "#f59e0b")
    
    // MARK: - Status Colors
    static let statusSuccess = Color(hex: "#10b981")
    static let statusWarning = Color(hex: "#f59e0b")
    static let statusError = Color(hex: "#ef4444")
    static let statusInfo = Color(hex: "#3b82f6")
    
    // MARK: - Task Priority Colors
    static let priorityLow = Color(hex: "#10b981")
    static let priorityMedium = Color(hex: "#fcc418")
    static let priorityHigh = Color(hex: "#f59e0b")
    static let priorityUrgent = Color(hex: "#ef4444")
    
    // MARK: - Task Status Colors
    static let statusTodo = Color(hex: "#6b7280")
    static let statusInProgress = Color(hex: "#3cc45b")
    static let statusReview = Color(hex: "#fcc418")
    static let statusCompleted = Color(hex: "#10b981")
    static let statusBlocked = Color(hex: "#ef4444")
    static let statusCancelled = Color(hex: "#9ca3af")
    
    // MARK: - Project Status Colors
    static let projectPlanning = Color(hex: "#6b7280")
    static let projectActive = Color(hex: "#3cc45b")
    static let projectOnHold = Color(hex: "#fcc418")
    static let projectCompleted = Color(hex: "#10b981")
    static let projectCancelled = Color(hex: "#ef4444")
    
    // MARK: - Gradient Colors
    static let gradientPrimary = LinearGradient(
        colors: [Color(hex: "#3e4464"), Color(hex: "#2a2f47")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientAccent = LinearGradient(
        colors: [Color(hex: "#fcc418"), Color(hex: "#f59e0b")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientSuccess = LinearGradient(
        colors: [Color(hex: "#3cc45b"), Color(hex: "#10b981")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientCard = LinearGradient(
        colors: [Color(hex: "#4a5073"), Color(hex: "#3e4464")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Utility
    static let divider = Color(hex: "#374151")
    static let shadow = Color.black.opacity(0.1)
    static let overlay = Color.black.opacity(0.3)
    
    // MARK: - Chart Colors
    static let chartBlue = Color(hex: "#3b82f6")
    static let chartGreen = Color(hex: "#10b981")
    static let chartYellow = Color(hex: "#fcc418")
    static let chartRed = Color(hex: "#ef4444")
    static let chartPurple = Color(hex: "#8b5cf6")
    static let chartOrange = Color(hex: "#f59e0b")
    
    static var chartColors: [Color] {
        [.chartBlue, .chartGreen, .chartYellow, .chartRed, .chartPurple, .chartOrange]
    }
}

// MARK: - Color Extension for Hex Support

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

// MARK: - Dynamic Colors for Task Status

extension Task.TaskStatus {
    var color: Color {
        switch self {
        case .todo: return .statusTodo
        case .inProgress: return .statusInProgress
        case .review: return .statusReview
        case .completed: return .statusCompleted
        case .blocked: return .statusBlocked
        case .cancelled: return .statusCancelled
        }
    }
}

// MARK: - Dynamic Colors for Task Priority

extension Task.TaskPriority {
    var color: Color {
        switch self {
        case .low: return .priorityLow
        case .medium: return .priorityMedium
        case .high: return .priorityHigh
        case .urgent: return .priorityUrgent
        }
    }
}

// MARK: - Dynamic Colors for Project Status

extension Project.ProjectStatus {
    var color: Color {
        switch self {
        case .planning: return .projectPlanning
        case .active: return .projectActive
        case .onHold: return .projectOnHold
        case .completed: return .projectCompleted
        case .cancelled: return .projectCancelled
        }
    }
}