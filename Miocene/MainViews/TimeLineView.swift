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
    @State private var timelineTimer : Timer?
    
    static var taskRunning = false
    
    var body: some View
    {
        mainView()
    }
    
    
    func mainView() -> some View
    {
        VStack(alignment: .leading)
            {
                HStack
                {
                    PopButtonColor(text: "", icon: "ellipsis.rectangle", textColor: settings.theme.minorColor, iconColor: settings.theme.minorColor)
                    {
                        settings.showTimelineToolBar.toggle()
                        UserDefaults.standard.set(settings.showTimelineToolBar, forKey: "showtimelinetoolbar")
                    }
                    .padding(EdgeInsets(top: 0.5, leading: 0.5, bottom: 0, trailing: 0))
                    
                    HStack(spacing: 20)
                    {
                        
                        if let accounts = mast.localAccountRecords
                        {
                            PopMenu(icon: "person.crop.circle",selected:"@\(accounts[0].username)",
                                    menuItems: [PopMenuItem(text: "@\(accounts[0].username)",userData: accounts[0]),
                                               ])
                            { item in
                            }
                        }
                        
                        
                        PopMenu(icon: "clock.arrow.circlepath",selected:appState.selectedTimeline.rawValue,
                                menuItems: [PopMenuItem(text: TimeLine.home.rawValue,userData:TimeLine.home),
                                            PopMenuItem(text: TimeLine.localTimeline.rawValue,userData:TimeLine.localTimeline),
                                            PopMenuItem(text: TimeLine.publicTimeline.rawValue,userData:TimeLine.publicTimeline),
                                            PopMenuItem(text: TimeLine.tag.rawValue,userData:TimeLine.tag),
                                            PopMenuItem(text: TimeLine.favorites.rawValue,userData:TimeLine.favorites),
                                            PopMenuItem(text: TimeLine.notifications.rawValue,userData:TimeLine.notifications),
                                            PopMenuItem(text: TimeLine.mentions.rawValue,userData:TimeLine.mentions),
                                           ])
                        { item in
                            if item.userData == TimeLine.tag
                            {
                                appState.selectedTimeline = TimeLine.tag
                                showTagAsk = true
                                if appState.currentTag.count > 0
                                {
                                    showLoading = true
                                    fetchSomeStatuses(timeline:.tag,tag:appState.currentTag)
                                }
                            }
                            else
                            {
                                showTagAsk = false
                                if let timeline = TimeLine(rawValue: item.text)
                                {
                                    showLoading = true
                                    appState.selectedTimeline = timeline
                                    fetchSomeStatuses(timeline:timeline,tag:appState.currentTag)
                                }
                            }
                        }
                        
                        Filters()
                        
                        PopButton(text: "Refresh", icon: "arrow.triangle.2.circlepath")
                        {
                            fetchNewerStatuses(timeline: appState.selectedTimeline, tag: appState.currentTag)
                        }
                        
                        NewPostButton(mast:mast)
                    }
                    .opacity(settings.showTimelineToolBar == true ? 1.0 : 0.0)
                    .frame(maxHeight:settings.showTimelineToolBar == true ? 55 : 5)
                    .animation(.easeInOut(duration: 0.25))
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
                /*
                if showLoading
                {
                    ProgressView("Loading...")
                        .font(settings.font.title)
                        .foregroundColor(settings.theme.accentColor)
                        .frame(alignment: .center)
                }
                 */
                
                
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
                    runTasks()
                }
        }
    }
    
    
    func runTasks()
    {
        fetchSomeStatuses(timeline: appState.selectedTimeline, tag: appState.currentTag)
        
        if timelineTimer != nil { timelineTimer?.invalidate() }
        
        timelineTimer = Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: true)
        { timer in
            fetchNewerStatuses(timeline: appState.selectedTimeline,tag:appState.currentTag)
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
                
                if stats.count > 150
                {
                    print("removing last 50 from stats")
                    stats.removeLast(50)
                }
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
        
        if timeline == .notifications || timeline == .mentions
        {
            getSomeNotifications(timeline: timeline)
        }
        else
        {
            mast.getSomeStatuses(timeline: timeline, tag: tag, done:
                                    { somestats in
                showLoading = false
                stats = somestats
                loadingStats = false
            })
        }
    }
    
    func getSomeNotifications(timeline:TimeLine)
    {
        mast.getNotifications(mentionsOnly:timeline == .mentions ? true : false)
        { mnotes in
            showLoading = false
            notifications = mnotes
            loadingStats = false
        }
    }
}

