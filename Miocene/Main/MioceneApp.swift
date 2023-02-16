//
//  MioceneApp.swift
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI

@main
struct MioceneApp: App
{
    @StateObject private var mast = Mastodon.shared
    @StateObject var settings = Settings()
    @StateObject var errorSystem = ErrorSystem()
    @StateObject var appState = AppState.shared 
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView(mast: mast).environmentObject(settings).environmentObject(errorSystem).environmentObject(appState)
        }
    }
}

