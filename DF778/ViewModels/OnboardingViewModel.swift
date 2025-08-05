import Foundation
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var selectedRole: User.UserRole = .member
    @Published var preferences: UserPreferences = UserPreferences()
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var hasCompletedOnboarding: Bool = false
    
    private let dataService = DataService.shared
    private let notificationService = NotificationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case userInfo = 1
        case preferences = 2
        case tutorial = 3
        case notifications = 4
        case complete = 5
        
        var title: String {
            switch self {
            case .welcome: return "Welcome to TaskFlow Nexus"
            case .userInfo: return "Let's Get Started"
            case .preferences: return "Customize Your Experience"
            case .tutorial: return "Quick Tutorial"
            case .notifications: return "Stay Updated"
            case .complete: return "You're All Set!"
            }
        }
        
        var subtitle: String {
            switch self {
            case .welcome: return "Revolutionize your task and project management"
            case .userInfo: return "Tell us a bit about yourself"
            case .preferences: return "Set up your work preferences"
            case .tutorial: return "Learn the key features"
            case .notifications: return "Enable notifications to stay on track"
            case .complete: return "Welcome to your productivity journey!"
            }
        }
    }
    
    init() {
        checkOnboardingStatus()
    }
    
    private func checkOnboardingStatus() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
        if dataService.currentUser != nil {
            hasCompletedOnboarding = true
        }
    }
    
    // MARK: - Navigation
    
    func nextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .userInfo
        case .userInfo:
            if validateUserInfo() {
                currentStep = .preferences
            }
        case .preferences:
            currentStep = .tutorial
        case .tutorial:
            currentStep = .notifications
        case .notifications:
            currentStep = .complete
        case .complete:
            completeOnboarding()
        }
    }
    
    func previousStep() {
        guard let previousStepRawValue = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = previousStepRawValue
    }
    
    func skipToStep(_ step: OnboardingStep) {
        currentStep = step
    }
    
    // MARK: - Validation
    
    private func validateUserInfo() -> Bool {
        if userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showErrorMessage("Please enter your name")
            return false
        }
        
        if userEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showErrorMessage("Please enter your email")
            return false
        }
        
        if !isValidEmail(userEmail) {
            showErrorMessage("Please enter a valid email address")
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
        
        // Auto-hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showError = false
        }
    }
    
    // MARK: - User Creation
    
    func completeOnboarding() {
        isLoading = true
        
        // Create user with collected information
        let user = dataService.createUser(
            name: userName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: userEmail.trimmingCharacters(in: .whitespacesAndNewlines),
            role: selectedRole
        )
        
        // Update user preferences
        var updatedUser = user
        updatedUser.preferences = preferences
        dataService.updateUser(updatedUser)
        dataService.setCurrentUser(updatedUser)
        
        // Setup notifications if enabled
        if preferences.enableNotifications {
            setupNotifications()
        }
        
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.hasCompletedOnboarding = true
        }
    }
    
    private func setupNotifications() {
        notificationService.requestPermission()
        
        if preferences.enableLifestyleIntegration {
            notificationService.scheduleBreakReminder()
            notificationService.scheduleEndOfWorkdayNotification()
        }
    }
    
    // MARK: - Tutorial Actions
    
    func simulateTaskCreation() {
        let task = dataService.createTask(
            title: "Welcome Task",
            description: "This is your first task in TaskFlow Nexus! Complete this to get started."
        )
        
        // Show task creation feedback
        // This would typically trigger a UI update to show the task was created
    }
    
    func simulateProjectCreation() {
        let project = dataService.createProject(
            name: "Getting Started Project",
            description: "A sample project to help you explore TaskFlow Nexus features",
            budget: 1000
        )
        
        // Create a sample task for the project
        _ = dataService.createTask(
            title: "Explore the dashboard",
            description: "Take a look around the main dashboard to familiarize yourself with the interface",
            projectId: project.id
        )
    }
    
    // MARK: - Preferences Management
    
    func updateWorkHours(start: String, end: String) {
        preferences.workStartTime = start
        preferences.workEndTime = end
    }
    
    func toggleNotifications(_ enabled: Bool) {
        preferences.enableNotifications = enabled
    }
    
    func toggleLifestyleIntegration(_ enabled: Bool) {
        preferences.enableLifestyleIntegration = enabled
    }
    
    func toggleFinancialInsights(_ enabled: Bool) {
        preferences.enableFinancialInsights = enabled
    }
    
    func updateBreakInterval(_ minutes: Int) {
        preferences.preferredBreakInterval = minutes
    }
    
    func updateTheme(_ theme: UserPreferences.AppTheme) {
        preferences.theme = theme
    }
    
    // MARK: - Progress Tracking
    
    var progressPercentage: Double {
        return Double(currentStep.rawValue) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var isFirstStep: Bool {
        return currentStep == .welcome
    }
    
    var isLastStep: Bool {
        return currentStep == .complete
    }
    
    var canProceed: Bool {
        switch currentStep {
        case .welcome, .preferences, .tutorial, .notifications, .complete:
            return true
        case .userInfo:
            return !userName.isEmpty && !userEmail.isEmpty && isValidEmail(userEmail)
        }
    }
}