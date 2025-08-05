import Foundation
import Combine

class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var productivityMetrics: ProductivityMetrics = ProductivityMetrics()
    @Published var financialInsights: FinancialInsights = FinancialInsights()
    @Published var teamPerformance: TeamPerformance = TeamPerformance()
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupDataObservers()
    }
    
    private func setupDataObservers() {
        // Observe data changes and update analytics
        dataService.$tasks
            .combineLatest(dataService.$projects, dataService.$users)
            .sink { [weak self] tasks, projects, users in
                self?.updateAnalytics(tasks: tasks, projects: projects, users: users)
            }
            .store(in: &cancellables)
    }
    
    private func updateAnalytics(tasks: [Task], projects: [Project], users: [User]) {
        updateProductivityMetrics(tasks: tasks)
        updateFinancialInsights(projects: projects, tasks: tasks)
        updateTeamPerformance(tasks: tasks, users: users)
    }
    
    // MARK: - Productivity Analytics
    
    private func updateProductivityMetrics(tasks: [Task]) {
        let completedTasks = tasks.filter { $0.status == .completed }
        let inProgressTasks = tasks.filter { $0.status == .inProgress }
        let overdueTasks = tasks.filter { 
            guard let dueDate = $0.dueDate else { return false }
            return dueDate < Date() && $0.status != .completed
        }
        
        let averageCompletionTime = calculateAverageCompletionTime(from: completedTasks)
        let tasksCompletedThisWeek = completedTasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return Calendar.current.isDate(completedAt, equalTo: Date(), toGranularity: .weekOfYear)
        }.count
        
        let tasksCompletedLastWeek = completedTasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            return Calendar.current.isDate(completedAt, equalTo: lastWeek, toGranularity: .weekOfYear)
        }.count
        
        productivityMetrics = ProductivityMetrics(
            totalTasks: tasks.count,
            completedTasks: completedTasks.count,
            inProgressTasks: inProgressTasks.count,
            overdueTasks: overdueTasks.count,
            averageCompletionTime: averageCompletionTime,
            tasksCompletedThisWeek: tasksCompletedThisWeek,
            tasksCompletedLastWeek: tasksCompletedLastWeek,
            productivityTrend: calculateProductivityTrend(thisWeek: tasksCompletedThisWeek, lastWeek: tasksCompletedLastWeek)
        )
    }
    
    private func calculateAverageCompletionTime(from tasks: [Task]) -> Double {
        let tasksWithTime = tasks.compactMap { task -> Double? in
            guard let completedAt = task.completedAt else { return nil }
            return completedAt.timeIntervalSince(task.createdAt) / 3600 // Convert to hours
        }
        
        guard !tasksWithTime.isEmpty else { return 0 }
        return tasksWithTime.reduce(0, +) / Double(tasksWithTime.count)
    }
    
    private func calculateProductivityTrend(thisWeek: Int, lastWeek: Int) -> Double {
        guard lastWeek > 0 else { return thisWeek > 0 ? 100 : 0 }
        return ((Double(thisWeek) - Double(lastWeek)) / Double(lastWeek)) * 100
    }
    
    // MARK: - Financial Analytics
    
    private func updateFinancialInsights(projects: [Project], tasks: [Task]) {
        let totalBudget = projects.compactMap { $0.budget }.reduce(0, +)
        let totalSpent = projects.compactMap { $0.actualCost }.reduce(0, +)
        let projectsOverBudget = projects.filter { project in
            guard let budget = project.budget, let cost = project.actualCost else { return false }
            return cost > budget
        }.count
        
        let budgetUtilization = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0
        let costPerTask = tasks.count > 0 ? totalSpent / Double(tasks.count) : 0
        
        let projectedSpend = calculateProjectedSpend(projects: projects)
        
        financialInsights = FinancialInsights(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            remainingBudget: totalBudget - totalSpent,
            budgetUtilization: budgetUtilization,
            projectsOverBudget: projectsOverBudget,
            costPerTask: costPerTask,
            projectedSpend: projectedSpend,
            savingsOpportunities: identifySavingsOpportunities(projects: projects)
        )
    }
    
    private func calculateProjectedSpend(projects: [Project]) -> Double {
        return projects.compactMap { project -> Double? in
            guard let budget = project.budget,
                  project.status == .active,
                  project.progress > 0 else { return nil }
            
            let currentCost = project.actualCost ?? 0
            return currentCost / project.progress // Projected total cost based on current progress
        }.reduce(0, +)
    }
    
    private func identifySavingsOpportunities(projects: [Project]) -> [String] {
        var opportunities: [String] = []
        
        for project in projects {
            guard let budget = project.budget,
                  let actualCost = project.actualCost else { continue }
            
            if actualCost > budget * 0.9 {
                opportunities.append("Project '\(project.name)' is approaching budget limit")
            }
            
            if project.progress < 0.5 && actualCost > budget * 0.6 {
                opportunities.append("Consider re-evaluating scope for '\(project.name)'")
            }
        }
        
        return opportunities
    }
    
    // MARK: - Team Performance Analytics
    
    private func updateTeamPerformance(tasks: [Task], users: [User]) {
        let userPerformance = users.map { user in
            let userTasks = tasks.filter { $0.assignedTo == user.id }
            let completedTasks = userTasks.filter { $0.status == .completed }
            let averageTaskTime = calculateAverageCompletionTime(from: completedTasks)
            
            return UserPerformance(
                userId: user.id,
                userName: user.name,
                totalTasks: userTasks.count,
                completedTasks: completedTasks.count,
                averageCompletionTime: averageTaskTime,
                efficiency: userTasks.count > 0 ? Double(completedTasks.count) / Double(userTasks.count) : 0
            )
        }
        
        let collaborationScore = calculateCollaborationScore(tasks: tasks, users: users)
        let teamVelocity = calculateTeamVelocity(tasks: tasks)
        
        teamPerformance = TeamPerformance(
            totalMembers: users.count,
            activeMembers: users.filter { user in
                tasks.contains { $0.assignedTo == user.id && $0.status == .inProgress }
            }.count,
            userPerformance: userPerformance,
            collaborationScore: collaborationScore,
            teamVelocity: teamVelocity,
            bottlenecks: identifyBottlenecks(tasks: tasks, users: users)
        )
    }
    
    private func calculateCollaborationScore(tasks: [Task], users: [User]) -> Double {
        let tasksWithComments = tasks.filter { !$0.comments.isEmpty }
        let tasksWithMultipleAssignees = tasks.filter { task in
            task.comments.map { $0.authorId }.uniqued().count > 1
        }
        
        let totalTasks = tasks.count
        guard totalTasks > 0 else { return 0 }
        
        let commentScore = Double(tasksWithComments.count) / Double(totalTasks)
        let collaborationScore = Double(tasksWithMultipleAssignees.count) / Double(totalTasks)
        
        return (commentScore + collaborationScore) / 2 * 100
    }
    
    private func calculateTeamVelocity(tasks: [Task]) -> Double {
        let completedTasksThisWeek = tasks.filter { task in
            guard let completedAt = task.completedAt else { return false }
            return Calendar.current.isDate(completedAt, equalTo: Date(), toGranularity: .weekOfYear)
        }
        
        let totalHours = completedTasksThisWeek.compactMap { $0.estimatedHours }.reduce(0, +)
        return totalHours
    }
    
    private func identifyBottlenecks(tasks: [Task], users: [User]) -> [String] {
        var bottlenecks: [String] = []
        
        // Identify users with too many in-progress tasks
        for user in users {
            let inProgressTasks = tasks.filter { $0.assignedTo == user.id && $0.status == .inProgress }
            if inProgressTasks.count > 5 {
                bottlenecks.append("\(user.name) has \(inProgressTasks.count) tasks in progress")
            }
        }
        
        // Identify blocked tasks
        let blockedTasks = tasks.filter { $0.status == .blocked }
        if blockedTasks.count > 0 {
            bottlenecks.append("\(blockedTasks.count) tasks are blocked")
        }
        
        // Identify overdue tasks
        let overdueTasks = tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && task.status != .completed
        }
        if overdueTasks.count > 0 {
            bottlenecks.append("\(overdueTasks.count) tasks are overdue")
        }
        
        return bottlenecks
    }
    
    // MARK: - Predictive Analytics
    
    func predictProjectCompletion(for project: Project) -> Date? {
        guard project.progress > 0 else { return nil }
        
        let daysSinceStart = Date().timeIntervalSince(project.startDate) / (24 * 3600)
        let estimatedTotalDays = daysSinceStart / project.progress
        let remainingDays = estimatedTotalDays - daysSinceStart
        
        return Calendar.current.date(byAdding: .day, value: Int(remainingDays), to: Date())
    }
    
    func suggestWorkloadRebalancing() -> [WorkloadSuggestion] {
        let users = dataService.users
        let tasks = dataService.tasks
        var suggestions: [WorkloadSuggestion] = []
        
        for user in users {
            let userTasks = tasks.filter { $0.assignedTo == user.id && $0.status != .completed }
            
            if userTasks.count > 7 {
                suggestions.append(WorkloadSuggestion(
                    type: .redistribute,
                    userId: user.id,
                    userName: user.name,
                    message: "Consider redistributing some of \(user.name)'s \(userTasks.count) active tasks"
                ))
            } else if userTasks.count < 2 {
                suggestions.append(WorkloadSuggestion(
                    type: .assignMore,
                    userId: user.id,
                    userName: user.name,
                    message: "\(user.name) has capacity for more tasks"
                ))
            }
        }
        
        return suggestions
    }
}

// MARK: - Data Models

struct ProductivityMetrics {
    var totalTasks: Int = 0
    var completedTasks: Int = 0
    var inProgressTasks: Int = 0
    var overdueTasks: Int = 0
    var averageCompletionTime: Double = 0 // in hours
    var tasksCompletedThisWeek: Int = 0
    var tasksCompletedLastWeek: Int = 0
    var productivityTrend: Double = 0 // percentage change
    
    var completionRate: Double {
        totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) * 100 : 0
    }
}

struct FinancialInsights {
    var totalBudget: Double = 0
    var totalSpent: Double = 0
    var remainingBudget: Double = 0
    var budgetUtilization: Double = 0 // percentage
    var projectsOverBudget: Int = 0
    var costPerTask: Double = 0
    var projectedSpend: Double = 0
    var savingsOpportunities: [String] = []
}

struct TeamPerformance {
    var totalMembers: Int = 0
    var activeMembers: Int = 0
    var userPerformance: [UserPerformance] = []
    var collaborationScore: Double = 0 // 0-100
    var teamVelocity: Double = 0 // hours per week
    var bottlenecks: [String] = []
}

struct UserPerformance {
    let userId: UUID
    let userName: String
    var totalTasks: Int
    var completedTasks: Int
    var averageCompletionTime: Double
    var efficiency: Double // 0-1
}

struct WorkloadSuggestion {
    enum SuggestionType {
        case redistribute
        case assignMore
        case takeBreak
    }
    
    let type: SuggestionType
    let userId: UUID
    let userName: String
    let message: String
}

// MARK: - Array Extension

extension Array where Element: Hashable {
    func uniqued() -> Array {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}