//
//  MioceneApp.swift
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI


@main
struct MioceneApp: App
{
    @StateObject var settings      = Settings()
    @StateObject var alertSystem   = AlertSystem()
    @StateObject var appState      = AppState()
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView().environmentObject(settings).environmentObject(alertSystem).environmentObject(appState)
        }
    }
}

