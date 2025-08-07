import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataService = DataService.shared
    @State private var task: Task
    @State private var isEditing = false
    @State private var actualHours: String = ""
    
    init(task: Task) {
        self._task = State(initialValue: task)
        self._actualHours = State(initialValue: String(task.actualHours ?? 0))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(task.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                
                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.body)
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                toggleTaskStatus()
                            } label: {
                                Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                                    .font(.title)
                                    .foregroundColor(Color(hex: task.status.color))
                            }
                        }
                        
                        // Status and Priority
                        HStack {
                            StatusBadge(status: task.status)
                            PriorityBadge(priority: task.priority)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                    )
                    
                    // Task Details
                    VStack(spacing: 16) {
                        DetailRow(
                            icon: "calendar",
                            title: "Created",
                            value: task.createdAt.formatted(date: .abbreviated, time: .shortened),
                            color: .textSecondary
                        )
                        
                        if let dueDate = task.dueDate {
                            DetailRow(
                                icon: "clock",
                                title: "Due Date",
                                value: dueDate.formatted(date: .abbreviated, time: .shortened),
                                color: dueDate < Date() ? .statusError : .accentYellow
                            )
                        }
                        
                        if let completedAt = task.completedAt {
                            DetailRow(
                                icon: "checkmark.circle",
                                title: "Completed",
                                value: completedAt.formatted(date: .abbreviated, time: .shortened),
                                color: .statusSuccess
                            )
                        }
                        
                        DetailRow(
                            icon: "timer",
                            title: "Estimated Hours",
                            value: String(format: "%.1f hours", task.estimatedHours),
                            color: .accentYellow
                        )
                        
                        if task.status == .completed || task.status == .inProgress {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.accentGreen)
                                
                                Text("Actual Hours")
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                
                                Spacer()
                                
                                if isEditing {
                                    TextField("0.0", text: $actualHours)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        .keyboardType(.decimalPad)
                                } else {
                                    Text(String(format: "%.1f hours", task.actualHours ?? 0))
                                        .foregroundColor(.textSecondary)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.cardBackground)
                            )
                        }
                    }
                    
                    // Progress Section
                    if task.status == .inProgress || task.status == .completed {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Progress")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.textPrimary)
                            
                            ProgressView(value: progressValue)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: task.status.color)))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                            
                            HStack {
                                Text("Progress: \(Int(progressValue * 100))%")
                                    .font(.caption1)
                                    .foregroundColor(.textSecondary)
                                
                                Spacer()
                                
                                if let actual = task.actualHours, task.estimatedHours > 0 {
                                    let efficiency = (task.estimatedHours / actual) * 100
                                    Text("Efficiency: \(Int(efficiency))%")
                                        .font(.caption1)
                                        .foregroundColor(efficiency >= 100 ? .statusSuccess : .statusWarning)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.cardBackground)
                        )
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveChanges()
                        }
                        isEditing.toggle()
                    }
                    .foregroundColor(.accentYellow)
                }
            }
        }
    }
    
    private var progressValue: Double {
        switch task.status {
        case .todo:
            return 0.0
        case .inProgress:
            if let actual = task.actualHours, task.estimatedHours > 0 {
                return min(actual / task.estimatedHours, 1.0)
            }
            return 0.3
        case .completed:
            return 1.0
        }
    }
    
    private func toggleTaskStatus() {
        switch task.status {
        case .todo:
            task.status = .inProgress
        case .inProgress:
            task.status = .completed
            task.completedAt = Date()
        case .completed:
            task.status = .todo
            task.completedAt = nil
        }
        dataService.updateTask(task)
    }
    
    private func saveChanges() {
        if let hours = Double(actualHours) {
            task.actualHours = hours
            dataService.updateTask(task)
        }
    }
}

struct StatusBadge: View {
    let status: Task.TaskStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption1)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: status.color).opacity(0.2))
            .foregroundColor(Color(hex: status.color))
            .cornerRadius(8)
    }
}

struct PriorityBadge: View {
    let priority: Task.Priority
    
    var body: some View {
        Text(priority.rawValue)
            .font(.caption1)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: priority.color).opacity(0.2))
            .foregroundColor(Color(hex: priority.color))
            .cornerRadius(8)
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .font(.bodyBold)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.textSecondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    TaskDetailView(task: Task(
        title: "Sample Task",
        description: "This is a sample task for preview",
        status: .inProgress,
        priority: .high,
        dueDate: Date(),
        estimatedHours: 4.0
    ))
}