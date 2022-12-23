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

    
    @State private var selectedTimeline : TimeLine = .home
    @State private var stats1 = [MStatus]()
    @State private var stats2 = [MStatus]()
    @State private var stats3 = [MStatus]()
    @State private var stats4 = [MStatus]()
    @State private var newPost : String = ""
    
    var body: some View
    {
        
        ZStack()
        {
            ScrollView
            {
                ForEach(getstats(timeline: $selectedTimeline))
                { mstat in
                    Post(mstat:mstat,settings: settings)
                        .padding(.horizontal)
                        .padding(.top)
                }
            }
            .task
            {
                fetchStatuses(timeline: TimeLine.home)
                Task
                {
                    fetchStatuses(timeline: TimeLine.localTimeline)
                    fetchStatuses(timeline: TimeLine.publicTimeline)
                    fetchStatuses(timeline: TimeLine.tag)
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
                    NewPost(mast: mast,selectedTimeline: $selectedTimeline)
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
    
    func getstats(timeline:Binding<TimeLine>) -> [MStatus]
    {
        switch timeline.wrappedValue
        {
        case .home:
            return stats1
        case .localTimeline:
            return stats2
        case .publicTimeline:
            return stats3
        case .tag:
            return stats4
        }
    }
        
    func fetchStatuses(timeline:TimeLine)
    {
        mast.getTimeline(timeline: timeline,done:
        { newstats in
            switch timeline
            {
            case .home:
                stats1 = newstats
            case .localTimeline:
                stats2 = newstats
            case .publicTimeline:
                stats3 = newstats
            case .tag:
                stats4 = newstats
            }
        })
    }
}

