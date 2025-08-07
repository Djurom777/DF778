import SwiftUI

struct DashboardView: View {
    @StateObject private var dataService = DataService.shared
    @State private var showingCreateTask = false
    @State private var selectedTask: Task?
    @State private var showingTaskDetail = false
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        if let user = dataService.currentUser {
                            Text("Welcome back, \(user.name)!")
                                .font(.title2)
                                .foregroundColor(.textPrimary)
                        }
                        
                        Text("Here's your productivity overview")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Quick Stats
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                        StatCard(
                            title: "Completed",
                            value: "\(dataService.completedTasksCount)",
                            color: .statusSuccess,
                            icon: "checkmark.circle.fill"
                        )
                        
                        StatCard(
                            title: "In Progress",
                            value: "\(dataService.inProgressTasksCount)",
                            color: .accentYellow,
                            icon: "clock.fill"
                        )
                        
                        StatCard(
                            title: "Pending",
                            value: "\(dataService.pendingTasksCount)",
                            color: .textSecondary,
                            icon: "circle.fill"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recent Tasks
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Tasks")
                                .font(.title3)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Button("View All") {
                                switchToTasksTab()
                            }
                            .font(.caption1)
                            .foregroundColor(.accentYellow)
                        }
                        .padding(.horizontal)
                        
                        if dataService.tasks.isEmpty {
                            EmptyStateView()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(dataService.tasks.prefix(5))) { task in
                                    TaskRowView(task: task) {
                                        selectedTask = task
                                        showingTaskDetail = true
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Dashboard")
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
            .sheet(isPresented: $showingTaskDetail) {
                if let task = selectedTask {
                    TaskDetailView(task: task)
                }
            }
        }
    }
    
    private func switchToTasksTab() {
        selectedTab = 1 // Switch to Tasks tab
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption1)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
    }
}

struct TaskRowView: View {
    let task: Task
    let onTap: () -> Void
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Indicator
            Button {
                if task.status != .completed {
                    dataService.completeTask(task)
                }
            } label: {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(Color(hex: task.status.color))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                if !task.description.isEmpty {
                    Text(task.description)
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(task.status.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: task.status.color).opacity(0.2))
                        .foregroundColor(Color(hex: task.status.color))
                        .cornerRadius(8)
                    
                    Text(task.priority.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: task.priority.color).opacity(0.2))
                        .foregroundColor(Color(hex: task.priority.color))
                        .cornerRadius(8)
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            if let dueDate = task.dueDate {
                VStack {
                    Text("Due")
                        .font(.caption2)
                        .foregroundColor(.textTertiary)
                    
                    Text(dueDate, format: .dateTime.month().day())
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)
            
            Text("No tasks yet")
                .font(.title3)
                .foregroundColor(.textSecondary)
            
            Text("Create your first task to get started")
                .font(.body)
                .foregroundColor(.textTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
}