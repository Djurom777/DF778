import Foundation
import Combine

class ProjectViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var filteredProjects: [Project] = []
    @Published var selectedProject: Project?
    @Published var showingProjectDetail: Bool = false
    @Published var showingCreateProject: Bool = false
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var selectedFilter: ProjectFilter = .all
    @Published var selectedSort: ProjectSort = .dateCreated
    
    // Project creation/editing
    @Published var projectName: String = ""
    @Published var projectDescription: String = ""
    @Published var projectBudget: String = ""
    @Published var hasBudget: Bool = false
    @Published var projectStartDate: Date = Date()
    @Published var projectEndDate: Date = Date()
    @Published var hasEndDate: Bool = false
    @Published var projectColor: String = "#3CC45B"
    @Published var projectTags: [String] = []
    @Published var newTag: String = ""
    @Published var selectedTeamMembers: [User] = []
    
    private let dataService = DataService.shared
    private let analyticsService = AnalyticsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum ProjectFilter: String, CaseIterable {
        case all = "all"
        case active = "active"
        case planning = "planning"
        case completed = "completed"
        case overBudget = "over_budget"
        case myProjects = "my_projects"
        
        var displayName: String {
            switch self {
            case .all: return "All Projects"
            case .active: return "Active"
            case .planning: return "Planning"
            case .completed: return "Completed"
            case .overBudget: return "Over Budget"
            case .myProjects: return "My Projects"
            }
        }
        
        var iconName: String {
            switch self {
            case .all: return "folder.fill"
            case .active: return "play.circle.fill"
            case .planning: return "clock.fill"
            case .completed: return "checkmark.circle.fill"
            case .overBudget: return "exclamationmark.triangle.fill"
            case .myProjects: return "person.circle.fill"
            }
        }
    }
    
    enum ProjectSort: String, CaseIterable {
        case dateCreated = "date_created"
        case name = "name"
        case progress = "progress"
        case budget = "budget"
        case endDate = "end_date"
        
        var displayName: String {
            switch self {
            case .dateCreated: return "Date Created"
            case .name: return "Name"
            case .progress: return "Progress"
            case .budget: return "Budget"
            case .endDate: return "End Date"
            }
        }
    }
    
    init() {
        setupDataObservers()
        loadProjects()
    }
    
    private func setupDataObservers() {
        // Observe data service changes
        dataService.$projects
            .sink { [weak self] projects in
                self?.projects = projects
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
        
        // Observe search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
        
        // Observe filter changes
        Publishers.CombineLatest($selectedFilter, $selectedSort)
            .sink { [weak self] _, _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }
    
    private func loadProjects() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
        }
    }
    
    // MARK: - Filtering and Sorting
    
    private func applyFiltersAndSort() {
        var filtered = projects
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { project in
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.description.localizedCaseInsensitiveContains(searchText) ||
                project.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            filtered = filtered.filter { !$0.isArchived }
        case .active:
            filtered = filtered.filter { $0.status == .active && !$0.isArchived }
        case .planning:
            filtered = filtered.filter { $0.status == .planning && !$0.isArchived }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .overBudget:
            filtered = filtered.filter { project in
                guard let budget = project.budget, let cost = project.actualCost else { return false }
                return cost > budget && !project.isArchived
            }
        case .myProjects:
            filtered = filtered.filter { project in
                let isOwner = project.ownerId == dataService.currentUser?.id
                let isMember = project.teamMembers.contains(dataService.currentUser?.id ?? UUID())
                return (isOwner || isMember) && !project.isArchived
            }
        }
        
        // Apply sorting
        switch selectedSort {
        case .dateCreated:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .name:
            filtered.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .progress:
            filtered.sort { $0.progress > $1.progress }
        case .budget:
            filtered.sort { ($0.budget ?? 0) > ($1.budget ?? 0) }
        case .endDate:
            filtered.sort { project1, project2 in
                let date1 = project1.endDate ?? Date.distantFuture
                let date2 = project2.endDate ?? Date.distantFuture
                return date1 < date2
            }
        }
        
        filteredProjects = filtered
    }
    
    // MARK: - Project Management
    
    func createProject() {
        let project = dataService.createProject(
            name: projectName,
            description: projectDescription,
            budget: hasBudget ? Double(projectBudget) : nil
        )
        
        var updatedProject = project
        updatedProject.startDate = projectStartDate
        updatedProject.endDate = hasEndDate ? projectEndDate : nil
        updatedProject.color = projectColor
        updatedProject.tags = projectTags
        updatedProject.teamMembers = selectedTeamMembers.map { $0.id }
        
        dataService.updateProject(updatedProject)
        resetProjectForm()
        showingCreateProject = false
    }
    
    func updateProject(_ project: Project) {
        dataService.updateProject(project)
    }
    
    func deleteProject(_ project: Project) {
        dataService.deleteProject(project)
        if selectedProject?.id == project.id {
            selectedProject = nil
            showingProjectDetail = false
        }
    }
    
    func archiveProject(_ project: Project) {
        var updatedProject = project
        updatedProject.isArchived = true
        dataService.updateProject(updatedProject)
    }
    
    func unarchiveProject(_ project: Project) {
        var updatedProject = project
        updatedProject.isArchived = false
        dataService.updateProject(updatedProject)
    }
    
    func duplicateProject(_ project: Project) {
        let duplicatedProject = dataService.createProject(
            name: "\(project.name) (Copy)",
            description: project.description,
            budget: project.budget
        )
        
        var updatedProject = duplicatedProject
        updatedProject.color = project.color
        updatedProject.tags = project.tags
        updatedProject.teamMembers = project.teamMembers
        
        dataService.updateProject(updatedProject)
    }
    
    func updateProjectStatus(_ project: Project, status: Project.ProjectStatus) {
        var updatedProject = project
        updatedProject.status = status
        dataService.updateProject(updatedProject)
    }
    
    // MARK: - Team Management
    
    func addTeamMember(_ user: User, to project: Project) {
        var updatedProject = project
        if !updatedProject.teamMembers.contains(user.id) {
            updatedProject.teamMembers.append(user.id)
            dataService.updateProject(updatedProject)
        }
    }
    
    func removeTeamMember(_ user: User, from project: Project) {
        var updatedProject = project
        updatedProject.teamMembers.removeAll { $0 == user.id }
        dataService.updateProject(updatedProject)
    }
    
    // MARK: - Financial Management
    
    func updateProjectBudget(_ project: Project, budget: Double) {
        var updatedProject = project
        updatedProject.budget = budget
        dataService.updateProject(updatedProject)
    }
    
    func updateProjectCost(_ project: Project, cost: Double) {
        var updatedProject = project
        updatedProject.actualCost = cost
        dataService.updateProject(updatedProject)
    }
    
    func getProjectTasks(_ project: Project) -> [Task] {
        return dataService.getTasksForProject(project.id)
    }
    
    // MARK: - Project Selection
    
    func selectProject(_ project: Project) {
        selectedProject = project
        showingProjectDetail = true
    }
    
    func deselectProject() {
        selectedProject = nil
        showingProjectDetail = false
    }
    
    // MARK: - Form Management
    
    func resetProjectForm() {
        projectName = ""
        projectDescription = ""
        projectBudget = ""
        hasBudget = false
        projectStartDate = Date()
        projectEndDate = Date()
        hasEndDate = false
        projectColor = "#3CC45B"
        projectTags = []
        newTag = ""
        selectedTeamMembers = []
    }
    
    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !projectTags.contains(trimmedTag) {
            projectTags.append(trimmedTag)
            newTag = ""
        }
    }
    
    func removeTag(_ tag: String) {
        projectTags.removeAll { $0 == tag }
    }
    
    func addTeamMember(_ user: User) {
        if !selectedTeamMembers.contains(where: { $0.id == user.id }) {
            selectedTeamMembers.append(user)
        }
    }
    
    func removeTeamMember(_ user: User) {
        selectedTeamMembers.removeAll { $0.id == user.id }
    }
    
    // MARK: - Analytics
    
    func getProjectAnalytics(_ project: Project) -> ProjectAnalytics {
        let tasks = getProjectTasks(project)
        let completedTasks = tasks.filter { $0.status == .completed }
        let overdueTasks = tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && task.status != .completed
        }
        
        let totalEstimatedHours = tasks.compactMap { $0.estimatedHours }.reduce(0, +)
        let totalActualHours = tasks.compactMap { $0.actualHours }.reduce(0, +)
        
        let budgetUtilization = project.budgetUtilization
        let projectedCompletion = analyticsService.predictProjectCompletion(for: project)
        
        return ProjectAnalytics(
            totalTasks: tasks.count,
            completedTasks: completedTasks.count,
            overdueTasks: overdueTasks.count,
            totalEstimatedHours: totalEstimatedHours,
            totalActualHours: totalActualHours,
            budgetUtilization: budgetUtilization,
            projectedCompletion: projectedCompletion
        )
    }
    
    // MARK: - Computed Properties
    
    var projectCounts: (active: Int, planning: Int, completed: Int, overBudget: Int) {
        let active = projects.filter { $0.status == .active && !$0.isArchived }.count
        let planning = projects.filter { $0.status == .planning && !$0.isArchived }.count
        let completed = projects.filter { $0.status == .completed }.count
        let overBudget = projects.filter { project in
            guard let budget = project.budget, let cost = project.actualCost else { return false }
            return cost > budget && !project.isArchived
        }.count
        
        return (active, planning, completed, overBudget)
    }
    
    var averageProgress: Double {
        let activeProjects = projects.filter { $0.status == .active && !$0.isArchived }
        guard !activeProjects.isEmpty else { return 0 }
        let totalProgress = activeProjects.map { $0.progress }.reduce(0, +)
        return totalProgress / Double(activeProjects.count)
    }
    
    var isFormValid: Bool {
        let nameValid = !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let budgetValid = !hasBudget || (!projectBudget.isEmpty && Double(projectBudget) != nil)
        let dateValid = !hasEndDate || projectEndDate >= projectStartDate
        
        return nameValid && budgetValid && dateValid
    }
}

// MARK: - Supporting Types

struct ProjectAnalytics {
    let totalTasks: Int
    let completedTasks: Int
    let overdueTasks: Int
    let totalEstimatedHours: Double
    let totalActualHours: Double
    let budgetUtilization: Double
    let projectedCompletion: Date?
    
    var completionRate: Double {
        totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) * 100 : 0
    }
    
    var isOnSchedule: Bool {
        guard let projectedCompletion = projectedCompletion else { return true }
        return projectedCompletion <= Date()
    }
    
    var isOverBudget: Bool {
        return budgetUtilization > 1.0
    }
    
    var hoursVariance: Double {
        guard totalEstimatedHours > 0 else { return 0 }
        return ((totalActualHours - totalEstimatedHours) / totalEstimatedHours) * 100
    }
}