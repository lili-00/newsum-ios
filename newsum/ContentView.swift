//
//  ContentView.swift
//  newsum
//
//  Created by Li Li on 4/16/25.
//

import SwiftUI
// Remove CoreData imports if no longer needed here
// import CoreData

struct ContentView: View {
    @AppStorage("textSizeMultiplier") private var textSizeMultiplier: Double = 1.0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Configure tab bar appearance at initialization time
        configureTabBarAppearance()
    }

    var body: some View {
        TabView {
            HeadlineListView()
                .tabItem {
                    Label("Headlines", systemImage: "newspaper")
                }
                .environment(\.sizeCategory, sizeCategory)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            // Update again when the view appears just to be sure
            configureTabBarAppearance()
        }
        // Watch for color scheme changes
        .onChange(of: colorScheme) { newColorScheme in
            // Force immediate update when color scheme changes
            configureTabBarAppearance()
        }
        // Also watch for scene phase changes, which can happen during system appearance changes
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                configureTabBarAppearance()
            }
        }
    }
    
    // Private method to configure tab bar appearance based on current color scheme
    private func configureTabBarAppearance() {
        // Create new appearance object each time to ensure changes take effect
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        
        // Get current appearance directly rather than relying on stored property
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        
        // Set background color based on current mode
        tabBarAppearance.backgroundColor = isDarkMode ? .black : .white
        
        // Apply appearance to both standard and scrollEdge states
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Force appearance update
        UITabBar.appearance().tintColor = UIColor.systemBlue
    }
    
    // Computed property to transform the slider value to a dynamic type size
    private var sizeCategory: ContentSizeCategory {
        switch textSizeMultiplier {
        case 0.8: return .small
        case 0.9: return .medium
        case 1.0: return .large
        case 1.1: return .extraLarge
        case 1.2: return .extraExtraLarge
        case 1.3: return .extraExtraExtraLarge
        case 1.4: return .accessibilityMedium
        default: return .large
        }
    }
}

#Preview {
    ContentView()
    // Remove CoreData environment setup if no longer needed
    // .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
