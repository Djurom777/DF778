import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var selectedTab: DashboardTab = .overview
    @Published var recentTasks: [Task] = []
    @Published var activeProjects: [Project] = []
    @Published var upcomingDeadlines: [Task] = []
    @Published var todayTasks: [Task] = []
    @Published var productivityMetrics: ProductivityMetrics = ProductivityMetrics()
    @Published var financialOverview: FinancialInsights = FinancialInsights()
    @Published var isLoading: Bool = false
    @Published var showNotifications: Bool = false
    @Published var notifications: [DashboardNotification] = []
    
    private let dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum DashboardTab: String, CaseIterable {
        case overview = "overview"
        case tasks = "tasks"
        case projects = "projects"
        case analytics = "analytics"
        case team = "team"
        
        var title: String {
            switch self {
            case .overview: return "Overview"
            case .tasks: return "Tasks"
            case .projects: return "Projects"
            case .analytics: return "Analytics"
            case .team: return "Team"
            }
        }
        
        var iconName: String {
            switch self {
            case .overview: return "house.fill"
            case .tasks: return "checklist"
            case .projects: return "folder.fill"
            case .analytics: return "chart.bar.fill"
            case .team: return "person.3.fill"
            }
        }
    }
    
    init() {
        setupDataObservers()
        loadDashboardData()
        generateNotifications()
    }
    
    private func setupDataObservers() {
        // Observe data changes and update dashboard
        dataService.$tasks
            .combineLatest(dataService.$projects)
            .sink { [weak self] tasks, projects in
                self?.updateDashboardData(tasks: tasks, projects: projects)
            }
            .store(in: &cancellables)
        
        // Observe analytics updates
        analyticsService.$productivityMetrics
            .sink { [weak self] metrics in
                self?.productivityMetrics = metrics
            }
            .store(in: &cancellables)
        
        analyticsService.$financialInsights
            .sink { [weak self] insights in
                self?.financialOverview = insights
            }
            .store(in: &cancellables)
    }
    
    private func loadDashboardData() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    private func updateDashboardData(tasks: [Task], projects: [Project]) {
        updateRecentTasks(tasks)
        updateActiveProjects(projects)
        updateUpcomingDeadlines(tasks)
        updateTodayTasks(tasks)
    }
    
    // MARK: - Data Updates
    
    private func updateRecentTasks(_ tasks: [Task]) {
        recentTasks = tasks
            .filter { $0.assignedTo == dataService.currentUser?.id }
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(5)
            .map { $0 }
    }
    
    private func updateActiveProjects(_ projects: [Project]) {
        activeProjects = projects
            .filter { $0.status == .active && !$0.isArchived }
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(6)
            .map { $0 }
    }
    
    private func updateUpcomingDeadlines(_ tasks: [Task]) {
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
        
        upcomingDeadlines = tasks
            .filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate <= nextWeek && task.status != .completed
            }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .prefix(5)
            .map { $0 }
    }
    
    private func updateTodayTasks(_ tasks: [Task]) {
        let calendar = Calendar.current
        
        todayTasks = tasks
            .filter { task in
                guard let dueDate = task.dueDate else { return false }
                return calendar.isDateInToday(dueDate) && task.status != .completed
            }
            .sorted { ($0.priority.rawValue) > ($1.priority.rawValue) }
    }
    
    // MARK: - Quick Actions
    
    func createQuickTask(title: String) -> Task {
        return dataService.createTask(title: title, description: "")
    }
    
    func markTaskComplete(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .completed
        updatedTask.completedAt = Date()
        dataService.updateTask(updatedTask)
        
        // Send completion notification
        addNotification(
            title: "Task Completed!",
            message: "Great job completing '\(task.title)'",
            type: .success
        )
    }
    
    func startTask(_ task: Task) {
        var updatedTask = task
        updatedTask.status = .inProgress
        dataService.updateTask(updatedTask)
        
        // Schedule reminder for break if lifestyle integration is enabled
        if dataService.currentUser?.preferences.enableLifestyleIntegration == true {
            notificationService.scheduleBreakReminder()
        }
    }
    
    func createQuickProject(name: String) -> Project {
        return dataService.createProject(name: name, description: "")
    }
    
    // MARK: - Notifications
    
    private func generateNotifications() {
        notifications = []
        
        // Check for overdue tasks
        let overdueTasks = dataService.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && task.status != .completed
        }
        
        if !overdueTasks.isEmpty {
            addNotification(
                title: "Overdue Tasks",
                message: "You have \(overdueTasks.count) overdue task(s)",
                type: .warning
            )
        }
        
        // Check for budget alerts
        let projectsOverBudget = dataService.projects.filter { project in
            guard let budget = project.budget, let cost = project.actualCost else { return false }
            return cost > budget * 0.9
        }
        
        if !projectsOverBudget.isEmpty {
            addNotification(
                title: "Budget Alert",
                message: "\(projectsOverBudget.count) project(s) approaching budget limit",
                type: .warning
            )
        }
        
        // Check for upcoming deadlines
        if !upcomingDeadlines.isEmpty {
            addNotification(
                title: "Upcoming Deadlines",
                message: "\(upcomingDeadlines.count) task(s) due this week",
                type: .info
            )
        }
        
        // Productivity insights
        if productivityMetrics.productivityTrend > 20 {
            addNotification(
                title: "Great Progress!",
                message: "Your productivity is up \(Int(productivityMetrics.productivityTrend))% this week",
                type: .success
            )
        }
    }
    
    private func addNotification(title: String, message: String, type: DashboardNotification.NotificationType) {
        let notification = DashboardNotification(
            title: title,
            message: message,
            type: type,
            timestamp: Date()
        )
        notifications.append(notification)
    }
    
    func dismissNotification(_ notification: DashboardNotification) {
        notifications.removeAll { $0.id == notification.id }
    }
    
    func dismissAllNotifications() {
        notifications.removeAll()
    }
    
    // MARK: - Data Refresh
    
    func refreshData() {
        isLoading = true
        
        // Simulate data refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.loadDashboardData()
            self.generateNotifications()
            self.isLoading = false
        }
    }
    
    // MARK: - Tab Management
    
    func selectTab(_ tab: DashboardTab) {
        selectedTab = tab
    }
    
    // MARK: - Computed Properties
    
    var taskCompletionRate: Double {
        let totalTasks = recentTasks.count
        guard totalTasks > 0 else { return 0 }
        let completedTasks = recentTasks.filter { $0.status == .completed }.count
        return Double(completedTasks) / Double(totalTasks) * 100
    }
    
    var activeProjectsCount: Int {
        return activeProjects.count
    }
    
    var todayTasksCount: Int {
        return todayTasks.count
    }
    
    var weeklyGoalProgress: Double {
        // Calculate progress towards weekly task completion goal
        let weeklyGoal = 10 // Could be user-configurable
        let completedThisWeek = productivityMetrics.tasksCompletedThisWeek
        return min(Double(completedThisWeek) / Double(weeklyGoal), 1.0)
    }
    
    var hasUnreadNotifications: Bool {
        return !notifications.isEmpty
    }
}

// MARK: - Supporting Types

struct DashboardNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    
    enum NotificationType {
        case success, warning, info, error
        
        var color: String {
            switch self {
            case .success: return "#10B981"
            case .warning: return "#F59E0B"
            case .info: return "#3B82F6"
            case .error: return "#EF4444"
            }
        }
        
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            case .error: return "xmark.circle.fill"
            }
        }
    }
}