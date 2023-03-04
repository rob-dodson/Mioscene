//
//  TimeLine.swift
//  Miocene
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI

struct TimeLineView: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @StateObject var timelineManger : TimelineManager
    
    @State private var presentAddAccountSheet = false
    @State private var currentSelectedTimeline = "Home"
    @State private var currentAccountServer = "Add Account"
    @State private var saveCurrentAccountServer = "Add Account"
    
    
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
                        NewPostButton()
                    }
                    .opacity(settings.showTimelineToolBar == true ? 1.0 : 0.0)
                    .frame(maxHeight:settings.showTimelineToolBar == true ? 55 : 5)
                    .animation(.easeInOut(duration: 0.25))
                }
                
                SpacerLine(color: settings.theme.minorColor)
                
                if appState.selectedTimeline == .tag
                {
                    handleTagInput()
                }
                
                ScrollView
                {
                    LazyVStack
                    {
                        if appState.selectedTimeline == .notifications || appState.selectedTimeline == .mentions
                        {
                            ForEach(getnotifications())
                            { note in
                                NotificationView(mnotification:note)
                                    .padding([.horizontal,.top],5)
                            }
                        }
                        else
                        {
                            ForEach(timelineManger.theStats)
                            { mstat in
                                
                                Post(mstat:mstat)
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
                        while(appState.userLoggedIn == false)
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
            TextField("#tag", text: $appState.showTag)
                .padding()
                .font(settings.font.title)
                .onSubmit
            {
                let request = TimelineRequest(timelineWhen: .current, timeLine: .tag, tag: appState.showTag)
                timelineManger.setTimelineRequestAndFetch(request: request)
            }
            
            PopButton(text: "Load", icon: "paperplane.fill", isSelected: true,help:"Load Tag Timeline")
            {
                loadTagTimeLine()
            }
        }
        .padding([.trailing],25)
        .onAppear()
        {
            timelineManger.clearTimeline()
            if appState.showTag.count > 0
            {
                loadTagTimeLine()
            }
        }
    }
     
    
    func loadTagTimeLine()
    {
        let request = TimelineRequest(timelineWhen: .current, timeLine: .tag, tag: appState.showTag)
        timelineManger.setTimelineRequestAndFetch(request: request)
    }
    
    
    func getnotifications() -> [MNotification]
    {
        return timelineManger.theNotifications
    }
    
    
    
    func refreshButton() -> some View
    {
        PopButton(text: "Refresh", icon: "arrow.triangle.2.circlepath",isSelected: false,help:"Refresh Timeline")
        {
            timelineManger.getNewerStats()
        }
    }
    
    
    func toolbarToggleButton() -> some View
    {
        PopButtonColor(text: "", icon: "ellipsis.circle", textColor: settings.theme.minorColor, iconColor: settings.theme.minorColor,isSelected: false,help: "Hide/Show Toolbar")
        {
            settings.showTimelineToolBar.toggle()
            UserDefaults.standard.set(settings.showTimelineToolBar, forKey: "showtimelinetoolbar")
        }
        .padding(EdgeInsets(top: 0.5, leading: 0.5, bottom: 0, trailing: 0))
    }
    
    
    func accountsMenu() -> some  View
    {
        var popitems = [PopMenuItem<AccountKey>]()
        _ = AppState.localAccountRecords.values.map()
        {
            let popitem = PopMenuItem<AccountKey>(text: $0.server,help:"Load Account \($0.server)",userData: $0.accountKey())
            popitems.append(popitem)
        }
        popitems.append(PopMenuItem<AccountKey>(text: "Add Account",help:"Add Account",userData: nil))
        
        DispatchQueue.main.async
        {
            if let localrec = appState.currentLocalAccountRecord()
            {
                currentAccountServer = localrec.server
            }
        }
        
        return PopMenu(icon: "person.crop.circle",selected:$currentAccountServer,menuItems:popitems)
        { result in
            
            print("Account Picked: \(result.text)")
            
            if result.text == "Add Account"
            {
                saveCurrentAccountServer = appState.currentLocalAccountRecord()!.server
                presentAddAccountSheet = true
                
            }
            else
            {
                if let accountkey = result.userData
                {
                    timelineManger.clearTimeline()
                    
                    appState.setAccount(accountKey: accountkey)
                    
                    let request = TimelineRequest(timelineWhen: .current, timeLine: appState.selectedTimeline, tag: appState.showTag)
                    timelineManger.setTimelineRequestAndFetch(request: request)
                }
            }
        }
        .sheet(isPresented: $presentAddAccountSheet)
        {
        }
    content:
        {
            AddAccountPanel()
            {
                currentAccountServer = saveCurrentAccountServer
                presentAddAccountSheet = false
            }
        }
    }

        
    func timelineMenu() -> some View
    {
        let filter1 = Filter(name: "macOS", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "macOS", type: .body)
        let filter2 = Filter(name: "#macOS", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "macOS", type: .hashtag)
        let filterset = FilterSet(name: "macOS", filters: [filter1,filter2], setType: .AnyFilter)
        let timelinerequest = TimelineRequest(timelineWhen: .current, timeLine: .localTimeline, tag: "")
        let customtimeline = CustomTimeline(name: "macOS - Local", timelineRequests: [timelinerequest], filterSet: filterset)
        
        let filter0 = Filter(name: "Ivory", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "Ivory", type: .body)
        let filterset0 = FilterSet(name: "Ivory", filters: [filter0], setType: .AnyFilter)
        let timelinerequest0 = TimelineRequest(timelineWhen: .current, timeLine: .home, tag: "")
        let customtimeline0 = CustomTimeline(name: "Ivory - Home", timelineRequests: [timelinerequest0], filterSet: filterset0)
        
        
        
        var custdict = Dictionary<String,CustomTimeline>()
        custdict[customtimeline.name] = customtimeline
        custdict[customtimeline0.name] = customtimeline0
        
        let customSubMenu = PopMenu(icon: "person",selected:$currentSelectedTimeline,
                                    menuItems: [PopMenuItem(text: customtimeline0.name,help:"Filter \(customtimeline0.name)",userData:TimeLine.custom),
                                                PopMenuItem(text: customtimeline.name,help:"Filter \(customtimeline.name)",userData:TimeLine.custom)
                                                ])
        { item in
            print("Custom Sub Menu \(item.text)")
            
            let timeline = custdict[item.text]
            
            let request = TimelineRequest(timelineWhen: .current, timeLine: .custom, tag: appState.showTag,customTimeLine: timeline)
            timelineManger.setTimelineRequestAndFetch(request: request)
        }
        
        
        
        return PopMenu(icon: "clock.arrow.circlepath",selected:$currentSelectedTimeline,
                       menuItems: [PopMenuItem(text: TimeLine.home.rawValue,help:TimeLine.home.rawValue,userData:TimeLine.home),
                                   PopMenuItem(text: TimeLine.localTimeline.rawValue,help:TimeLine.localTimeline.rawValue,userData:TimeLine.localTimeline),
                                   PopMenuItem(text: TimeLine.publicTimeline.rawValue,help:TimeLine.publicTimeline.rawValue,userData:TimeLine.publicTimeline),
                                   PopMenuItem(text: TimeLine.tag.rawValue,help:TimeLine.tag.rawValue,userData:TimeLine.tag),
                                   PopMenuItem(text: TimeLine.favorites.rawValue,help:TimeLine.favorites.rawValue,userData:TimeLine.favorites),
                                   PopMenuItem(text: TimeLine.bookmarks.rawValue,help:TimeLine.bookmarks.rawValue,userData:TimeLine.bookmarks),
                                   PopMenuItem(text: TimeLine.notifications.rawValue,help:TimeLine.notifications.rawValue,userData:TimeLine.notifications),
                                   PopMenuItem(text: TimeLine.mentions.rawValue,help:TimeLine.mentions.rawValue,userData:TimeLine.mentions),
                            PopMenuItem(text: TimeLine.custom.rawValue,help:"Custom",userData:TimeLine.custom,subMenu: customSubMenu),
                           ])
        { item in
            
            timelineManger.clearTimeline()
            appState.selectedTimeline = item.userData!
            
            let request = TimelineRequest(timelineWhen: .current, timeLine: item.userData!, tag: appState.showTag)
            timelineManger.setTimelineRequestAndFetch(request: request)
        }
    }
    
}

