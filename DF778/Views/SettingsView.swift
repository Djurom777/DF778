import SwiftUI

struct SettingsView: View {
    @StateObject private var dataService = DataService.shared
    @State private var showingProfileEdit = false
    @State private var showingNotifications = false
    @State private var showingAppearance = false
    @State private var showingAnalytics = false
    @State private var showingClearDataAlert = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        // Profile Image
                        ZStack {
                            Circle()
                                .fill(Color.accentYellow)
                                .frame(width: 60, height: 60)
                            
                            if let user = dataService.currentUser {
                                Text(String(user.name.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.backgroundPrimary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            if let user = dataService.currentUser {
                                Text(user.name)
                                    .font(.bodyBold)
                                    .foregroundColor(.textPrimary)
                                
                                Text(user.email)
                                    .font(.body)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            showingProfileEdit = true
                        }
                        .font(.caption1)
                        .foregroundColor(.accentYellow)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.cardBackground)
                
                // App Settings
                Section("Preferences") {
                    SettingsRow(
                        icon: "bell.fill",
                        title: "Notifications",
                        subtitle: "Push notifications and reminders",
                        iconColor: .accentYellow
                    ) {
                        showingNotifications = true
                    }
                    
                    SettingsRow(
                        icon: "paintbrush.fill",
                        title: "Appearance",
                        subtitle: "Theme and display options",
                        iconColor: .statusInfo
                    ) {
                        showingAppearance = true
                    }
                    
                    SettingsRow(
                        icon: "chart.bar.fill",
                        title: "Analytics",
                        subtitle: "Data tracking preferences",
                        iconColor: .accentGreen
                    ) {
                        showingAnalytics = true
                    }
                }
                .listRowBackground(Color.cardBackground)
                
                // Data Management
                Section("Data") {
                    SettingsRow(
                        icon: "trash.fill",
                        title: "Clear Data",
                        subtitle: "Remove all tasks and progress",
                        iconColor: .statusError
                    ) {
                        clearAllData()
                    }
                }
                .listRowBackground(Color.cardBackground)
                

                
                // Sign Out
                Section {
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.statusError)
                            
                            Text("Sign Out")
                                .foregroundColor(.statusError)
                            
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.cardBackground)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingProfileEdit) {
                ProfileEditView()
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationSettingsView()
            }
            .sheet(isPresented: $showingAppearance) {
                AppearanceSettingsView()
            }
            .sheet(isPresented: $showingAnalytics) {
                AnalyticsSettingsView()
            }
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    dataService.clearAllData()
                }
            } message: {
                Text("This will permanently delete all your tasks and progress. This action cannot be undone.")
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    signOut()
                }
            } message: {
                Text("Are you sure you want to sign out? You will need to sign in again to access your data.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func signOut() {
        dataService.signOut()
    }
    
    private func clearAllData() {
        showingClearDataAlert = true
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyBold)
                        .foregroundColor(.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption1)
                    .foregroundColor(.textTertiary)
            }
            .padding(.vertical, 4)
        }
    }
}

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dataService = DataService.shared
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var showingDeleteAccountAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.bodyBold)
                            .foregroundColor(.textPrimary)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                }
                
                Section("Danger Zone") {
                    Button(action: {
                        showingDeleteAccountAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.statusError)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Delete Account")
                                    .font(.bodyBold)
                                    .foregroundColor(.statusError)
                                
                                Text("Permanently delete your account and all data")
                                    .font(.caption1)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Edit Profile")
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
                        saveProfile()
                    }
                    .foregroundColor(.accentYellow)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                             email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let user = dataService.currentUser {
                name = user.name
                email = user.email
            }
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func saveProfile() {
        if let user = dataService.currentUser {
            let updatedUser = User(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                profileImageURL: user.profileImageURL
            )
            // In a real app, you would call dataService.updateUser(updatedUser)
            // For now, we'll just update the current user directly
            dataService.currentUser = updatedUser
        }
        dismiss()
    }
    
    private func deleteAccount() {
        dataService.deleteAccount()
        dismiss()
    }
}

// MARK: - Settings Views

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var allowNotifications = true
    @State private var taskReminders = true
    @State private var dailySummary = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notification Settings") {
                    Toggle("Allow Notifications", isOn: $allowNotifications)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                    
                    Toggle("Task Reminders", isOn: $taskReminders)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                        .disabled(!allowNotifications)
                    
                    Toggle("Daily Summary", isOn: $dailySummary)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                        .disabled(!allowNotifications)
                }
                
                Section("Reminder Time") {
                    HStack {
                        Text("Daily Reminder")
                        Spacer()
                        Text("9:00 AM")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accentYellow)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AppearanceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTheme = "Dark"
    
    private let themes = ["Light", "Dark", "System"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Theme") {
                    ForEach(themes, id: \.self) { theme in
                        HStack {
                            Text(theme)
                            Spacer()
                            if theme == selectedTheme {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentYellow)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTheme = theme
                        }
                    }
                }
                
                Section("Display") {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("Medium")
                            .foregroundColor(.textSecondary)
                    }
                    
                    HStack {
                        Text("Accent Color")
                        Spacer()
                        Circle()
                            .fill(Color.accentYellow)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accentYellow)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AnalyticsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var trackProductivity = true
    @State private var shareUsageData = false
    @State private var improvePerformance = true
    
    var body: some View {
        NavigationView {
            Form {
                Section("Data Collection") {
                    Toggle("Track Productivity", isOn: $trackProductivity)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                    
                    Toggle("Share Usage Data", isOn: $shareUsageData)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                    
                    Toggle("Improve Performance", isOn: $improvePerformance)
                        .toggleStyle(SwitchToggleStyle(tint: .accentYellow))
                }
                
                Section("Privacy") {
                    Text("Your data is processed locally and never shared with third parties. Analytics help improve the app experience.")
                        .font(.caption1)
                        .foregroundColor(.textSecondary)
                }
            }
            .background(Color.backgroundPrimary)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accentYellow)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    SettingsView()
}