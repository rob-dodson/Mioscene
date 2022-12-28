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
    @ObservedObject var settings: Settings

    
    var body: some View
    {
        NavigationStack
        {
            List()
            {
                NavigationLink { TimeLineView(mast: mast, settings: settings) }
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
                
                NavigationLink { TimeLineView(mast: mast, settings: settings) }
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
                
                NavigationLink { AccountView(mast: mast, settings: settings) }
                label:
                {
                    HStack
                    {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                            .font(.headline)
                            .foregroundColor(settings.theme.nameColor)
                    }
                }

            }
        }
    }
    
}

