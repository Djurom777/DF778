import Foundation

struct Project: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var status: ProjectStatus
    var ownerId: UUID // User ID
    var teamMembers: [UUID] // User IDs
    var startDate: Date
    var endDate: Date?
    var budget: Double?
    var actualCost: Double?
    var progress: Double // 0.0 to 1.0
    var tags: [String]
    var color: String
    var isArchived: Bool
    var createdAt: Date
    var updatedAt: Date
    
    // Analytics data
    var totalTasks: Int
    var completedTasks: Int
    var overdueTasks: Int
    var averageTaskCompletionTime: Double? // in hours
    
    enum ProjectStatus: String, CaseIterable, Codable {
        case planning = "planning"
        case active = "active"
        case onHold = "on_hold"
        case completed = "completed"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .planning: return "Planning"
            case .active: return "Active"
            case .onHold: return "On Hold"
            case .completed: return "Completed"
            case .cancelled: return "Cancelled"
            }
        }
        
        var hexColor: String {
            switch self {
            case .planning: return "#6B7280"
            case .active: return "#3CC45B"
            case .onHold: return "#FCC418"
            case .completed: return "#10B981"
            case .cancelled: return "#EF4444"
            }
        }
    }
    
    var completionPercentage: Int {
        guard totalTasks > 0 else { return 0 }
        return Int((Double(completedTasks) / Double(totalTasks)) * 100)
    }
    
    var budgetUtilization: Double {
        guard let budget = budget, budget > 0 else { return 0 }
        return (actualCost ?? 0) / budget
    }
}

struct ProjectMilestone: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var dueDate: Date
    var isCompleted: Bool
    var completedAt: Date?
    var projectId: UUID
    var createdAt: Date
}