import Foundation

struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var status: TaskStatus
    var priority: Priority
    var dueDate: Date?
    var estimatedHours: Double
    var actualHours: Double?
    var createdAt: Date
    var completedAt: Date?
    
    enum TaskStatus: String, CaseIterable, Codable {
        case todo = "To Do"
        case inProgress = "In Progress"
        case completed = "Completed"
        
        var color: String {
            switch self {
            case .todo: return "#6B7280"
            case .inProgress: return "#3CC45B"
            case .completed: return "#10B981"
            }
        }
    }
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: String {
            switch self {
            case .low: return "#10B981"
            case .medium: return "#FCC418"
            case .high: return "#EF4444"
            }
        }
    }
    
    init(title: String, description: String = "", status: TaskStatus = .todo, priority: Priority = .medium, dueDate: Date? = nil, estimatedHours: Double = 1.0) {
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.dueDate = dueDate
        self.estimatedHours = estimatedHours
        self.createdAt = Date()
    }
}