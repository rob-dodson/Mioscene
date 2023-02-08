//
//  TimeLine.swift
//  Miocene
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI

struct TimeLineView: View
{
    @ObservedObject var mast: Mastodon
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @StateObject private var timelineManger = TimelineManager()
    
    @State private var notifications = [MNotification]()
    @State private var favorites = [MStatus]()
    @State private var tags = [MStatus]()
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
                            let request = TimelineRequest(timelineWhen: .current, timeLine: .tag, tag: appState.currentTag)
                            timelineManger.setTimelineRequestAndFetchCurrent(request: request)
                        }
                        .keyboardShortcut(.defaultAction)
                    }
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
                            ForEach(timelineManger.theStats)
                            { mstat in
                                
                                Post(mast:mast,mstat:mstat)
                                    .padding([.horizontal,.top],5)
                                    .onAppear
                                {
                                    if mstat.id == timelineManger.theStats[timelineManger.theStats.count - 1].id
                                    {
                                        timelineManger.getOlderStats()
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear()
                {
                    Task
                    {
                        while(mast.userLoggedIn == false)
                        { // on boarding here
                            try? await Task.sleep(for: .seconds(0.5))
                            print("SLEEP")
                        }
                        print("IN")
                        timelineManger.setTimelineRequestAndFetchCurrent(request: TimelineRequest(timelineWhen: .current, timeLine: .home, tag: "")) // get this request from defaults. last used.
                    }
                }
        }
    }
    
     
    
    func getnotifications() -> [MNotification]
    {
        return notifications
    }
    
    
    
    
    func getSomeNotifications(timeline:TimeLine)
    {
        mast.getNotifications(mentionsOnly:timeline == .mentions ? true : false)
        { mnotes in
            notifications = mnotes
            loadingStats = false
        }
    }
    
    func refreshButton() -> some View
    {
        PopButton(text: "Refresh", icon: "arrow.triangle.2.circlepath",isSelected: false)
        {
            timelineManger.getNewerStats()
        }
    }
    
    
    func toolbarToggleButton() -> some View
    {
        PopButtonColor(text: "", icon: "ellipsis.curlybraces", textColor: settings.theme.minorColor, iconColor: settings.theme.minorColor,isSelected: false)
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
                    let request = TimelineRequest(timelineWhen: .current, timeLine: .tag, tag: appState.currentTag)
                    timelineManger.setTimelineRequestAndFetchCurrent(request: request)
                }
            }
            else
            {
                if let timeline = TimeLine(rawValue: item.text)
                {
                    let request = TimelineRequest(timelineWhen: .current, timeLine: timeline, tag: "")
                    timelineManger.setTimelineRequestAndFetchCurrent(request: request)
                }
            }
        }
    }
    
}

