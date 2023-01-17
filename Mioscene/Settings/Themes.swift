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
    enum colorName : String,Equatable,CaseIterable,Identifiable
    {
        case accent = "accent"
        case body = "body"
        case name = "name"
        case minor = "minor"
        case link = "link"
        case block = "block"
        
        var id: Self { return self }
    }
    
    var name: String
    var colors : Dictionary<String,Color>
    var id : UUID
    var bodyColor : Color
    var accentColor : Color
    var nameColor : Color
    var minorColor : Color
    var linkColor : Color
    var blockColor : Color
    
    init(name: String, colors: Dictionary<String, Color>, id: UUID = UUID())
    {
        self.name = name
        self.colors = colors
        self.id = id
        
        bodyColor = colors[colorName.body.rawValue] ?? Color.white
        accentColor = colors[colorName.accent.rawValue] ?? Color.orange
        nameColor = colors[colorName.name.rawValue] ?? Color.white
        minorColor = colors[colorName.minor.rawValue] ?? Color.gray
        linkColor = colors[colorName.link.rawValue] ?? Color.blue
        blockColor = colors[colorName.block.rawValue] ?? Color.init(red: 0.2, green: 0.2, blue: 0.2)
    }
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
                          Theme.colorName.block.rawValue:Color("block\(index)"),
                           ]
            
            let theme = Theme(name: themeNames[index], colors: colors)
            themeslist.append(theme)
        }
    }
}

