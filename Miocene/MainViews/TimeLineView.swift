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
    @EnvironmentObject var appState: AppState
    
    @State private var stats1 = [MStatus]()
    @State private var stats2 = [MStatus]()
    @State private var stats3 = [MStatus]()
    @State private var notifications = [MNotification]()
    @State private var favorites = [MStatus]()
    @State private var tags = [MStatus]()
    @State private var showLoading = true
    @State private var showTagAsk = false
    @State private var taskRunning = false
    @State private var numTabs = 3
    @State private var showingpopup : Bool = false
    
    var body: some View
    {
            mainView()
    }
    
    
    func mainView() -> some View
    {
        VStack
        {
            HStack(spacing: 20)
            {
                
                if let accounts = mast.localAccountRecords
                {
                    PopMenu(icon: "person.crop.circle",
                            menuItems: [PopMenuItem(text: accounts[0].username),
                                       ])
                    { item in
                    }
                }
                
             
                PopMenu(icon: "clock.arrow.circlepath",
                        menuItems: [PopMenuItem(text: TimeLine.home.rawValue),
                                    PopMenuItem(text: TimeLine.localTimeline.rawValue),
                                    PopMenuItem(text: TimeLine.publicTimeline.rawValue),
                                    PopMenuItem(text: TimeLine.tag.rawValue),
                                    PopMenuItem(text: TimeLine.favorites.rawValue),
                                    PopMenuItem(text: TimeLine.mentions.rawValue),
                                   ])
                { item in
                    if item.text == TimeLine.tag.rawValue
                    {
                        appState.selectedTimeline = TimeLine.tag
                        showTagAsk = true
                        if appState.currentTag.count > 0
                        {
                            fetchStatuses(timeline:.tag,tag:appState.currentTag)
                        }
                    }
                    else
                    {
                        showTagAsk = false
                        if let timeline = TimeLine(rawValue: item.text)
                        {
                            appState.selectedTimeline = timeline
                            fetchStatuses(timeline:timeline,tag:appState.currentTag)
                        }
                    }
                }
                
                Filters()
                
                NewPostButton(mast:mast)
            }
            
           
            
            SpacerLine(color: settings.theme.minorColor)
            
            if showTagAsk == true
            {
                HStack
                {
                    TextField("#tag", text: $appState.currentTag)
                        .padding()
                        .font(settings.font.title)
                    
                    Button("Load")
                    {
                        fetchStatuses(timeline:.tag,tag:appState.currentTag)
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
                if appState.selectedTimeline == .notifications || appState.selectedTimeline == .mentions
                {
                    ForEach(getnotifications())
                    { note in
                        NotificationView(mast:mast,mnotification:note)
                            .padding([.horizontal,.top],5)
                    }
                }
                else
                {
                    ForEach(getstats(timeline: $appState.selectedTimeline))
                    { mstat in
                        Post(mast:mast,mstat:mstat)
                            .padding([.horizontal,.top],5)
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
        if taskRunning == true
        {
            return
        }
        
        Task
        {
            taskRunning = true
            
            while(true)
            {
                fetchStatuses(timeline: appState.selectedTimeline,tag:appState.currentTag)
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
        case .mentions:
            Log.log(msg:"error mentions 1")
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
        
        if timeline == .notifications || timeline == .mentions
        {
            mast.getNotifications(mentionsOnly:timeline == .mentions ? true : false)
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
                case .mentions:
                    Log.log(msg:"error 3")
                }
            })
        }
    }
}

