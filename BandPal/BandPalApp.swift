//
//  BandPalApp.swift
//  BandPal
//
//  Created by Timo Engelvaart on 25/10/2023.
//

import SwiftUI
import SwiftData

@main
struct BandPalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Setlist.self,
            Song.self,
            Band.self,
            BandMember.self,
            Rehearsal.self
        ])

        // Configure SwiftData to NOT use CloudKit - BandSharingManager handles CloudKit separately
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
