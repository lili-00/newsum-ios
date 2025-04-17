//
//  newsumApp.swift
//  newsum
//
//  Created by Li Li on 4/16/25.
//

import SwiftUI

@main
struct newsumApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
