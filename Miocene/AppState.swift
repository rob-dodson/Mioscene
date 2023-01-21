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
    var currentlocalAccountRecord : LocalAccountRecord?
    var currentUserMastAccount : MastodonKit.Account?
    var currentViewingMastAccount : MastodonKit.Account?

    @Published var currenttabindex = CurrentTabIndex()
    @Published var tabIndex : TabIndex = .TimeLine
    @Published var currentTag = String()
    @Published var selectedTimeline : TimeLine = .home
    
    static var shared = AppState()
    
    
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
    
    func showAccount(account:Account)
    {
        currentViewingMastAccount = account
        tabIndex = .Accounts
    }
}
