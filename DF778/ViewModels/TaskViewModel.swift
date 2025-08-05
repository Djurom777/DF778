import Foundation
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var filteredTasks: [Task] = []
    @Published var selectedTask: Task?
    @Published var showingTaskDetail: Bool = false
    @Published var showingCreateTask: Bool = false
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedSort: TaskSort = .dateCreated
    @Published var selectedPriority: Task.TaskPriority? = nil
    @Published var selectedProject: Project? = nil
    
    // Task creation/editing
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var taskPriority: Task.TaskPriority = .medium
    @Published var taskDueDate: Date = Date()
    @Published var hasDueDate: Bool = false
    @Published var estimatedHours: String = ""
    @Published var selectedAssignee: User? = nil
    @Published var taskTags: [String] = []
    @Published var newTag: String = ""
    
    private let dataService = DataService.shared
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum TaskFilter: String, CaseIterable {
        case all = "all"
        case myTasks = "my_tasks"
        case todo = "todo"
        case inProgress = "in_progress"
        case completed = "completed"
        case overdue = "overdue"
        case thisWeek = "this_week"
        
        var displayName: String {
            switch self {
            case .all: return "All Tasks"
            case .myTasks: return "My Tasks"
            case .todo: return "To Do"
            case .inProgress: return "In Progress"
            case .completed: return "Completed"
            case .overdue: return "Overdue"
            case .thisWeek: return "This Week"
            }
        }
        
        var iconName: String {
            switch self {
            case .all: return "list.bullet"
            case .myTasks: return "person.circle"
            case .todo: return "circle"
            case .inProgress: return "clock"
            case .completed: return "checkmark.circle"
            case .overdue: return "exclamationmark.triangle"
            case .thisWeek: return "calendar"
            }
        }
    }
    
    enum TaskSort: String, CaseIterable {
        case dateCreated = "date_created"
        case dueDate = "due_date"
        case priority = "priority"
        case title = "title"
        case status = "status"
        
        var displayName: String {
            switch self {
            case .dateCreated: return "Date Created"
            case .dueDate: return "Due Date"
            case .priority: return "Priority"
            case .title: return "Title"
            case .status: return "Status"
            }
        }
    }
    
    init() {
        setupDataObservers()
        loadTasks()
    }
    
    private func setupDataObservers() {
        // Observe data service changes
        dataService.$tasks
            .sink { [weak self] tasks in
                self?.tasks = tasks
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
        Publishers.CombineLatest3($selectedFilter, $selectedSort, $selectedPriority)
            .sink { [weak self] _, _, _ in
                self?.applyFiltersAndSort()
            }
            .store(in: &cancellables)
    }
    
    private func loadTasks() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isLoading = false
        }
    }
    
    // MARK: - Filtering and Sorting
    
    private func applyFiltersAndSort() {
        var filtered = tasks
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.description.localizedCaseInsensitiveContains(searchText) ||
                task.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break // No additional filtering
        case .myTasks:
            filtered = filtered.filter { $0.assignedTo == dataService.currentUser?.id }
        case .todo:
            filtered = filtered.filter { $0.status == .todo }
        case .inProgress:
            filtered = filtered.filter { $0.status == .inProgress }
        case .completed:
            filtered = filtered.filter { $0.status == .completed }
        case .overdue:
            filtered = filtered.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate < Date() && task.status != .completed
            }
        case .thisWeek:
            let calendar = Calendar.current
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: Date()) ?? Date()
            filtered = filtered.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return dueDate <= endOfWeek
            }
        }
        
        // Apply priority filter
        if let priority = selectedPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Apply project filter
        if let project = selectedProject {
            filtered = filtered.filter { $0.projectId == project.id }
        }
        
        // Apply sorting
        switch selectedSort {
        case .dateCreated:
            filtered.sort { $0.createdAt > $1.createdAt }
        case .dueDate:
            filtered.sort { task1, task2 in
                let date1 = task1.dueDate ?? Date.distantFuture
                let date2 = task2.dueDate ?? Date.distantFuture
                return date1 < date2
            }
        case .priority:
            let priorityOrder: [Task.TaskPriority] = [.urgent, .high, .medium, .low]
            filtered.sort { task1, task2 in
                let index1 = priorityOrder.firstIndex(of: task1.priority) ?? priorityOrder.count
                let index2 = priorityOrder.firstIndex(of: task2.priority) ?? priorityOrder.count
                return index1 < index2
            }
        case .title:
            filtered.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .status:
            let statusOrder: [Task.TaskStatus] = [.todo, .inProgress, .review, .blocked, .completed, .cancelled]
            filtered.sort { task1, task2 in
                let index1 = statusOrder.firstIndex(of: task1.status) ?? statusOrder.count
                let index2 = statusOrder.firstIndex(of: task2.status) ?? statusOrder.count
                return index1 < index2
            }
        }
        
        filteredTasks = filtered
    }
    
    // MARK: - Task Management
    
    func createTask() {
        let task = dataService.createTask(
            title: taskTitle,
            description: taskDescription,
            projectId: selectedProject?.id
        )
        
        var updatedTask = task
        updatedTask.priority = taskPriority
        updatedTask.assignedTo = selectedAssignee?.id ?? dataService.currentUser?.id
        updatedTask.tags = taskTags
        
        if hasDueDate {
            updatedTask.dueDate = taskDueDate
            // Schedule notification for due date
            notificationService.scheduleTaskDueDateReminder(for: updatedTask)
        }
        
        if let hours = Double(estimatedHours), hours > 0 {
            updatedTask.estimatedHours = hours
        }
        
        dataService.updateTask(updatedTask)
        resetTaskForm()
        showingCreateTask = false
    }
    
    func updateTask(_ task: Task) {
        dataService.updateTask(task)
    }
    
    func deleteTask(_ task: Task) {
        dataService.deleteTask(task)
        if selectedTask?.id == task.id {
            selectedTask = nil
            showingTaskDetail = false
        }
    }
    
    func duplicateTask(_ task: Task) {
        let duplicatedTask = dataService.createTask(
            title: "\(task.title) (Copy)",
            description: task.description,
            projectId: task.projectId
        )
        
        var updatedTask = duplicatedTask
        updatedTask.priority = task.priority
        updatedTask.tags = task.tags
        updatedTask.estimatedHours = task.estimatedHours
        
        dataService.updateTask(updatedTask)
    }
    
    func toggleTaskStatus(_ task: Task) {
        var updatedTask = task
        
        switch task.status {
        case .todo:
            updatedTask.status = .inProgress
        case .inProgress:
            updatedTask.status = .completed
            updatedTask.completedAt = Date()
        case .completed:
            updatedTask.status = .todo
            updatedTask.completedAt = nil
        default:
            break
        }
        
        dataService.updateTask(updatedTask)
    }
    
    // MARK: - Task Selection
    
    func selectTask(_ task: Task) {
        selectedTask = task
        showingTaskDetail = true
    }
    
    func deselectTask() {
        selectedTask = nil
        showingTaskDetail = false
    }
    
    // MARK: - Form Management
    
    func resetTaskForm() {
        taskTitle = ""
        taskDescription = ""
        taskPriority = .medium
        taskDueDate = Date()
        hasDueDate = false
        estimatedHours = ""
        selectedAssignee = nil
        taskTags = []
        newTag = ""
    }
    
    func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !taskTags.contains(trimmedTag) {
            taskTags.append(trimmedTag)
            newTag = ""
        }
    }
    
    func removeTag(_ tag: String) {
        taskTags.removeAll { $0 == tag }
    }
    
    // MARK: - Bulk Operations
    
    func markSelectedTasksComplete(_ taskIds: [UUID]) {
        for taskId in taskIds {
            if let taskIndex = tasks.firstIndex(where: { $0.id == taskId }) {
                var task = tasks[taskIndex]
                task.status = .completed
                task.completedAt = Date()
                dataService.updateTask(task)
            }
        }
    }
    
    func deleteSelectedTasks(_ taskIds: [UUID]) {
        for taskId in taskIds {
            if let task = tasks.first(where: { $0.id == taskId }) {
                dataService.deleteTask(task)
            }
        }
    }
    
    func assignSelectedTasks(_ taskIds: [UUID], to user: User) {
        for taskId in taskIds {
            if let taskIndex = tasks.firstIndex(where: { $0.id == taskId }) {
                var task = tasks[taskIndex]
                task.assignedTo = user.id
                dataService.updateTask(task)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var taskCounts: (todo: Int, inProgress: Int, completed: Int, overdue: Int) {
        let todo = tasks.filter { $0.status == .todo }.count
        let inProgress = tasks.filter { $0.status == .inProgress }.count
        let completed = tasks.filter { $0.status == .completed }.count
        let overdue = tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < Date() && task.status != .completed
        }.count
        
        return (todo, inProgress, completed, overdue)
    }
    
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedCount = tasks.filter { $0.status == .completed }.count
        return Double(completedCount) / Double(tasks.count) * 100
    }
    
    var isFormValid: Bool {
        return !taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}