//
//  ContentView.swift
//  Mammut
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit


struct ContentView: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings: Settings
    
    @State private var tabselection = 0
    
    var body: some View
    {
        TabView(selection: $tabselection)
        {
            TimeLineView(mast: mast)
            .tabItem
            {
                Label("Timelines", systemImage: "house.fill")
            }
            .tag(0)
            
            AccountView(mast: mast)
            .tabItem
            {
                Label("Accounts", systemImage: "person.crop.circle")
            }
            .tag(1)
            
            SearchView(mast: mast)
            .tabItem
            {
                Label("Search", systemImage: "magnifyingglass")
            }
            .tag(2)
            
            SettingsView(mast: mast)
            .tabItem
            {
                Label("Settings", systemImage: "gear")
            }
            .tag(3)
        }
        .accentColor(settings.theme.accentColor)
        .padding()
    }
}

