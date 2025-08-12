import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var currentUser: User?
    @Published var tasks: [Task] = []
    
    private init() {
        // Start with clean data - no sample data loaded
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
    
    func deleteAccount() {
        // Delete all user data and sign out
        self.currentUser = nil
        self.tasks = []
        UserDefaults.standard.set(false, forKey: "HasCompletedOnboarding")
        // In a real app, you would also delete data from server/database
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
    

}