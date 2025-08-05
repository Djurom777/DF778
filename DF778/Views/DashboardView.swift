import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingNotifications = false
    @State private var showingCreateTask = false
    @State private var showingCreateProject = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        // Header with notifications
                        DashboardHeader(
                            hasNotifications: viewModel.hasUnreadNotifications,
                            onNotificationsTapped: { showingNotifications = true },
                            onRefresh: { viewModel.refreshData() }
                        )
                        
                        // Quick Stats
                        QuickStatsSection(viewModel: viewModel)
                        
                        // Today's Tasks
                        TodayTasksSection(
                            tasks: viewModel.todayTasks,
                            onTaskTapped: { task in
                                viewModel.markTaskComplete(task)
                            }
                        )
                        
                        // Active Projects
                        ActiveProjectsSection(
                            projects: viewModel.activeProjects,
                            onCreateProject: { showingCreateProject = true }
                        )
                        
                        // Recent Activity
                        RecentActivitySection(
                            tasks: viewModel.recentTasks,
                            onCreateTask: { showingCreateTask = true }
                        )
                        
                        // Productivity Insights
                        ProductivityInsightsSection(
                            metrics: viewModel.productivityMetrics
                        )
                        
                        // Upcoming Deadlines
                        UpcomingDeadlinesSection(
                            tasks: viewModel.upcomingDeadlines
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // Account for tab bar
                }
                .refreshable {
                    viewModel.refreshData()
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.overlay
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentYellow))
                        .scaleEffect(1.2)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingNotifications) {
            VStack {
                Text("Notifications")
                    .font(AppFonts.title1)
                    .foregroundColor(.textPrimary)
                Text("Coming Soon")
                    .font(AppFonts.body)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundPrimary)
        }
        .sheet(isPresented: $showingCreateTask) {
            CreateTaskView()
        }
        .sheet(isPresented: $showingCreateProject) {
            CreateProjectView()
        }
    }
}

// MARK: - Dashboard Header

struct DashboardHeader: View {
    let hasNotifications: Bool
    let onNotificationsTapped: () -> Void
    let onRefresh: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning")
                    .font(AppFonts.headline)
                    .foregroundColor(.textSecondary)
                
                Text("Ready to be productive?")
                    .font(AppFonts.dashboardTitle)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                // Refresh button
                Button {
                    onRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(.textSecondary)
                }
                
                // Notifications button
                Button {
                    onNotificationsTapped()
                } label: {
                    ZStack {
                        Image(systemName: "bell")
                            .font(.system(size: 18))
                            .foregroundColor(.textSecondary)
                        
                        if hasNotifications {
                            Circle()
                                .fill(Color.statusError)
                                .frame(width: 8, height: 8)
                                .offset(x: 8, y: -8)
                        }
                    }
                }
                
                // Profile button
                Button {
                    // Handle profile tap
                } label: {
                    Circle()
                        .fill(Color.gradientAccent)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("U")
                                .font(AppFonts.buttonMedium)
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Quick Stats Section

struct QuickStatsSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(AppFonts.headline)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Active Tasks",
                    value: "\(viewModel.todayTasksCount)",
                    subtitle: "due today",
                    color: .accentBlue,
                    icon: "checkmark.circle"
                )
                
                StatCard(
                    title: "Projects",
                    value: "\(viewModel.activeProjectsCount)",
                    subtitle: "in progress",
                    color: .accentGreen,
                    icon: "folder"
                )
                
                StatCard(
                    title: "Completion",
                    value: "\(Int(viewModel.taskCompletionRate))%",
                    subtitle: "this week",
                    color: .accentYellow,
                    icon: "chart.bar"
                )
                
                StatCard(
                    title: "Weekly Goal",
                    value: "\(Int(viewModel.weeklyGoalProgress * 100))%",
                    subtitle: "progress",
                    color: .accentPurple,
                    icon: "target"
                )
            }
        }
    }
}

// MARK: - Today's Tasks Section

struct TodayTasksSection: View {
    let tasks: [Task]
    let onTaskTapped: (Task) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Tasks")
                    .font(AppFonts.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if !tasks.isEmpty {
                    Text("\(tasks.count)")
                        .font(AppFonts.caption1)
                        .foregroundColor(.textAccent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.cardBackground)
                        .cornerRadius(8)
                }
            }
            
            if tasks.isEmpty {
                EmptyStateView(
                    icon: "checkmark.circle",
                    title: "No tasks due today",
                    subtitle: "Great job staying on top of things!"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TodayTaskRow(
                            task: task,
                            onTapped: { onTaskTapped(task) }
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Active Projects Section

struct ActiveProjectsSection: View {
    let projects: [Project]
    let onCreateProject: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Projects")
                    .font(AppFonts.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    onCreateProject()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentYellow)
                }
            }
            
            if projects.isEmpty {
                EmptyStateView(
                    icon: "folder.badge.plus",
                    title: "No active projects",
                    subtitle: "Create your first project to get started"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(projects) { project in
                            ProjectCard(project: project)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
    }
}

// MARK: - Recent Activity Section

struct RecentActivitySection: View {
    let tasks: [Task]
    let onCreateTask: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(AppFonts.headline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button {
                    onCreateTask()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.accentYellow)
                }
            }
            
            if tasks.isEmpty {
                EmptyStateView(
                    icon: "clock",
                    title: "No recent activity",
                    subtitle: "Start by creating your first task"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tasks.prefix(5)) { task in
                        RecentTaskRow(task: task)
                    }
                }
            }
        }
    }
}

// MARK: - Productivity Insights Section

struct ProductivityInsightsSection: View {
    let metrics: ProductivityMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Productivity Insights")
                .font(AppFonts.headline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 16) {
                // Productivity trend
                ProductivityTrendCard(metrics: metrics)
                
                // Completion rate
                CompletionRateCard(metrics: metrics)
            }
        }
    }
}

// MARK: - Upcoming Deadlines Section

struct UpcomingDeadlinesSection: View {
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Deadlines")
                .font(AppFonts.headline)
                .foregroundColor(.textPrimary)
            
            if tasks.isEmpty {
                EmptyStateView(
                    icon: "calendar",
                    title: "No upcoming deadlines",
                    subtitle: "You're all caught up!"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(tasks) { task in
                        DeadlineTaskRow(task: task)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(AppFonts.dashboardMetric)
                    .foregroundColor(.textPrimary)
                
                Text(title)
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textSecondary)
                
                Text(subtitle)
                    .font(AppFonts.caption1)
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct TodayTaskRow: View {
    let task: Task
    let onTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                onTapped()
            } label: {
                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(task.status == .completed ? .statusSuccess : .textTertiary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppFonts.taskTitle)
                    .foregroundColor(.textPrimary)
                    .strikethrough(task.status == .completed)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(task.priority.color)
                        .frame(width: 8, height: 8)
                    
                    Text(task.priority.displayName)
                        .font(AppFonts.caption1)
                        .foregroundColor(.textTertiary)
                    
                    if let dueDate = task.dueDate {
                        Text("•")
                            .font(AppFonts.caption1)
                            .foregroundColor(.textTertiary)
                        
                        Text(dueDate, style: .time)
                            .font(AppFonts.caption1)
                            .foregroundColor(.textTertiary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct ProjectCard: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: project.color))
                    .frame(width: 12, height: 12)
                
                Spacer()
                
                Text("\(project.completionPercentage)%")
                    .font(AppFonts.caption1)
                    .foregroundColor(.textTertiary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(project.name)
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textPrimary)
                    .lineLimit(2)
                
                Text("\(project.completedTasks)/\(project.totalTasks) tasks")
                    .font(AppFonts.caption1)
                    .foregroundColor(.textSecondary)
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.backgroundSecondary)
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(Color(hex: project.color))
                            .frame(width: geometry.size.width * project.progress, height: 4)
                            .cornerRadius(2)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .frame(width: 160)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct RecentTaskRow: View {
    let task: Task
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(task.status.color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppFonts.taskTitle)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                Text(task.status.displayName)
                    .font(AppFonts.caption1)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(task.updatedAt, style: .relative)
                .font(AppFonts.caption1)
                .foregroundColor(.textTertiary)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct DeadlineTaskRow: View {
    let task: Task
    
    private var daysUntilDue: Int {
        guard let dueDate = task.dueDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }
    
    private var deadlineColor: Color {
        if daysUntilDue < 0 {
            return .statusError
        } else if daysUntilDue <= 1 {
            return .statusWarning
        } else {
            return .textSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppFonts.taskTitle)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(task.priority.color)
                        .frame(width: 8, height: 8)
                    
                    Text(task.priority.displayName)
                        .font(AppFonts.caption1)
                        .foregroundColor(.textTertiary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(AppFonts.caption1)
                        .foregroundColor(deadlineColor)
                    
                    Text(daysUntilDue < 0 ? "Overdue" : 
                         daysUntilDue == 0 ? "Today" : 
                         "\(daysUntilDue) days")
                        .font(AppFonts.caption2)
                        .foregroundColor(deadlineColor)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(12)
    }
}

struct ProductivityTrendCard: View {
    let metrics: ProductivityMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("This Week")
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: metrics.productivityTrend >= 0 ? "arrow.up" : "arrow.down")
                        .font(.system(size: 12))
                        .foregroundColor(metrics.productivityTrend >= 0 ? .statusSuccess : .statusError)
                    
                    Text("\(abs(Int(metrics.productivityTrend)))%")
                        .font(AppFonts.caption1)
                        .foregroundColor(metrics.productivityTrend >= 0 ? .statusSuccess : .statusError)
                }
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(metrics.tasksCompletedThisWeek)")
                        .font(AppFonts.monoLarge)
                        .foregroundColor(.textPrimary)
                    
                    Text("Completed")
                        .font(AppFonts.caption1)
                        .foregroundColor(.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(metrics.tasksCompletedLastWeek)")
                        .font(AppFonts.monoLarge)
                        .foregroundColor(.textTertiary)
                    
                    Text("Last Week")
                        .font(AppFonts.caption1)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct CompletionRateCard: View {
    let metrics: ProductivityMetrics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Completion Rate")
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(Int(metrics.completionRate))%")
                    .font(AppFonts.monoLarge)
                    .foregroundColor(.accentGreen)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.backgroundSecondary)
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color.gradientSuccess)
                        .frame(width: geometry.size.width * (metrics.completionRate / 100), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.textTertiary)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textSecondary)
                
                Text(subtitle)
                    .font(AppFonts.caption1)
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Notifications View (Placeholder)

// MARK: - Placeholder Views

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create Task")
                    .font(AppFonts.title1)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CreateProjectView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create Project")
                    .font(AppFonts.title1)
                    .foregroundColor(.textPrimary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundPrimary)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}