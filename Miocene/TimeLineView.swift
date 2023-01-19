//
//  TimeLine.swift
//  Miocene
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI



struct TimeLineView: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings: Settings

    
    @State private var stats1 = [MStatus]()
    @State private var stats2 = [MStatus]()
    @State private var stats3 = [MStatus]()
    @State private var notifications = [MNotification]()
    @State private var favorites = [MStatus]()
    @State private var tags = [MStatus]()
    @State private var showLoading = true
    @State private var showTagAsk = false
    @State private var taskRunning = false
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Picker(selection: .constant(1),label: Text("Account"),content:
                {
                    Text("@rdodson").tag(1)
                    Text("@FrogradioHQ").tag(2)
                })
                
                Picker("Timeline",selection: $settings.selectedTimeline)
                {
                    ForEach(TimeLine.allCases)
                    { timeline in
                        Text(timeline.rawValue.capitalized)
                    }
                }
                .onChange(of: settings.selectedTimeline)
                { newValue in
                    if settings.selectedTimeline == .tag
                    {
                        showTagAsk = true
                        if settings.currentTag.count > 0
                        {
                            fetchStatuses(timeline:newValue,tag:settings.currentTag)
                        }
                    }
                    else
                    {
                        showTagAsk = false
                        fetchStatuses(timeline:newValue,tag:settings.currentTag)
                    }
                }
                 
                NewPostButton(mast:mast)
                        
             }
            .padding()
            
            SpacerLine(color: settings.theme.minorColor)
            
            if showTagAsk == true
            {
                HStack
                {
                    TextField("#tag", text: $settings.currentTag)
                        .padding()
                        .font(settings.font.title)
                    
                    Button("Load")
                    {
                        fetchStatuses(timeline:.tag,tag:settings.currentTag)
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            
            if showLoading
            {
                
                ProgressView("Loading...")
                    .font(settings.font.title)
                    .foregroundColor(settings.theme.accentColor)
            }

            ScrollView
            {
                if settings.selectedTimeline == .notifications
                {
                    ForEach(getnotifications())
                    { note in
                        NotificationView(mast:mast,mnotification:note)
                            .padding([.horizontal,.top])
                    }
                }
                else
                {
                    ForEach(getstats(timeline: $settings.selectedTimeline))
                    { mstat in
                        Post(mast:mast,mstat:mstat)
                            .padding([.horizontal,.top])
                    }
                }
            }
            .task
            {
                loadStatuses()
            }
        }
    }
    
   
    
    func loadStatuses()
    {
        print("TASK \(taskRunning)")
        if taskRunning == true
        {
            return
        }
        
        Task
        {
            taskRunning = true
            
            while(true)
            {
                fetchStatuses(timeline: settings.selectedTimeline,tag:settings.currentTag)
                try await Task.sleep(nanoseconds: 60 * 15 * NSEC_PER_SEC)
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
        case .favorites:
            return favorites
        case .tag:
            return tags
        case .notifications:
            Log.log(msg:"error 1")
            return []
        }
    }
     
    func getnotifications() -> [MNotification]
    {
        return notifications
    }
    
    func fetchStatuses(timeline:TimeLine,tag:String)
    {
        showLoading = true
        
        if timeline == .notifications
        {
            mast.getNotifications
            { mnotes in
                
                showLoading = false
                
                notifications = mnotes
            }
        }
        else
        {
            mast.getTimeline(timeline: timeline,tag:tag,done:
                                { newstats in
                
                showLoading = false
                
                switch timeline
                {
                case .home:
                    stats1 = newstats
                case .localTimeline:
                    stats2 = newstats
                case .publicTimeline:
                    stats3 = newstats
                case .favorites:
                    favorites = newstats
                case .tag:
                    tags = newstats
                case .notifications:
                    Log.log(msg:"error 2")
                }
            })
        }
    }
}

