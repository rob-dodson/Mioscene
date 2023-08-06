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
        case ownpost = "ownpost"
        case appback = "appback"
        case replyto = "replyto"
        
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
    var ownpostColor : Color
    var appbackColor : Color
    var replyToColor : Color


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
        ownpostColor = colors[colorName.ownpost.rawValue] ?? Color.gray
        appbackColor = colors[colorName.appback.rawValue] ?? Color.gray
        replyToColor = colors[colorName.replyto.rawValue] ?? Color.brown

    }
}


class Themes
{
    var themeslist : [Theme]
    
    init()
    {
        themeslist = Array<Theme>()
        let themeNames = ["Hyper","Midnight"]
        
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
                          Theme.colorName.ownpost.rawValue:Color("ownpost\(index)"),
                          Theme.colorName.appback.rawValue:Color("appback\(index)"),
                          Theme.colorName.replyto.rawValue:Color("replyto\(index)"),
                           ]
            
            let theme = Theme(name: themeNames[index], colors: colors)
            themeslist.append(theme)
        }
    }
}

