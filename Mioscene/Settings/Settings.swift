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
    @Published var seeAccount : MastodonKit.Account?
    @Published var currentTag = String()
    @Published var fonts = Fonts()
    
    
    var themes = Themes()
    
    init()
    {
        theme = themes.themeslist[0]
    }
   
    func showTag(tag:String)
    {
        currentTag = tag
        tabIndex = .TimeLine
    }
    
    func showAccount(account:Account)
    {
        seeAccount = account
        tabIndex = .Accounts
    }
}

 


