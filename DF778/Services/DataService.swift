import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var currentUser: User?
    @Published var tasks: [Task] = []
    
    private init() {
        loadSampleData()
    }
    
    // MARK: - User Management
    func signIn(name: String, email: String) {
        let user = User(name: name, email: email)
        self.currentUser = user
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
    }
    
    func signOut() {
        self.currentUser = nil
        self.tasks = []
        UserDefaults.standard.set(false, forKey: "HasCompletedOnboarding")
    }
    
    func clearAllData() {
        self.tasks = []
        // Keep user logged in but clear all data
    }
    
    // MARK: - Task Management
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    func completeTask(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .completed
        updatedTask.completedAt = Date()
        updateTask(updatedTask)
    }
    
    // MARK: - Analytics
    var completedTasksCount: Int {
        tasks.filter { $0.status == .completed }.count
    }
    
    var pendingTasksCount: Int {
        tasks.filter { $0.status != .completed }.count
    }
    
    var inProgressTasksCount: Int {
        tasks.filter { $0.status == .inProgress }.count
    }
    
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTasksCount) / Double(tasks.count)
    }
    
    var averageTaskTime: Double {
        let completedTasks = tasks.filter { $0.status == .completed && $0.actualHours != nil }
        guard !completedTasks.isEmpty else { return 0 }
        let totalHours = completedTasks.compactMap { $0.actualHours }.reduce(0, +)
        return totalHours / Double(completedTasks.count)
    }
    
    private func loadSampleData() {
        tasks = [
            Task(title: "Design UI mockups", description: "Create wireframes and mockups", status: .completed, priority: .high, estimatedHours: 4.0),
            Task(title: "Implement authentication", description: "Setup user login system", status: .inProgress, priority: .high, estimatedHours: 6.0),
            Task(title: "Write unit tests", description: "Add test coverage", status: .todo, priority: .medium, estimatedHours: 3.0),
            Task(title: "Update documentation", description: "Update API docs", status: .todo, priority: .low, estimatedHours: 2.0),
            Task(title: "Fix critical bug", description: "Resolve crash on startup", status: .completed, priority: .high, estimatedHours: 2.0)
        ]
        
        // Set some completed tasks with actual hours
        if tasks.count > 0 {
            tasks[0].actualHours = 3.5
            tasks[0].completedAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        }
        if tasks.count > 4 {
            tasks[4].actualHours = 1.5
            tasks[4].completedAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        }
    }
}