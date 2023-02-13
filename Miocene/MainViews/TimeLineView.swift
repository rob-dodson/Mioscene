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
        custdict["macOS - Local"] = customtimeline
        custdict["Ivory - Home"] = customtimeline0
        
        let customSubMenu = PopMenu(icon: "person",selected:selectedTimeline.rawValue,
                                    menuItems: [PopMenuItem(text: "macOS - Local",userData:TimeLine.custom),
                                                PopMenuItem(text: "Ivory - Home",userData:TimeLine.custom)
                                                ])
        { item in
            print("Custom Sub Menu \(item.text)")
            
            let timeline = custdict[item.text]
            
            let request = TimelineRequest(timelineWhen: .current, timeLine: .custom, tag: currentTag,customTimeLine: timeline)
            timelineManger.setTimelineRequestAndFetch(request: request)
        }
        
        
        
        return PopMenu(icon: "clock.arrow.circlepath",selected:selectedTimeline.rawValue,
                menuItems: [PopMenuItem(text: TimeLine.home.rawValue,userData:TimeLine.home),
                            PopMenuItem(text: TimeLine.localTimeline.rawValue,userData:TimeLine.localTimeline),
                            PopMenuItem(text: TimeLine.publicTimeline.rawValue,userData:TimeLine.publicTimeline),
                            PopMenuItem(text: TimeLine.tag.rawValue,userData:TimeLine.tag),
                            PopMenuItem(text: TimeLine.favorites.rawValue,userData:TimeLine.favorites),
                            PopMenuItem(text: TimeLine.bookmarks.rawValue,userData:TimeLine.bookmarks),
                            PopMenuItem(text: TimeLine.notifications.rawValue,userData:TimeLine.notifications),
                            PopMenuItem(text: TimeLine.mentions.rawValue,userData:TimeLine.mentions),
                            PopMenuItem(text: TimeLine.custom.rawValue,userData:TimeLine.custom,subMenu: customSubMenu),
                           ])
        { item in
            
            timelineManger.clearTimeline()
            selectedTimeline = item.userData!
            
            let request = TimelineRequest(timelineWhen: .current, timeLine: item.userData!, tag: currentTag)
            timelineManger.setTimelineRequestAndFetch(request: request)
        }
    }
    
}

