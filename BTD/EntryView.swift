//
//  ContentView.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-16.
//

import SwiftUI
import AVFoundation

struct StepItem: Identifiable {
    let id = UUID()
    let text: String
    var isExpanded: Bool = false
    var isDone: Bool = false
}


enum Tab {
    case home, results, about, contact
}

struct MainTabView: View {
    @State private var responseSteps: [StepItem] = []
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            
            NavigationStack {
                QueryScreen(responseSteps: $responseSteps, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(Tab.home)

            NavigationStack {
                ResultView(steps: $responseSteps)
            }
            .tabItem {
                Label("Results", systemImage: "magnifyingglass")
            }
            .tag(Tab.results)

            NavigationStack {
                AboutUsView()
            }
            .tabItem {
                Label("About Us", systemImage: "person.fill")
            }
            .tag(Tab.about)

            NavigationStack {
                ContactUsView()
            }
            .tabItem {
                Label("Contact Us", systemImage: "phone.fill")
            }
            .tag(Tab.contact)
        }
        .accentColor(.yellow) // 🔶 Highlight selected tab in yellow
    }
}



struct EntryView: View {
    @State private var MainScreen = false

    private let backgroundColor = Color(red: 12/255, green: 17/255, blue: 15/255)
    
    var body: some View {
           ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                Image("BTDLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Version 1.0")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding(.top,130)
                
            }
           .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect().first()) { _ in
               print("Navigating...")
                MainScreen = true
            }
            .navigationDestination(isPresented: $MainScreen) {
                MainTabView()
                .onAppear {
                            setupTabBarAppearance()
                                    }
            }
        }
    }

func setupTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor.black // Background color
    
    // Define your custom yellow
        let customYellow = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)

    // Setting icon and text colors to white
    appearance.stackedLayoutAppearance.normal.iconColor = .white
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    
    appearance.stackedLayoutAppearance.selected.iconColor = customYellow
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: customYellow]
    
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
}
    
#Preview {
        EntryView()
    }

    
