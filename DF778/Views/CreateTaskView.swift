import SwiftUI

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Task) -> Void
    
    @State private var title = ""
    @State private var description = ""
    @State private var priority: Task.Priority = .medium
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var estimatedHours: Double = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Enter task title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Enter task description...", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(Task.Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(hex: priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Timeline") {
                    Toggle("Set Due Date", isOn: $hasDueDate)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                    
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated Hours: \(estimatedHours, specifier: "%.1f")")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        Slider(value: $estimatedHours, in: 0.5...24, step: 0.5)
                            .accentColor(.accentYellow)
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .foregroundColor(.accentYellow)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        let task = Task(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil,
            estimatedHours: estimatedHours
        )
        onSave(task)
        dismiss()
    }
}

#Preview {
    CreateTaskView { _ in }
}