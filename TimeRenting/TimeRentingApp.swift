//
//  TimeRentingApp.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 9/17/24.
//

import SwiftUI

@main
struct TimeRentingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext) // Inject viewContext
        }
    }
}
