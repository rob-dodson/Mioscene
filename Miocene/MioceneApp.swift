//
//  MioceneApp.swift
//
//  Created by Robert Dodson on 12/16/22.
//

/*
 
 Use @State for very simple data like Int, Bool, or String. Think situations like whether a toggle is on or off, or whether a dialog is open or closed.
 Use @StateObject to create any type that is more complex than what @State can handle. Ensure that the type conforms to ObservableObject, and has @Published wrappers on the properties you would like to cause the view to re-render, or you’d like to update from a view. Always use @StateObject when you are instantiating a model.
 Use @ObservedObject to allow a parent view to pass down to a child view an already created ObservableObject (via @StateObject).
 Use @EnvironmentObject to consume an ObservableObject that has already been created in a parent view and then attached via the view’s environmentObject() view modifier.
 */

import SwiftUI


@main
struct MioceneApp: App
{
    @StateObject private var mast = Mastodon()
    @StateObject var settings = Settings()
    @StateObject var errorSystem = ErrorSystem()
    @StateObject var appState = AppState()
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView(mast: mast).environmentObject(settings).environmentObject(errorSystem).environmentObject(appState)
        }
    }
}
