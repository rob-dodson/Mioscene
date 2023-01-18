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
    
    @Published var currentTextSize : MFont.TextSize
    @Published var font : MFont
   
    
    var themes = Themes()
    
    init()
    {
        theme = themes.themeslist[0]
        currentTextSize = MFont.TextSize.normal
        font = MFont(fontName: "SF Pro",size: MFont.TextSize.normal)
    }
   
    func showTag(tag:String)
    {
        currentTag = tag
        tabIndex = .TimeLine
    }
    
    func showAccount(account:Account)
    {
        currentAccount = account
        tabIndex = .Accounts
    }
}

 


