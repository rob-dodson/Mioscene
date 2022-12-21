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
    
    @State private var selectedTimeline : TimeLine = .home
    @State private var stats = [MStatus]()
    
    var body: some View
    {
        
        ZStack()
        {
            ScrollView
            {
                ForEach(stats)
                { mstat in
                    Post(mstat:mstat)
                        .padding(.horizontal)
                        .padding(.top)
                }
            }
        }
        .toolbar
        {
                //
                // account
                //
                ToolbarItem
                {
                    Picker(selection: .constant(1),label: Text("Account"),content:
                            {
                        Text("@rdodson").tag(1)
                        Text("@frogradio").tag(2)
                        Text("Add Account...").tag(3)
                    })
                }
                
                
                //
                // timeline
                //
                ToolbarItem
                {
                    Picker("Timeline",selection: $selectedTimeline)
                            {
                                ForEach(TimeLine.allCases)
                                { timeline in
                                       Text(timeline.rawValue.capitalized)
                                }
                            }
                }
                
                
                //
                // new post
                //
                ToolbarItem
                {
                    Button
                    {
                        MammutApp.openCurrentUserAccountURL()
                    }
                label:
                    {
                        Image(systemName: "square.and.pencil")
                    }
                }
                
                
                //
                // search
                //
                ToolbarItem
                {
                    Button
                    {
                        MammutApp.openCurrentUserAccountURL()
                    }
                label:
                    {
                        Image(systemName: "magnifyingglass")
                    }
                    
                }
                
                //
                // settings
                //
                ToolbarItem
                {
                    Button
                    {
                    }
                label:
                    {
                        Image(systemName: "gearshape")
                    }
                }
        }
    }
    

    func fetchStatuses(timeline:Binding<TimeLine>) -> [MStatus]
    {
        mast.getTimeline(timeline: selectedTimeline,done:
        { newstats in
            stats = newstats
        })
    }

}

