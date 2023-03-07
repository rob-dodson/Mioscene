//
//  Settings.swift
//  Miocene
//
//  Created by Robert Dodson on 12/23/22.
//

import Foundation
import SwiftUI
import MastodonKit

class Settings: ObservableObject
{
    @Published var theme : Theme
    @Published var font : MFont
    @Published var hideStatusButtons : Bool = false
    @Published var showCards : Bool = false
    @Published var hideIconText : Bool = false
    @Published var showTimelineToolBar = true
    @Published var addMentionsToHome = false
    @Published var flagBots = true
    @Published var hidePostsWithCW = false
    
    
    var iconSize = 20
    var themes = Themes()
    
    init()
    {
        let defaults = UserDefaults.standard
        
        theme = themes.themeslist[0]
        if let themename = defaults.string(forKey: "theme")
        {
            for tmptheme in themes.themeslist
            {
                if tmptheme.name == themename
                {
                    theme = tmptheme
                }
            }
        }
        var fontName = "SF Pro"
        var fontSize = MFont.TextSize.normal
        
        if let userfont = defaults.string(forKey: "font") { fontName = userfont }
        if let userfontsizename = defaults.string(forKey: "fontsizename") { fontSize = MFont.getEnumFromString(string: userfontsizename) }
        font = MFont(fontName: fontName,sizeName: fontSize)
        
        hideStatusButtons = defaults.bool(forKey: "hidestatusbuttons")
        showCards = defaults.bool(forKey: "showcards")
        showTimelineToolBar = defaults.bool(forKey: "showtimelinetoolbar")
        addMentionsToHome = defaults.bool(forKey: "addmentionstohome")
        flagBots = defaults.bool(forKey: "flagbots")
        hidePostsWithCW = defaults.bool(forKey: "hidepostswithcw")
    }
}

 


