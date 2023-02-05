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
        VStack(alignment: .center)
        {
                HStack(alignment: .center )
                {
                    HStack()
                   {
                        toolbarToggleButton()
                   }
                   .frame(alignment: .leading)
                    
                    HStack(spacing: 20)
                    {
                        accountsMenu()
                        timelineMenu()
                        Filters()
                        refreshButton()
                        NewPostButton(mast:mast)
                    }
                    .opacity(settings.showTimelineToolBar == true ? 1.0 : 0.0)
                    .frame(maxHeight:settings.showTimelineToolBar == true ? 55 : 5)
                    .animation(.easeInOut(duration: 0.25))
                }
                
                SpacerLine(color: settings.theme.minorColor)
                
                if appState.selectedTimeline == .tag
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
                { // How about a timer here that only shows if taking more than 2 seconds
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
    
    @State var lastfetch : TimeLine = TimeLine.home
    
    func getstats() -> [MStatus]
    {
        if stats.count == 0 || lastfetch != appState.selectedTimeline
        {
            let group = DispatchGroup()
            group.enter()
            
            DispatchQueue.global(qos: .userInitiated).async
            {
                timelineTimer?.invalidate()
                
                fetchSomeStatuses(timeline: appState.selectedTimeline, tag: appState.currentTag)
                lastfetch = appState.selectedTimeline
                
                runTasks()
                
                group.leave()
            }
            
            group.wait()
        }
        
        return stats
    }
     
    
    func getnotifications() -> [MNotification]
    {
        return notifications
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
    
    
    func fetchNewerStatuses(timeline:TimeLine,tag:String)
    {
        if loadingStats == true { return }
        loadingStats = true
        
        Task
        {
            var nomore = false
            
            while(nomore == false)
            {
                if let first = stats.first
                {
                    let newerThanID = first.status.id
                    
                    mast.getNewerStatuses(timeline: timeline, id:newerThanID, tag: tag, done:
                    { newerstats in
                        print("NEW STATUSES \(newerstats.count) newthanid: \(newerThanID)")
                        if newerstats.count > 0
                        {
                            stats = newerstats + stats
                            
                            if stats.count > 150
                            {
                                print("removing last 50 from stats")
                                stats.removeLast(50)
                            }
                        }
                        else
                        {
                            nomore = true
                        }
                    })
                }
                
                if nomore == false
                {
                    try await Task.sleep(for: .seconds(4))
                }
            }
            
            loadingStats = false
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
                if olderstats[0].status.id == olderThanID
                {
                    print("DUPE OLDER") // Mastodon API bug?
                }
                else
                {
                    stats = stats + olderstats
                    loadingStats = false
                }
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
    
    func refreshButton() -> some View
    {
        PopButton(text: "Refresh", icon: "arrow.triangle.2.circlepath",isSelected: false)
        {
            fetchNewerStatuses(timeline: appState.selectedTimeline, tag: appState.currentTag)
        }
    }
    
    
    func toolbarToggleButton() -> some View
    {
        PopButtonColor(text: "", icon: "ellipsis.rectangle", textColor: settings.theme.minorColor, iconColor: settings.theme.minorColor,isSelected: false)
        {
            settings.showTimelineToolBar.toggle()
            UserDefaults.standard.set(settings.showTimelineToolBar, forKey: "showtimelinetoolbar")
        }
        .padding(EdgeInsets(top: 0.5, leading: 0.5, bottom: 0, trailing: 0))
    }
    
    func accountsMenu() -> some  View
    {
        var popitems = [PopMenuItem<LocalAccountRecord>]()
        
        if let accounts = mast.localAccountRecords
        {
            for account in accounts
            {
                let popitem = PopMenuItem<LocalAccountRecord>(text: "@\(account.username)",userData: account)
                popitems.append(popitem)
            }
        }
        else
        {
            let popitem = PopMenuItem<LocalAccountRecord>(text: "@Add Account",userData: nil)
            popitems.append(popitem)
        }
        
        return PopMenu(icon: "person.crop.circle",selected:"@\(mast.localAccountRecords?[0].username ?? "Add Account")",menuItems:popitems)
            { item in
            }
    }

        
    func timelineMenu() -> some View
    {
        PopMenu(icon: "clock.arrow.circlepath",selected:appState.selectedTimeline.rawValue,
                menuItems: [PopMenuItem(text: TimeLine.home.rawValue,userData:TimeLine.home),
                            PopMenuItem(text: TimeLine.localTimeline.rawValue,userData:TimeLine.localTimeline),
                            PopMenuItem(text: TimeLine.publicTimeline.rawValue,userData:TimeLine.publicTimeline),
                            PopMenuItem(text: TimeLine.tag.rawValue,userData:TimeLine.tag),
                            PopMenuItem(text: TimeLine.favorites.rawValue,userData:TimeLine.favorites),
                            PopMenuItem(text: TimeLine.bookmarks.rawValue,userData:TimeLine.bookmarks),
                            PopMenuItem(text: TimeLine.notifications.rawValue,userData:TimeLine.notifications),
                            PopMenuItem(text: TimeLine.mentions.rawValue,userData:TimeLine.mentions),
                           ])
        { item in
            if item.userData == TimeLine.tag
            {
                appState.selectedTimeline = TimeLine.tag
                if appState.currentTag.count > 0
                {
                    showLoading = true
                    fetchSomeStatuses(timeline:.tag,tag:appState.currentTag)
                }
            }
            else
            {
                if let timeline = TimeLine(rawValue: item.text)
                {
                    showLoading = true
                    appState.selectedTimeline = timeline
                    fetchSomeStatuses(timeline:timeline,tag:appState.currentTag)
                }
            }
        }
    }
    
}

