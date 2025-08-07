import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var name = ""
    @State private var email = ""
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomeScreen()
                        .tag(0)
                    
                    SetupScreen(name: $name, email: $email)
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.accentYellow : Color.textTertiary)
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
                
                // Navigation Button
                Button(action: {
                    if currentPage == 0 {
                        withAnimation(.spring()) {
                            currentPage = 1
                        }
                    } else {
                        completeOnboarding()
                    }
                }) {
                    HStack {
                        Text(currentPage == 0 ? "Get Started" : "Complete Setup")
                            .font(.button)
                            .foregroundColor(.backgroundPrimary)
                        
                        if currentPage == 0 {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.backgroundPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentYellow)
                    .cornerRadius(25)
                }
                .disabled(currentPage == 1 && (name.isEmpty || email.isEmpty))
                .opacity(currentPage == 1 && (name.isEmpty || email.isEmpty) ? 0.6 : 1.0)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .background(Color.backgroundPrimary.ignoresSafeArea())
        }
        .navigationBarHidden(true)
    }
    
    private func completeOnboarding() {
        dataService.signIn(name: name, email: email)
    }
}

struct WelcomeScreen: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo
            ZStack {
                Circle()
                    .fill(Color.accentYellow)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(.backgroundPrimary)
            }
            
            VStack(spacing: 16) {
                Text("TaskFlow Nexus")
                    .font(.title1)
                    .foregroundColor(.textPrimary)
                
                Text("Boost your productivity with intelligent task management and efficiency tracking")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct SetupScreen: View {
    @Binding var name: String
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Let's get you set up")
                    .font(.title2)
                    .foregroundColor(.textPrimary)
                
                Text("We need a few details to personalize your experience")
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 20) {
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
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}