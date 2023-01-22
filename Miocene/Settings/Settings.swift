//
//  Settings.swift
//  Miocene
//
//  Created by Robert Dodson on 12/23/22.
//

import Foundation
import SwiftUI
import MastodonKit





/**
 Settings
 */
class Settings: ObservableObject
{
    @Published var theme : Theme
    @Published var font : MFont
    @Published var hideStatusButtons : Bool = false
   
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
        
        hideStatusButtons = defaults.bool(forKey: "hidestatusbuttons")
    }
   
  
}

 


