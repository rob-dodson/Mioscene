//
//  Themes.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/11/23.
//

import Foundation
import SwiftUI

struct Theme : Identifiable
{
    enum colorName : String
    {
        case body = "body"
        case accent = "accent"
        case name = "name"
        case minor = "minor"
        case link = "link"
        case date = "date"
        case block = "block"
    }
    
    var name: String
    var colors : Dictionary<String,Color>
    var id : UUID = UUID()
    
    var bodyColor : Color = Color.white
    var accentColor : Color = Color.orange
    var nameColor : Color = Color.white
    var minorColor : Color = Color.gray
    var linkColor : Color = Color.blue
    var dateColor : Color = Color.gray
    var blockColor : Color = Color.black
}

class Themes
{
    var themeslist : [Theme]
    
    init()
    {
        themeslist = Array<Theme>()
        let themeNames = ["Hyper","Serious"]
        
        //
        // get colors from Assests.xcasssets
        //
        for index in 0..<themeNames.count
        {
            let colors = [Theme.colorName.body.rawValue:Color("body\(index)"),
                          Theme.colorName.accent.rawValue:Color("accent\(index)"),
                          Theme.colorName.name.rawValue:Color("name\(index)"),
                          Theme.colorName.minor.rawValue:Color("minor\(index)"),
                          Theme.colorName.link.rawValue:Color("link\(index)"),
                          Theme.colorName.date.rawValue:Color("date\(index)"),
                          Theme.colorName.block.rawValue:Color("block\(index)"),
                           ]
            
            let theme = Theme(name: themeNames[index], colors: colors)
            themeslist.append(theme)
        }
    }
}

