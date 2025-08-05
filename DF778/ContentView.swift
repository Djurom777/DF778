//
//  ContentView.swift
//  DF778
//
//  Created by IGOR on 06/08/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataService = DataService.shared
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if dataService.currentUser == nil {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            checkOnboardingStatus()
        }
    }
    
    private func checkOnboardingStatus() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
        if !hasCompletedOnboarding || dataService.currentUser == nil {
            showingOnboarding = true
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            TaskListView()
                .tabItem {
                    Image(systemName: "checklist")
                    Text("Tasks")
                }
                .tag(1)
            
            ProjectListView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Projects")
                }
                .tag(2)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Analytics")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.accentYellow)
        .background(Color.backgroundPrimary)
    }
}

// MARK: - Placeholder Views

struct TaskListView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack {
                    Text("Task List")
                        .font(AppFonts.title1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Coming Soon")
                        .font(AppFonts.body)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct ProjectListView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack {
                    Text("Project List")
                        .font(AppFonts.title1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Coming Soon")
                        .font(AppFonts.body)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack {
                    Text("Analytics")
                        .font(AppFonts.title1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Coming Soon")
                        .font(AppFonts.body)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack {
                    Text("Settings")
                        .font(AppFonts.title1)
                        .foregroundColor(.textPrimary)
                    
                    Text("Coming Soon")
                        .font(AppFonts.body)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}
