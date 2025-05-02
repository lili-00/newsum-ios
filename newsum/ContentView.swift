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
