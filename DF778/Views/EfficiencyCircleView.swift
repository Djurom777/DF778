import SwiftUI

struct EfficiencyCircleView: View {
    @StateObject private var dataService = DataService.shared
    @State private var animateCircle = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Efficiency Score")
                            .font(.title1)
                            .foregroundColor(.textPrimary)
                        
                        Text("Your productivity at a glance")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                    
                    // Main Efficiency Circle
                    ZStack {
                        // Background Circle
                        Circle()
                            .stroke(Color.textTertiary.opacity(0.3), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        // Progress Circle
                        Circle()
                            .trim(from: 0, to: animateCircle ? CGFloat(dataService.completionRate) : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [.accentYellow, .accentGreen],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.5), value: animateCircle)
                        
                        // Center Content
                        VStack(spacing: 8) {
                            Text("\(Int(dataService.completionRate * 100))%")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.textPrimary)
                            
                            Text("Efficiency")
                                .font(.title3)
                                .foregroundColor(.textSecondary)
                            
                            EfficiencyBadge(score: dataService.completionRate)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Efficiency Metrics
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        EfficiencyMetricCard(
                            title: "Tasks Completed",
                            value: "\(dataService.completedTasksCount)",
                            subtitle: "of \(dataService.tasks.count) total",
                            icon: "checkmark.circle.fill",
                            color: .statusSuccess
                        )
                        
                        EfficiencyMetricCard(
                            title: "Avg. Task Time",
                            value: String(format: "%.1fh", dataService.averageTaskTime),
                            subtitle: "per task",
                            icon: "clock.fill",
                            color: .accentYellow
                        )
                        
                        EfficiencyMetricCard(
                            title: "In Progress",
                            value: "\(dataService.inProgressTasksCount)",
                            subtitle: "active tasks",
                            icon: "arrow.triangle.2.circlepath",
                            color: .statusInfo
                        )
                        
                        EfficiencyMetricCard(
                            title: "Pending",
                            value: "\(dataService.pendingTasksCount)",
                            subtitle: "to start",
                            icon: "circle.dotted",
                            color: .textSecondary
                        )
                    }
                    .padding(.horizontal)
                    
                    // Weekly Progress
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("This Week")
                                .font(.title3)
                                .foregroundColor(.textPrimary)
                            
                            Spacer()
                            
                            Text("5 days remaining")
                                .font(.caption1)
                                .foregroundColor(.textSecondary)
                        }
                        
                        WeeklyProgressView()
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Efficiency")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                animateCircle = true
            }
        }
    }
}

struct EfficiencyBadge: View {
    let score: Double
    
    var badgeText: String {
        switch score {
        case 0.9...:
            return "Excellent"
        case 0.7..<0.9:
            return "Great"
        case 0.5..<0.7:
            return "Good"
        case 0.3..<0.5:
            return "Fair"
        default:
            return "Getting Started"
        }
    }
    
    var badgeColor: Color {
        switch score {
        case 0.9...:
            return .accentGreen
        case 0.7..<0.9:
            return .statusSuccess
        case 0.5..<0.7:
            return .accentYellow
        case 0.3..<0.5:
            return .statusWarning
        default:
            return .textSecondary
        }
    }
    
    var body: some View {
        Text(badgeText)
            .font(.caption1)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(badgeColor.opacity(0.2))
            .foregroundColor(badgeColor)
            .cornerRadius(12)
    }
}

struct EfficiencyMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(title)
                    .font(.bodyBold)
                    .foregroundColor(.textPrimary)
                
                Text(subtitle)
                    .font(.caption1)
                    .foregroundColor(.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
        )
    }
}

struct WeeklyProgressView: View {
    @StateObject private var dataService = DataService.shared
    
    var weekdays: [String] {
        ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(Array(weekdays.enumerated()), id: \.offset) { index, day in
                    VStack(spacing: 8) {
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.textSecondary)
                        
                        // Progress bar for each day
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.textTertiary.opacity(0.3))
                            .frame(width: 30, height: 60)
                            .overlay(
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [.accentYellow, .accentGreen],
                                                startPoint: .bottom,
                                                endPoint: .top
                                            )
                                        )
                                        .frame(height: CGFloat.random(in: 10...50))
                                }
                            )
                        
                        Text("\(Int.random(in: 0...5))")
                            .font(.caption2)
                            .foregroundColor(.textPrimary)
                    }
                    
                    if index < weekdays.count - 1 {
                        Spacer()
                    }
                }
            }
            
            HStack {
                Text("Tasks completed per day")
                    .font(.caption1)
                    .foregroundColor(.textSecondary)
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.cardBackground)
        )
    }
}

#Preview {
    EfficiencyCircleView()
}