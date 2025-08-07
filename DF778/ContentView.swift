import SwiftUI

struct ContentView: View {
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        Group {
            if dataService.currentUser == nil {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
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
            
            EfficiencyCircleView()
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Efficiency")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.accentYellow)
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    ContentView()
}