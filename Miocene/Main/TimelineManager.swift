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
    case custom          = "Custom",
         home            = "Home",
         localTimeline   = "Local Timeline",
         publicTimeline  = "Public Timeline",
         tag             = "Tag",
         favorites       = "Favorites",
         bookmarks       = "Bookmarks",
         notifications   = "All Notifications",
         mentions        = "Mentions Only"
    
    var id: Self { self }
}


enum TimelineWhen : Int
{
    case current,older,newer
}


struct CustomTimeline
{
    var name : String
    var timelineRequests : [TimelineRequest]
    var filterSet : FilterSet
}


class TimelineRequest
{
    var timelineWhen : TimelineWhen
    var timeLine : TimeLine
    var tag : String
    var customTimeLine : CustomTimeline?
    var lastId : String?
    var firstId : String?
    
    init(timelineWhen: TimelineWhen, timeLine: TimeLine, tag: String, customTimeLine: CustomTimeline? = nil, id: String? = nil, lastId: String? = nil, firstId: String? = nil)
    {
        self.timelineWhen = timelineWhen
        self.timeLine = timeLine
        self.tag = tag
        self.customTimeLine = customTimeLine
        self.lastId = lastId
        self.firstId = firstId
    }
}


class TimelineManager : ObservableObject
{
    //
    // TimeLineView uses these in it's ScrollView ===
    //
    @Published var theStats = [MStatus]()
    @Published var theNotifications = [MNotification]()

    @State private var settings: Settings
    @State private var appState: AppState
    @State private var fetching : Bool = false
    private var currentRequest : TimelineRequest? //(timelineWhen: .current, timeLine: .home, tag: "")
    private var timelineTimer : Timer?
    
    
    
    init()
    {
        self.settings = Settings.shared
        self.appState = AppState.shared
    }
    
    
    //
    // Public API
    //
    func start()
    {
        Log.log(msg:"START TLM LOOP")
        loop()
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
        if let requestOld = self.currentRequest
        {
            requestOld.timelineWhen = .older
            doRequest(request: requestOld)
        }
    }
    
    func getNewerStats()
    {
        if let requestNew = self.currentRequest
        {
            requestNew.timelineWhen = .newer
            doRequest(request: requestNew)
        }
    }
 
    func getCurrentStats()
    {
        if let requestCurrent = self.currentRequest
        {
            requestCurrent.timelineWhen = .current
            doRequest(request: requestCurrent)
        }
    }
    
    
    //
    // private funcs
    //
    private func doRequest(request:TimelineRequest)
    {
        Task(priority: .userInitiated)
        {
            await fetchStatuses(timelineRequest:request)
        }
    }
    
    
    private func loop()
    {
        if timelineTimer != nil {  Log.log(msg:"TIMER STOPPED !! ");timelineTimer?.invalidate() }
        Log.log(msg:"TIMER STARTED")
        timelineTimer = Timer.scheduledTimer(withTimeInterval: 60 * 5, repeats: true)
        { timer in
            self.loopfunc()
        }
    }
   
    
    private func loopfunc()
    {
        Task
        {
            if let requestNew = currentRequest
            {
                requestNew.timelineWhen = .newer
                await fetchStatuses(timelineRequest:requestNew)
            }
        }
    }
    
    private func fetchStatuses(timelineRequest:TimelineRequest) async
    {
        if fetching == true { return }
        fetching = true
        
        switch timelineRequest.timeLine
        {
            case .home,.localTimeline,.publicTimeline,.favorites,.tag,.bookmarks:
                
                assembleTimeline(timelineRequest: timelineRequest)
                { newstats in
                   
                    self.currentRequest = timelineRequest
                   
                    Task
                    { @MainActor in
                        self.theStats = newstats
                    }
                    self.fetching = false
                }
                
                
            case .mentions,.notifications:
                
                getNotifications(timelineRequest: timelineRequest)
                currentRequest = timelineRequest
                
            case .custom:
                assembleTimeline(timelineRequest: timelineRequest)
                { newstats in
                    self.currentRequest = timelineRequest
                    
                    Task
                    { @MainActor in
                        self.theStats = newstats
                    }
                    self.fetching = false
                }
                
        }
    }
    
    private func getNotifications(timelineRequest:TimelineRequest)
    {
        appState.mastio()?.getNotifications(mentionsOnly:timelineRequest.timeLine == .mentions ? true : false)
        { mnotes in
            
            Task
            { @MainActor in
                self.theNotifications = mnotes
            }
        }
    }
    
    
    private func assembleTimeline(timelineRequest:TimelineRequest, done: @escaping ([MStatus]) -> Void)
    {
        //
        // standard timelines
        //
        if timelineRequest.timeLine != .custom
        {
            getTimeline(timelineRequest:timelineRequest)
            { stats in
                
                done(stats)
            }
        }
        else // custom timeline
        {
            //
            // append all desired timelines into one array
            //
            if let customtimeline = timelineRequest.customTimeLine
            {
                let group = DispatchGroup()
                group.enter()
                
                var retstats = [MStatus]()
                
                var counter = 0
                for custreq in customtimeline.timelineRequests
                {
                    custreq.timelineWhen = timelineRequest.timelineWhen
                    
                    counter += 1
                    getTimeline(timelineRequest:custreq)
                    { custstats in
                        Log.log(msg:"cust stats \(custstats.count)")
                        retstats = retstats + custstats
                        custreq.firstId = custstats.last?.status.id
                        custreq.lastId = custstats.last?.status.id
                        counter -= 1
                        if counter == 0
                        {
                            group.leave()
                        }
                    }
                }
                group.wait()
                
                //
                // sort by date/time
                //
                retstats = retstats.sorted(by:
                { a, b in
                    return a.status.createdAt.timeIntervalSince1970 < b.status.createdAt.timeIntervalSince1970
                })
                
                
                //
                // now apply filters
                //
                retstats = FilterTools.shared.filterStats(filterSet:customtimeline.filterSet,stats:retstats)
                Log.log(msg:"cust stats after filters: \(retstats.count)")
                
                done(retstats)
            }
        }
    }
    
    
    private func getTimeline(timelineRequest:TimelineRequest, done: @escaping ([MStatus]) -> Void)
    {
        guard fetching == false else { return }
        fetching = true
        
        switch timelineRequest.timelineWhen
        {
            case .current:
                getCurrentStats(timelineRequest: timelineRequest)
                { stats in
                    timelineRequest.firstId = stats.first?.status.id
                    timelineRequest.lastId = stats.last?.status.id
                    done(stats)
                }
                
            case .newer:
                getNewStatuses(timelineRequest: timelineRequest)
                { stats in
                    timelineRequest.firstId = stats.first?.status.id
                    done(stats)
                }
                
            case .older:
                getOlderStats(timelineRequest: timelineRequest)
                { stats in
                    
                    timelineRequest.lastId = stats.last?.status.id
                    done(stats)
                }
        }
    }
    
    
    private func getCurrentStats(timelineRequest:TimelineRequest, done: @escaping ([MStatus]) -> Void)
    {
        appState.mastio()?.getSomeStatuses(timeline: timelineRequest.timeLine, tag:timelineRequest.tag)
        { somestats in
            done(somestats)
        }
    }
    
    
    private func getOlderStats(timelineRequest:TimelineRequest, done: @escaping ([MStatus]) -> Void)
    {
        guard let lastid = timelineRequest.lastId else { return }
        
        appState.mastio()?.getOlderStatuses(timeline: timelineRequest.timeLine, id: lastid, tag:timelineRequest.tag)
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
                
                done(self.theStats + filteredoldstats)
            }
            else
            {
                done(self.theStats + olderstats)
            }
        }
    }
   
    
    @available(*, renamed: "getNewStatuses(timelineRequest:)")
    private func getNewStatuses(timelineRequest:TimelineRequest, done: @escaping ([MStatus]) -> Void)
    {
        Task
        {
            let result = await getNewStatuses(timelineRequest: timelineRequest)
            done(result)
        }
    }
    
    
    private func getNewStatuses(timelineRequest:TimelineRequest) async -> [MStatus]
    {
        guard var newid = timelineRequest.firstId else { return [MStatus]() }
        
        var retstats = [MStatus]()
        var nomore = false
        
        while(nomore == false)
        {
            let result = await appState.mastio()?.getNewerStatuses(timeline: timelineRequest.timeLine, id: newid, tag: timelineRequest.tag)
            
            if let newstats = result?.newstats
            {
                let morestats = result?.morestats
                Log.log(msg:"new \(newstats.count) more:\(morestats ?? false)")

                if newstats.count > 0
                {
                    retstats = retstats + newstats
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
        }
        
        retstats = retstats + self.theStats
        if retstats.count > 250
        {
            Log.log(msg:"removing last 50 from stats")
            retstats.removeLast(50)
        }
        return retstats
    }
    
}

