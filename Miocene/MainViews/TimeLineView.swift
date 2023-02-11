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
    
    @State private var showingpopup : Bool = false
    
    @State var currentTag = String() // move this into TimeLineManager?
    @State var selectedTimeline : TimeLine = .home

    
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
                        FiltersView()
                        refreshButton()
                        NewPostButton(mast:mast)
                    }
                    .opacity(settings.showTimelineToolBar == true ? 1.0 : 0.0)
                    .frame(maxHeight:settings.showTimelineToolBar == true ? 55 : 5)
                    .animation(.easeInOut(duration: 0.25))
                }
                
                SpacerLine(color: settings.theme.minorColor)
                
                if selectedTimeline == .tag
                {
                    handleTagInput()
                }
                
                ScrollView
                {
                    LazyVStack
                    {
                        if selectedTimeline == .notifications || selectedTimeline == .mentions
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
                        {
                            try? await Task.sleep(for: .seconds(0.25))
                        }
                        
                        timelineManger.start()
                        timelineManger.setTimelineRequestAndFetch(request: TimelineRequest(timelineWhen: .current, timeLine: .home, tag: "")) // get this request from defaults. last used.
                    }
                }
        }
    }
    
     
    func handleTagInput() -> some View
    {
        HStack
        {
            TextField("#tag", text: $currentTag)
                .padding()
                .font(settings.font.title)
                .onSubmit
            {
                let request = TimelineRequest(timelineWhen: .current, timeLine: .tag, tag: currentTag)
                timelineManger.setTimelineRequestAndFetch(request: request)
            }
            
            PopButton(text: "Load", icon: "paperplane.fill", isSelected: true)
            {
                let request = TimelineRequest(timelineWhen: .current, timeLine: .tag, tag: currentTag)
                timelineManger.setTimelineRequestAndFetch(request: request)
            }
        }
        .padding([.trailing],25)
        .onAppear()
        {
            timelineManger.clearTimeline()
        }
    }
    
    
    func getnotifications() -> [MNotification]
    {
        return timelineManger.theNotifications
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
        PopButtonColor(text: "", icon: "ellipsis.circle", textColor: settings.theme.minorColor, iconColor: settings.theme.minorColor,isSelected: false)
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
        let customSubMenu = PopMenu(icon: "person",selected:selectedTimeline.rawValue,
                                    menuItems: [PopMenuItem(text: "Custom1",userData:"custom1"),
                                            PopMenuItem(text: "Custom2",userData:"custom1"),
                                             PopMenuItem(text: "Custom3",userData:"custom1"),
                                                PopMenuItem(text: "Custom4",userData:"custom1"),
                                                ])
        { iten in
            
        }
        
        return PopMenu(icon: "clock.arrow.circlepath",selected:selectedTimeline.rawValue,
                menuItems: [PopMenuItem(text: TimeLine.home.rawValue,userData:TimeLine.home.rawValue),
                            PopMenuItem(text: TimeLine.localTimeline.rawValue,userData:TimeLine.localTimeline.rawValue),
                            PopMenuItem(text: TimeLine.publicTimeline.rawValue,userData:TimeLine.publicTimeline.rawValue),
                            PopMenuItem(text: TimeLine.tag.rawValue,userData:TimeLine.tag.rawValue),
                            PopMenuItem(text: TimeLine.favorites.rawValue,userData:TimeLine.favorites.rawValue),
                            PopMenuItem(text: TimeLine.bookmarks.rawValue,userData:TimeLine.bookmarks.rawValue),
                            PopMenuItem(text: TimeLine.notifications.rawValue,userData:TimeLine.notifications.rawValue),
                            PopMenuItem(text: TimeLine.mentions.rawValue,userData:TimeLine.mentions.rawValue),
                            PopMenuItem(text: "Custom",userData:"custom",subMenu: customSubMenu),
                           ])
        { item in
            
            if let timeline = TimeLine(rawValue: item.text)
            {
                timelineManger.clearTimeline()
                
                selectedTimeline = timeline
                
                let request = TimelineRequest(timelineWhen: .current, timeLine: timeline, tag: currentTag)
                timelineManger.setTimelineRequestAndFetch(request: request)
            }
            else if item.text.hasPrefix("Custom")
            {
                print ("\(item.text)")
            }
        }
    }
    
}

