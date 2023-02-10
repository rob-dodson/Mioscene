//
//  TimelineManager.swift
//  Miocene
//
//  Created by Robert Dodson on 2/6/23.
//

import Foundation
import SwiftUI


enum TimeLine : String,CaseIterable,Identifiable,Equatable
{
    case custom = "Custom",
         home = "Home",
         localTimeline = "Local Timeline",
         publicTimeline = "Public Timeline",
         tag = "Tag",
         favorites = "Favorites",
         bookmarks = "Bookmarks",
         notifications = "All Notifications",
         mentions = "Mentions Only"
    
    var id: Self { self }
}


enum TimelineWhen : Int
{
    case current,older,newer
}


struct CustomTimeline
{
    var timelineRequests : [TimelineRequest]
    var filterSet : FilterSet
}


struct TimelineRequest
{
    var timelineWhen : TimelineWhen
    var timeLine : TimeLine
    var tag : String
    var customTimeLine : CustomTimeline?
    var id : String?
}


class TimelineManager : ObservableObject
{
    @EnvironmentObject var settings: Settings
    
    //
    // TimeLineView uses these in it's ScrollView ===
    //
    @Published var theStats = [MStatus]()
    @Published var theNotifications = [MNotification]()

    
    @State private var fetching : Bool = false
    @State private var currentRequest = TimelineRequest(timelineWhen: .current, timeLine: .home, tag: "")
    @State private var timelineTimer : Timer?
    @State private var mast = Mastodon.shared
    
    
    //
    // Public API
    //
    func start()
    {
        if timelineTimer == nil // first time run this
        {
            loop()
        }
    }
    
    //
    // These funcs update theStats/theNotifications and will cause the TimeLineView to reload!
    //
    func clearTimeline()
    {
        theStats = [MStatus]()
        theNotifications = [MNotification]()
    }
    
    func setTimelineRequestAndFetch(request:TimelineRequest)
    {
        doRequest(request: request)
    }
    
    func getOlderStats()
    {
        var requestOld = self.currentRequest
        requestOld.timelineWhen = .older
        requestOld.id = theStats.last?.status.id
        
        doRequest(request: requestOld)
    }
    
    func getNewerStats()
    {
        var requestNew = self.currentRequest
        requestNew.timelineWhen = .newer
        requestNew.id = theStats.first?.status.id
        
        doRequest(request: requestNew)
    }
 
    func getCurrentStats()
    {
        var requestCurrent = self.currentRequest
        requestCurrent.timelineWhen = .current
        
        doRequest(request: requestCurrent)
    }
    
    
    //
    // private funcs
    //
    private func doRequest(request:TimelineRequest)
    {
        Task
        {
            await fetchStatuses(timelineRequest:request)
        }
    }
    
    
    private func loop()
    {
        if timelineTimer != nil { timelineTimer?.invalidate() }
        
        timelineTimer = Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: true)
        { timer in
            self.loopfunc()
        }
    }
   
    
    private func loopfunc()
    {
        Task
        {
            var requestNew = currentRequest
            requestNew.timelineWhen = .newer
            requestNew.id = theStats.first?.status.id
            await fetchStatuses(timelineRequest:requestNew)
        }
    }
    
    private func fetchStatuses(timelineRequest:TimelineRequest) async
    {
        if fetching == true { return }
        fetching = true
        
        switch timelineRequest.timeLine
        {
            case .home,.localTimeline,.publicTimeline,.favorites,.tag,.bookmarks:
                
                theStats = await assembleTimeline(timelineRequest: timelineRequest)
                currentRequest = timelineRequest
                
            case .mentions,.notifications:
                
                getNotifications(timelineRequest: timelineRequest)
                currentRequest = timelineRequest
                
            case .custom:
                print("CUSTOM")
        }
    }
    
    
    private func getNotifications(timelineRequest:TimelineRequest)
    {
        mast.getNotifications(mentionsOnly:timelineRequest.timeLine == .mentions ? true : false)
        { mnotes in
            
            DispatchQueue.main.async
            {
                self.theNotifications = mnotes
            }
        }
    }
    
    
    private func assembleTimeline(timelineRequest:TimelineRequest) async -> [MStatus]
    {
        //
        // standard tiumelines
        //
        if timelineRequest.timeLine != .custom
        {
            return await getTimeline(timelineRequest:timelineRequest)
        }
        else // custom timeline
        {
            var stats = [MStatus]()
            
            //
            // append all desired timelines into one array
            //
            if let customtimeline = timelineRequest.customTimeLine
            {
                for timelineRequest in customtimeline.timelineRequests
                {
                    let custStats = await getTimeline(timelineRequest:timelineRequest)
                    stats = stats + custStats
                }
                
                //
                // sort by date/time
                //
                stats = stats.sorted(by:
                { a, b in
                    return a.status.createdAt.timeIntervalSince1970 < b.status.createdAt.timeIntervalSince1970
                })
                
                
                //
                // now apply filters
                //
                stats = FilterTools.shared.filterStats(filterSet:customtimeline.filterSet,stats:stats)
            }
            
            return stats
        }
    }
    
    
    private func getTimeline(timelineRequest:TimelineRequest) async -> [MStatus]
    {
        guard fetching == false else { return theStats }
        fetching = true
        
        switch timelineRequest.timelineWhen
        {
            case .current:
                getCurrentStats(timelineRequest: timelineRequest)
                
            case .newer:
                getNewStatuses(timelineRequest: timelineRequest)
                
            case .older:
                getOlderStats(timelineRequest: timelineRequest)
        }
        
        return theStats
    }
    
    
    private func getCurrentStats(timelineRequest:TimelineRequest)
    {
        Task
        {
            await mast.getSomeStatuses(timeline: timelineRequest.timeLine, tag:timelineRequest.tag)
            { somestats in
                
                DispatchQueue.main.async
                {
                    self.theStats = somestats
                    self.fetching = false
                }
            }
        }
    }
    
    
    private func getOlderStats(timelineRequest:TimelineRequest)
    {
        guard let id = timelineRequest.id else { return }
        
        Task
        {
            mast.getOlderStatuses(timeline: timelineRequest.timeLine, id: id, tag:timelineRequest.tag)
            { [self] olderstats in
                
                if timelineRequest.timeLine == .bookmarks || timelineRequest.timeLine == .favorites // getOlder always returns all, so we filter out ones we have. Bug? Me dumb?
                {
                    let filteredoldstats = olderstats.filter
                    { mstatus in
                        
                        for stat in theStats
                        {
                            if stat.status.id == mstatus.status.id { return false }
                        }
                        return true
                    }
                    
                    DispatchQueue.main.async
                    {
                        self.theStats = self.theStats + filteredoldstats
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        self.theStats = self.theStats + olderstats
                    }
                }
                
                self.fetching = false
            }
        }
    }
   
    
    private func getNewStatuses(timelineRequest:TimelineRequest)
    {
        guard var newid = timelineRequest.id else { return }
        
        Task
        {
            var nomore = false
            while(nomore == false)
            {
                mast.getNewerStatuses(timeline: timelineRequest.timeLine, id: newid, tag:timelineRequest.tag)
                { newstats,morestats in
                    
                    print("NEW \(newstats.count) more:\(morestats)")
                    if newstats.count > 0
                    {
                            DispatchQueue.main.async
                            {
                                self.theStats = newstats + self.theStats
                                
                                if self.theStats.count > 150
                                {
                                    print("removing last 50 from stats")
                                    self.theStats.removeLast(50)
                                }
                            }
                    }
                    
                    if morestats == false
                    {
                        nomore = true
                    }
                    else
                    {
                        newid = (newstats.first?.status.id)!
                    }
                }
                
                try? await Task.sleep(for: .seconds(1))
            }
            
            self.fetching = false
        }
    }
    
}

