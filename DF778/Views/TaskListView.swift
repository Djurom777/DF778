import SwiftUI

struct TaskListView: View {
    @StateObject private var dataService = DataService.shared
    @State private var showingCreateTask = false
    @State private var selectedFilter: TaskFilter = .all
    @State private var selectedTask: Task?
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case todo = "To Do"
        case inProgress = "In Progress"
        case completed = "Completed"
    }
    
    var filteredTasks: [Task] {
        switch selectedFilter {
        case .all:
            return dataService.tasks
        case .todo:
            return dataService.tasks.filter { $0.status == .todo }
        case .inProgress:
            return dataService.tasks.filter { $0.status == .inProgress }
        case .completed:
            return dataService.tasks.filter { $0.status == .completed }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(TaskFilter.allCases, id: \.self) { filter in
                            FilterTab(
                                title: filter.rawValue,
                                count: getTaskCount(for: filter),
                                isSelected: selectedFilter == filter
                            ) {
                                selectedFilter = filter
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 16)
                .background(Color.backgroundPrimary)
                
                // Tasks List
                if filteredTasks.isEmpty {
                    Spacer()
                    EmptyStateView()
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task) {
                                selectedTask = task
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    dataService.deleteTask(task)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.backgroundPrimary)
                }
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingCreateTask = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.accentYellow)
                    }
                }
            }
            .sheet(isPresented: $showingCreateTask) {
                CreateTaskView { task in
                    dataService.addTask(task)
                }
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task)
            }
        }
    }
    
    private func getTaskCount(for filter: TaskFilter) -> Int {
        switch filter {
        case .all:
            return dataService.tasks.count
        case .todo:
            return dataService.tasks.filter { $0.status == .todo }.count
        case .inProgress:
            return dataService.tasks.filter { $0.status == .inProgress }.count
        case .completed:
            return dataService.tasks.filter { $0.status == .completed }.count
        }
    }
}

struct FilterTab: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.bodyBold)
                
                Text("\(count)")
                    .font(.caption1)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.backgroundPrimary : Color.textTertiary.opacity(0.3))
                    )
            }
            .foregroundColor(isSelected ? .backgroundPrimary : .textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.accentYellow : Color.cardBackground)
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    TaskListView()
}