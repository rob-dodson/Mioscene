//
//  AppState.swift
//  Miocene
//
//  Created by Robert Dodson on 1/21/23.
//

import Foundation
import MastodonKit


class CurrentTabIndex : ObservableObject
{
    var index : TabIndex = .TimeLine
}

enum TabIndex : Int
{
    case TimeLine = 0
    case Accounts
    case Search
    case Settings
}


class AppState : ObservableObject
{
    @Published var currentlocalAccountRecord : LocalAccountRecord?
    @Published var currentUserMastAccount : MastodonKit.Account?
    @Published var currentViewingMastAccount : MAccount?
    @Published var currenttabindex = CurrentTabIndex()
    @Published var tabIndex : TabIndex = .TimeLine
    @Published var currentTag = String()
    @Published var selectedTimeline : TimeLine = .home
    
    static let shared = AppState()
    
    
    func showTag(tag:String)
    {
        currentTag = tag
        selectedTimeline = .tag
        tabIndex = .TimeLine
    }
    
    func showHome()
    {
        selectedTimeline = .home
        tabIndex = .TimeLine
    }
    
    func showAccount(maccount:MAccount)
    {
        currentViewingMastAccount = maccount
        tabIndex = .Accounts
    }
}
