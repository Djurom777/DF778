import Foundation
import UserNotifications
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [PendingNotification] = []
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.setupNotificationCategories()
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func setupNotificationCategories() {
        let taskAction = UNNotificationAction(
            identifier: "TASK_ACTION",
            title: "Mark Complete",
            options: [.foreground]
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [taskAction],
            intentIdentifiers: [],
            options: []
        )
        
        let meetingAction = UNNotificationAction(
            identifier: "JOIN_MEETING",
            title: "Join Meeting",
            options: [.foreground]
        )
        
        let meetingCategory = UNNotificationCategory(
            identifier: "MEETING_REMINDER",
            actions: [meetingAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([taskCategory, meetingCategory])
    }
    
    // MARK: - Task Notifications
    
    func scheduleTaskReminder(for task: Task, reminderDate: Date) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Don't forget: \(task.title)"
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": task.id.uuidString]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            } else {
                DispatchQueue.main.async {
                    self.addPendingNotification(
                        id: request.identifier,
                        title: content.title,
                        body: content.body,
                        scheduledDate: reminderDate,
                        type: .taskReminder
                    )
                }
            }
        }
    }
    
    func scheduleTaskDueDateReminder(for task: Task) {
        guard let dueDate = task.dueDate,
              dueDate > Date(),
              isAuthorized else { return }
        
        // Schedule reminder 1 day before due date
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: dueDate) ?? dueDate
        
        let content = UNMutableNotificationContent()
        content.title = "Task Due Tomorrow"
        content.body = "\(task.title) is due tomorrow"
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskId": task.id.uuidString, "type": "due_reminder"]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_due_\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Lifestyle Integration Notifications
    
    func scheduleBreakReminder() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for a Break!"
        content.body = "You've been working hard. Take a 15-minute break to recharge."
        content.sound = .default
        content.userInfo = ["type": "break_reminder"]
        
        // Schedule for every 90 minutes during work hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 90 * 60, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "break_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleEndOfWorkdayNotification() {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "End of Workday"
        content.body = "Great work today! Don't forget to log your completed tasks."
        content.sound = .default
        content.userInfo = ["type": "workday_end"]
        
        var components = DateComponents()
        components.hour = 17
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "workday_end",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Project Notifications
    
    func scheduleProjectMilestoneReminder(project: Project, milestone: ProjectMilestone) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Project Milestone Due"
        content.body = "\(milestone.title) for \(project.name) is due soon"
        content.sound = .default
        content.userInfo = ["projectId": project.id.uuidString, "milestoneId": milestone.id.uuidString]
        
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: milestone.dueDate) ?? milestone.dueDate
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "milestone_\(milestone.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Budget Notifications
    
    func scheduleBudgetAlert(for project: Project, threshold: Double = 0.8) {
        guard let budget = project.budget,
              let actualCost = project.actualCost,
              actualCost / budget >= threshold,
              isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Budget Alert"
        content.body = "\(project.name) has used \(Int((actualCost / budget) * 100))% of its budget"
        content.sound = .default
        content.userInfo = ["projectId": project.id.uuidString, "type": "budget_alert"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "budget_\(project.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Notification Management
    
    private func addPendingNotification(id: String, title: String, body: String, scheduledDate: Date, type: NotificationType) {
        let notification = PendingNotification(
            id: id,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
            type: type
        )
        pendingNotifications.append(notification)
    }
    
    func cancelNotification(withId id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        pendingNotifications.removeAll { $0.id == id }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        pendingNotifications.removeAll()
    }
    
    func getPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests.compactMap { request in
                    guard let trigger = request.trigger as? UNCalendarNotificationTrigger,
                          let nextTriggerDate = trigger.nextTriggerDate() else { return nil }
                    
                    return PendingNotification(
                        id: request.identifier,
                        title: request.content.title,
                        body: request.content.body,
                        scheduledDate: nextTriggerDate,
                        type: .taskReminder // Default type, could be enhanced
                    )
                }
            }
        }
    }
}

struct PendingNotification: Identifiable {
    let id: String
    let title: String
    let body: String
    let scheduledDate: Date
    let type: NotificationType
}

enum NotificationType {
    case taskReminder
    case breakReminder
    case projectMilestone
    case budgetAlert
    case workdayEnd
}