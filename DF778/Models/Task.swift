import Foundation

struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var status: TaskStatus
    var priority: TaskPriority
    var assignedTo: UUID? // User ID
    var projectId: UUID?
    var dueDate: Date?
    var estimatedHours: Double?
    var actualHours: Double?
    var tags: [String]
    var attachments: [TaskAttachment]
    var comments: [TaskComment]
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    
    // Financial tracking
    var budget: Double?
    var actualCost: Double?
    
    enum TaskStatus: String, CaseIterable, Codable {
        case todo = "todo"
        case inProgress = "in_progress"
        case review = "review"
        case completed = "completed"
        case blocked = "blocked"
        case cancelled = "cancelled"
        
        var displayName: String {
            switch self {
            case .todo: return "To Do"
            case .inProgress: return "In Progress"
            case .review: return "Review"
            case .completed: return "Completed"
            case .blocked: return "Blocked"
            case .cancelled: return "Cancelled"
            }
        }
        
        var hexColor: String {
            switch self {
            case .todo: return "#6B7280"
            case .inProgress: return "#3CC45B"
            case .review: return "#FCC418"
            case .completed: return "#10B981"
            case .blocked: return "#EF4444"
            case .cancelled: return "#9CA3AF"
            }
        }
    }
    
    enum TaskPriority: String, CaseIterable, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
        
        var displayName: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            case .urgent: return "Urgent"
            }
        }
        
        var hexColor: String {
            switch self {
            case .low: return "#10B981"
            case .medium: return "#FCC418"
            case .high: return "#F59E0B"
            case .urgent: return "#EF4444"
            }
        }
    }
}

struct TaskAttachment: Identifiable, Codable {
    let id = UUID()
    var name: String
    var url: String
    var type: AttachmentType
    var size: Int64
    var uploadedAt: Date
    var uploadedBy: UUID // User ID
    
    enum AttachmentType: String, CaseIterable, Codable {
        case document = "document"
        case image = "image"
        case video = "video"
        case audio = "audio"
        case archive = "archive"
        case other = "other"
    }
}

struct TaskComment: Identifiable, Codable {
    let id = UUID()
    var content: String
    var authorId: UUID
    var createdAt: Date
    var updatedAt: Date?
    var mentions: [UUID] // User IDs
}