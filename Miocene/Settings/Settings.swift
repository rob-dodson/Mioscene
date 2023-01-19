//
//  Settings.swift
//  Miocene
//
//  Created by Robert Dodson on 12/23/22.
//

import Foundation
import SwiftUI
import MastodonKit


enum TabIndex : Int
{
    case TimeLine = 0
    case Accounts
    case Search
    case Settings
}

class CurrentTabIndex : ObservableObject
{
    var index : TabIndex = .TimeLine
}

/**
 Settings
 */
class Settings: ObservableObject
{
    @Published var theme : Theme
    @Published var tabIndex : TabIndex = .TimeLine
    @Published var currentAccount : MastodonKit.Account?
    @Published var currentTag = String()
    @Published var selectedTimeline : TimeLine = .home
    @Published var font : MFont
   
    var iconSize = 20
    
    var themes = Themes()
    
    init()
    {
        let defaults = UserDefaults.standard
        
        theme = themes.themeslist[0]
        
        var fontName = "SF Pro"
        var fontSize = MFont.TextSize.normal
        
        if let userfont = defaults.string(forKey: "font") { fontName = userfont }
        if let userfontsizename = defaults.string(forKey: "fontsizename") { fontSize = MFont.getEnumFromString(string: userfontsizename) }
        font = MFont(fontName: fontName,sizeName: fontSize)
    }
   
    func showTag(tag:String)
    {
        currentTag = tag
        selectedTimeline = .tag
        tabIndex = .TimeLine
        
        
    }
    
    func showAccount(account:Account)
    {
        currentAccount = account
        tabIndex = .Accounts
    }
}

 


