//
//  SafeZoneApp.swift
//  SafeZone
//
//  Created by Алуа Жолдыкан on 03.08.2025.
//

import SwiftUI

@main
struct SafeZoneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
