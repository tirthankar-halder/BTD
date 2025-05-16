//
//  BTDApp.swift
//  BTD
//
//  Created by Tirthankar Halder on 2025-05-16.
//

import SwiftUI

@main
struct BTDApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                EntryView() // Only define the TabView here
            }
        }
    }
}
