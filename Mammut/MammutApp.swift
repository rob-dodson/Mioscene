//
//  MammutApp.swift
//  Mammut
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI

@main
struct MammutApp: App
{
    @StateObject private var mast : Mastodon = Mastodon.shared

    var body: some Scene
    {
        WindowGroup
        {
            ContentView(mast: mast)
        }
    }
    
    static func openCurrentUserAccountURL()
    {
        if let url = URL(string:Mastodon.shared.getCurrentUserAccount().url)
        {
            NSWorkspace.shared.open(url)
        }
    }
}
