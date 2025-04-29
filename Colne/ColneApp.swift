//
//  ColneApp.swift
//  Colne
//
//  Created by Gracjan Baryla on 29/04/2025.
//

import SwiftUI
import FamilyControls

@main
struct ColneApp: App {
    
    let center = AuthorizationCenter.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task{
                    do {
                        try await center.requestAuthorization(for: .individual)
                    } catch {
                        print("Failed to get Authorization: \(error)")
                    }
                }
        }
    }
}
