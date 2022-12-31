//
//  TimeLine.swift
//  Mammut
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI

struct TimeLineView: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings: Settings

    @State private var selectedTimeline : TimeLine = .home
    @State private var stats1 = [MStatus]()
    @State private var stats2 = [MStatus]()
    @State private var stats3 = [MStatus]()
    @State private var notifications = [MStatus]()
    
    var body: some View
    {
        ZStack
        {
            ScrollView
            {
                ForEach(getstats(timeline: $selectedTimeline))
                { mstat in
                    Post(mstat:mstat)
                        .padding(.horizontal)
                        .padding(.top)
                }
            }
            .task
            {
                Task
                {
                    while(true)
                    {
                        fetchStatuses(timeline: selectedTimeline)
                        try await Task.sleep(nanoseconds: 60 * 15 * NSEC_PER_SEC)
                    }
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
                .onChange(of: selectedTimeline)
                { newValue in
                    fetchStatuses(timeline:newValue)
                }
            }
            
            
            //
            // new post
            //
            ToolbarItem
            {
                NewPost(mast: mast, selectedTimeline: $selectedTimeline)
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
        case .notifications:
            return notifications
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
            case .notifications:
                notifications = newstats
            }
        })
    }
}

