import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            Color.gradientPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome {
                    OnboardingProgressBar(progress: viewModel.progressPercentage)
                        .padding(.horizontal)
                        .padding(.top)
                }
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.welcome)
                    
                    UserInfoStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.userInfo)
                    
                    PreferencesStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.preferences)
                    
                    TutorialStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.tutorial)
                    
                    NotificationsStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.notifications)
                    
                    CompleteStepView(viewModel: viewModel)
                        .tag(OnboardingViewModel.OnboardingStep.complete)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onChange(of: viewModel.hasCompletedOnboarding) { completed in
            if completed {
                dismiss()
            }
        }
    }
}

// MARK: - Progress Bar

struct OnboardingProgressBar: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Setup Progress")
                    .font(AppFonts.caption1)
                    .foregroundColor(.textTertiary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(AppFonts.caption1)
                    .foregroundColor(.textAccent)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.backgroundSecondary)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color.gradientAccent)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Welcome Step

struct WelcomeStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // App Icon and Title
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.gradientAccent)
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text("TaskFlow Nexus")
                        .font(AppFonts.onboardingTitle)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Revolutionize your task and project management")
                        .font(AppFonts.onboardingSubtitle)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            // Features
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "chart.bar.fill",
                    title: "Financial Insights",
                    description: "Track budgets and expenses"
                )
                
                FeatureRow(
                    icon: "heart.fill",
                    title: "Lifestyle Integration",
                    description: "Work-life balance tools"
                )
                
                FeatureRow(
                    icon: "person.3.fill",
                    title: "Team Collaboration",
                    description: "Real-time communication"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Continue Button
            Button {
                withAnimation {
                    viewModel.nextStep()
                }
            } label: {
                HStack {
                    Text("Get Started")
                        .font(AppFonts.buttonLarge)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.gradientAccent)
                .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - User Info Step

struct UserInfoStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            OnboardingStepHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            // Form
            VStack(spacing: 16) {
                CustomTextField(
                    title: "Full Name",
                    text: $viewModel.userName,
                    placeholder: "Enter your full name"
                )
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .email
                }
                
                CustomTextField(
                    title: "Email Address",
                    text: $viewModel.userEmail,
                    placeholder: "Enter your email address"
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .focused($focusedField, equals: .email)
                .submitLabel(.done)
                .onSubmit {
                    if viewModel.canProceed {
                        withAnimation {
                            viewModel.nextStep()
                        }
                    }
                }
                
                // Role Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Role")
                        .font(AppFonts.formLabel)
                        .foregroundColor(.textPrimary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(User.UserRole.allCases, id: \.self) { role in
                            Button {
                                viewModel.selectedRole = role
                            } label: {
                                Text(role.rawValue.capitalized)
                                    .font(AppFonts.buttonMedium)
                                    .foregroundColor(viewModel.selectedRole == role ? .white : .textSecondary)
                                    .frame(height: 44)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        viewModel.selectedRole == role ?
                                        Color.accentGreen : Color.cardBackground
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Navigation Buttons
            OnboardingNavigationButtons(
                viewModel: viewModel,
                canProceed: viewModel.canProceed
            )
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .name
            }
        }
    }
}

// MARK: - Preferences Step

struct PreferencesStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            OnboardingStepHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Work Hours
                    PreferenceSection(title: "Work Hours") {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Start Time")
                                    .font(AppFonts.formLabel)
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("End Time")
                                    .font(AppFonts.formLabel)
                                    .foregroundColor(.textSecondary)
                                
                                DatePicker("", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                            }
                        }
                    }
                    
                    // Features
                    PreferenceSection(title: "Features") {
                        PreferenceToggle(
                            title: "Push Notifications",
                            description: "Get notified about tasks and deadlines",
                            isOn: $viewModel.preferences.enableNotifications
                        )
                        
                        PreferenceToggle(
                            title: "Lifestyle Integration",
                            description: "Break reminders and work-life balance",
                            isOn: $viewModel.preferences.enableLifestyleIntegration
                        )
                        
                        PreferenceToggle(
                            title: "Financial Insights",
                            description: "Budget tracking and expense analytics",
                            isOn: $viewModel.preferences.enableFinancialInsights
                        )
                    }
                    
                    // Break Intervals
                    if viewModel.preferences.enableLifestyleIntegration {
                        PreferenceSection(title: "Break Reminders") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reminder Interval")
                                    .font(AppFonts.formLabel)
                                    .foregroundColor(.textSecondary)
                                
                                Picker("Break Interval", selection: $viewModel.preferences.preferredBreakInterval) {
                                    Text("60 minutes").tag(60)
                                    Text("90 minutes").tag(90)
                                    Text("120 minutes").tag(120)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .colorScheme(.dark)
                            }
                        }
                    }
                    
                    // Theme
                    PreferenceSection(title: "Appearance") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Theme")
                                .font(AppFonts.formLabel)
                                .foregroundColor(.textSecondary)
                            
                            Picker("Theme", selection: $viewModel.preferences.theme) {
                                ForEach(UserPreferences.AppTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue.capitalized).tag(theme)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .colorScheme(.dark)
                        }
                    }
                }
                .padding(.horizontal, 32)
            }
            
            // Navigation Buttons
            OnboardingNavigationButtons(
                viewModel: viewModel,
                canProceed: true
            )
        }
    }
}

// MARK: - Tutorial Step

struct TutorialStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var currentTutorialStep = 0
    
    let tutorialSteps = [
        TutorialStep(
            icon: "plus.circle.fill",
            title: "Create Tasks",
            description: "Easily add new tasks with priorities, due dates, and assignments",
            action: "Try creating a task"
        ),
        TutorialStep(
            icon: "folder.fill",
            title: "Manage Projects",
            description: "Organize tasks into projects with budgets and team collaboration",
            action: "Create a sample project"
        ),
        TutorialStep(
            icon: "chart.bar.fill",
            title: "Track Progress",
            description: "Monitor your productivity with insights and analytics",
            action: "View dashboard"
        )
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            OnboardingStepHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            // Tutorial Content
            TabView(selection: $currentTutorialStep) {
                ForEach(Array(tutorialSteps.enumerated()), id: \.offset) { index, step in
                    TutorialStepCard(step: step) {
                        // Handle tutorial action
                        switch index {
                        case 0:
                            viewModel.simulateTaskCreation()
                        case 1:
                            viewModel.simulateProjectCreation()
                        default:
                            break
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 400)
            
            // Page Indicators
            HStack(spacing: 8) {
                ForEach(0..<tutorialSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentTutorialStep ? Color.accentYellow : Color.textTertiary)
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: currentTutorialStep)
                }
            }
            
            Spacer()
            
            // Navigation Buttons
            OnboardingNavigationButtons(
                viewModel: viewModel,
                canProceed: true
            )
        }
    }
}

// MARK: - Notifications Step

struct NotificationsStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            OnboardingStepHeader(
                title: viewModel.currentStep.title,
                subtitle: viewModel.currentStep.subtitle
            )
            
            // Notification Icon
            ZStack {
                Circle()
                    .fill(Color.gradientAccent)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            // Benefits
            VStack(spacing: 20) {
                NotificationBenefit(
                    icon: "clock.fill",
                    title: "Task Reminders",
                    description: "Never miss important deadlines"
                )
                
                NotificationBenefit(
                    icon: "heart.fill",
                    title: "Break Notifications",
                    description: "Maintain healthy work habits"
                )
                
                NotificationBenefit(
                    icon: "dollarsign.circle.fill",
                    title: "Budget Alerts",
                    description: "Stay on top of project expenses"
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button {
                    viewModel.toggleNotifications(true)
                    withAnimation {
                        viewModel.nextStep()
                    }
                } label: {
                    Text("Enable Notifications")
                        .font(AppFonts.buttonLarge)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.gradientAccent)
                        .cornerRadius(12)
                }
                
                Button {
                    viewModel.toggleNotifications(false)
                    withAnimation {
                        viewModel.nextStep()
                    }
                } label: {
                    Text("Maybe Later")
                        .font(AppFonts.buttonMedium)
                        .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Complete Step

struct CompleteStepView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Success Animation
            ZStack {
                Circle()
                    .fill(Color.gradientSuccess)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            // Completion Message
            VStack(spacing: 16) {
                Text(viewModel.currentStep.title)
                    .font(AppFonts.onboardingTitle)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.currentStep.subtitle)
                    .font(AppFonts.onboardingSubtitle)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Complete Button
            Button {
                viewModel.completeOnboarding()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(height: 52)
                } else {
                    HStack {
                        Text("Start Using TaskFlow Nexus")
                            .font(AppFonts.buttonLarge)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.gradientSuccess)
                    .cornerRadius(12)
                }
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Supporting Views

struct OnboardingStepHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(AppFonts.title1)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(AppFonts.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 32)
    }
}

struct OnboardingNavigationButtons: View {
    @ObservedObject var viewModel: OnboardingViewModel
    let canProceed: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            if !viewModel.isFirstStep {
                Button {
                    withAnimation {
                        viewModel.previousStep()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(AppFonts.buttonMedium)
                    }
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
            }
            
            Button {
                withAnimation {
                    viewModel.nextStep()
                }
            } label: {
                HStack {
                    Text(viewModel.isLastStep ? "Complete" : "Next")
                        .font(AppFonts.buttonLarge)
                    
                    if !viewModel.isLastStep {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(canProceed ? Color.accentYellow : Color.textTertiary)
                .cornerRadius(12)
            }
            .disabled(!canProceed)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 32)
    }
}

// MARK: - Helper Views

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentYellow)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(AppFonts.caption1)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFonts.formLabel)
                .foregroundColor(.textPrimary)
            
            TextField(placeholder, text: $text)
                .font(AppFonts.formField)
                .foregroundColor(.textPrimary)
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
        }
    }
}

struct PreferenceSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(AppFonts.headline)
                .foregroundColor(.textPrimary)
            
            content
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct PreferenceToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(AppFonts.cardDescription)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .accentGreen))
        }
    }
}

struct TutorialStep {
    let icon: String
    let title: String
    let description: String
    let action: String
}

struct TutorialStepCard: View {
    let step: TutorialStep
    let onAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.gradientAccent)
                    .frame(width: 80, height: 80)
                
                Image(systemName: step.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text(step.title)
                    .font(AppFonts.title2)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(AppFonts.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                onAction()
            } label: {
                Text(step.action)
                    .font(AppFonts.buttonMedium)
                    .foregroundColor(.accentYellow)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.cardBackground)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 32)
    }
}

struct NotificationBenefit: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.accentGreen)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.cardTitle)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(AppFonts.cardDescription)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}