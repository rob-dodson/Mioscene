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

    
    var body: some View
    {
        NavigationSplitView
        {
            List()
            {
                //
                // Timeline (home)
                //
                NavigationLink { TimeLineView(mast: mast) }
            label:
                {
                    HStack
                    {
                        Image(systemName: "house.fill")
                        Text("Timelines")
                            .font(.headline)
                            .foregroundColor(settings.theme.nameColor)
                        
                    }
                }
                
                
                //
                // Settings
                //
                NavigationLink { TimeLineView(mast: mast) }
            label:
                {
                    HStack
                    {
                        Image(systemName: "gear")
                        Text("Settings")
                            .font(.headline)
                            .foregroundColor(settings.theme.nameColor)
                        
                    }
                }
                
                
                //
                // Account
                //
                NavigationLink { AccountView(mast: mast) }
            label:
                {
                    HStack
                    {
                        Image(systemName: "person.crop.circle")
                        Text("Accounts")
                            .font(.headline)
                            .foregroundColor(settings.theme.nameColor)
                    }
                }
                
                
                //
                // Search
                //
                NavigationLink { SearchView(mast: mast) }
            label:
                {
                    HStack
                    {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                            .font(.headline)
                            .foregroundColor(settings.theme.nameColor)
                    }
                }
            }
        }
        detail:
        {
            
        }

    }
    
}

