import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var users: [User] = []
    @Published var tasks: [Task] = []
    @Published var projects: [Project] = []
    @Published var currentUser: User?
    
    private let userDefaults = UserDefaults.standard
    private let usersKey = "TaskFlow_Users"
    private let tasksKey = "TaskFlow_Tasks"
    private let projectsKey = "TaskFlow_Projects"
    private let currentUserKey = "TaskFlow_CurrentUser"
    
    private init() {
        loadData()
        setupDemoData()
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        loadUsers()
        loadTasks()
        loadProjects()
        loadCurrentUser()
    }
    
    private func loadUsers() {
        if let data = userDefaults.data(forKey: usersKey),
           let decoded = try? JSONDecoder().decode([User].self, from: data) {
            users = decoded
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func loadProjects() {
        if let data = userDefaults.data(forKey: projectsKey),
           let decoded = try? JSONDecoder().decode([Project].self, from: data) {
            projects = decoded
        }
    }
    
    private func loadCurrentUser() {
        if let data = userDefaults.data(forKey: currentUserKey),
           let decoded = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = decoded
        }
    }
    
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            userDefaults.set(encoded, forKey: usersKey)
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func saveProjects() {
        if let encoded = try? JSONEncoder().encode(projects) {
            userDefaults.set(encoded, forKey: projectsKey)
        }
    }
    
    private func saveCurrentUser() {
        if let user = currentUser,
           let encoded = try? JSONEncoder().encode(user) {
            userDefaults.set(encoded, forKey: currentUserKey)
        }
    }
    
    // MARK: - User Management
    
    func createUser(name: String, email: String, role: User.UserRole) -> User {
        let user = User(
            name: name,
            email: email,
            role: role,
            preferences: UserPreferences(),
            createdAt: Date(),
            lastActiveAt: Date()
        )
        users.append(user)
        saveUsers()
        return user
    }
    
    func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveUsers()
            
            if currentUser?.id == user.id {
                currentUser = user
                saveCurrentUser()
            }
        }
    }
    
    func setCurrentUser(_ user: User) {
        currentUser = user
        saveCurrentUser()
    }
    
    // MARK: - Task Management
    
    func createTask(title: String, description: String, projectId: UUID? = nil) -> Task {
        let task = Task(
            title: title,
            description: description,
            status: .todo,
            priority: .medium,
            assignedTo: currentUser?.id,
            projectId: projectId,
            tags: [],
            attachments: [],
            comments: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        tasks.append(task)
        saveTasks()
        updateProjectStats(for: projectId)
        return task
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            var updatedTask = task
            updatedTask.updatedAt = Date()
            tasks[index] = updatedTask
            saveTasks()
            updateProjectStats(for: task.projectId)
        }
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        updateProjectStats(for: task.projectId)
    }
    
    func getTasksForProject(_ projectId: UUID) -> [Task] {
        return tasks.filter { $0.projectId == projectId }
    }
    
    func getTasksForUser(_ userId: UUID) -> [Task] {
        return tasks.filter { $0.assignedTo == userId }
    }
    
    // MARK: - Project Management
    
    func createProject(name: String, description: String, budget: Double? = nil) -> Project {
        let project = Project(
            name: name,
            description: description,
            status: .planning,
            ownerId: currentUser?.id ?? UUID(),
            teamMembers: currentUser?.id != nil ? [currentUser!.id] : [],
            startDate: Date(),
            budget: budget,
            progress: 0.0,
            tags: [],
            color: "#3CC45B",
            isArchived: false,
            createdAt: Date(),
            updatedAt: Date(),
            totalTasks: 0,
            completedTasks: 0,
            overdueTasks: 0
        )
        projects.append(project)
        saveProjects()
        return project
    }
    
    func updateProject(_ project: Project) {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            var updatedProject = project
            updatedProject.updatedAt = Date()
            projects[index] = updatedProject
            saveProjects()
        }
    }
    
    func deleteProject(_ project: Project) {
        // Delete all tasks associated with the project
        tasks.removeAll { $0.projectId == project.id }
        saveTasks()
        
        // Delete the project
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    private func updateProjectStats(for projectId: UUID?) {
        guard let projectId = projectId,
              let index = projects.firstIndex(where: { $0.id == projectId }) else { return }
        
        let projectTasks = getTasksForProject(projectId)
        let completedTasks = projectTasks.filter { $0.status == .completed }
        let overdueTasks = projectTasks.filter { 
            guard let dueDate = $0.dueDate else { return false }
            return dueDate < Date() && $0.status != .completed
        }
        
        projects[index].totalTasks = projectTasks.count
        projects[index].completedTasks = completedTasks.count
        projects[index].overdueTasks = overdueTasks.count
        projects[index].progress = projectTasks.isEmpty ? 0.0 : Double(completedTasks.count) / Double(projectTasks.count)
        
        saveProjects()
    }
    
    // MARK: - Demo Data Setup
    
    private func setupDemoData() {
        if users.isEmpty && currentUser == nil {
            let demoUser = createUser(name: "Demo User", email: "demo@taskflow.com", role: .admin)
            setCurrentUser(demoUser)
            
            // Create demo projects
            let project1 = createProject(name: "Mobile App Development", description: "Building TaskFlow Nexus iOS app", budget: 50000)
            let project2 = createProject(name: "Marketing Campaign", description: "Q4 marketing strategy implementation", budget: 25000)
            
            // Create demo tasks
            _ = createTask(title: "Design user interface", description: "Create wireframes and mockups for the main screens", projectId: project1.id)
            _ = createTask(title: "Implement authentication", description: "Set up user login and registration system", projectId: project1.id)
            _ = createTask(title: "Setup CI/CD pipeline", description: "Configure automated testing and deployment", projectId: project1.id)
            
            var task = createTask(title: "Social media strategy", description: "Develop content calendar for social platforms", projectId: project2.id)
            task.status = .completed
            task.completedAt = Date()
            updateTask(task)
        }
    }
}