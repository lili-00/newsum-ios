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
    // Remove CoreData related properties if no longer needed
    // @Environment(\.managedObjectContext) private var vContext
    // @FetchRequest(
    //     sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
    //     animation: .default)
    // private var items: FetchedResults<Item>

    var body: some View {
        TabView {
            HeadlineListView()
                .tabItem {
                    Label("Headlines", systemImage: "newspaper") // Use newspaper icon
                }

            InfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle") // Use info icon
                }
        }
    }
}

#Preview {
    ContentView()
    // Remove CoreData environment setup if no longer needed
    // .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
