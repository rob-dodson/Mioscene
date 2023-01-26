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
    
    @State private var stats = [MStatus]()
    @State private var notifications = [MNotification]()
    @State private var favorites = [MStatus]()
    @State private var tags = [MStatus]()
    @State private var showLoading = true
    @State private var showTagAsk = false
    @State private var loadingStats = false
    @State private var showingpopup : Bool = false
    
    static var taskRunning = false
    
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
                                menuItems: [PopMenuItem(text: "@\(accounts[0].username)"),
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
                                fetchSomeStatuses(timeline:.tag,tag:appState.currentTag)
                            }
                        }
                        else
                        {
                            showTagAsk = false
                            if let timeline = TimeLine(rawValue: item.text)
                            {
                                appState.selectedTimeline = timeline
                                fetchSomeStatuses(timeline:timeline,tag:appState.currentTag)
                            }
                        }
                    }
                    
                    Filters()
                    
                    NewPostButton(mast:mast)
                    
                    //RefreshButton
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
                            fetchSomeStatuses(timeline:.tag,tag:appState.currentTag)
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
                    LazyVStack
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
                            ForEach(getstats())
                            { mstat in
                                
                                Post(mast:mast,mstat:mstat)
                                    .padding([.horizontal,.top],5)
                                    .onAppear
                                    {
                                        if mstat.id == stats[stats.count - 1].id
                                        {
                                            fetchOlderStatuses(timeline: appState.selectedTimeline, tag: appState.currentTag)
                                        }
                                    }
                            }
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
        if TimeLineView.taskRunning == true
        {
            return
        }
        
        Task
        {
            TimeLineView.taskRunning = true
            
            fetchSomeStatuses(timeline: appState.selectedTimeline, tag: appState.currentTag)
            
            while(true)
            {
                try await Task.sleep(nanoseconds: 30 * NSEC_PER_SEC)
                fetchNewerStatuses(timeline: appState.selectedTimeline,tag:appState.currentTag)
            }
        }
    }
    
    func getstats() -> [MStatus]
    {
        return stats
    }
    
     
    func getnotifications() -> [MNotification]
    {
        return notifications
    }
    
    func fetchNewerStatuses(timeline:TimeLine,tag:String)
    {
        if loadingStats == true { return }
        
        loadingStats = true
        if let first = stats.first
        {
            let newerThanID = first.status.id
            mast.getNewerStatuses(timeline: timeline, id:newerThanID, tag: tag, done:
           { newerstats in
                stats = newerstats + stats
                loadingStats = false
            })
        }
    }
    
    func fetchOlderStatuses(timeline:TimeLine,tag:String)
    {
        if loadingStats == true { return }
        
        loadingStats = true
        if let last = stats.last
        {
            let olderThanID = last.status.id
            mast.getOlderStatuses(timeline: timeline, id:olderThanID, tag: tag, done:
           { olderstats in
                stats = stats + olderstats
                loadingStats = false
            })
        }
    }
    
    func fetchSomeStatuses(timeline:TimeLine,tag:String)
    {
        if loadingStats == true { return }
        
        loadingStats = true
        mast.getSomeStatuses(timeline: timeline, tag: tag, done:
        { somestats in
            showLoading = false
            stats = somestats
            loadingStats = false
        })
    }
    
    /*
    func fetchSomeStatuses(timeline:TimeLine,tag:String)
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
                stats = stats + newstats
            })
        }
    }
     */
}

