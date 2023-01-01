//
//  Settings.swift
//  Mammut
//
//  Created by Robert Dodson on 12/23/22.
//

import Foundation
import SwiftUI
import Combine


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
    
    var bodyColor : Color
    var accentColor : Color
    var nameColor : Color
    var minorColor : Color
    var linkColor : Color
    var dateColor : Color
    var blockColor : Color

    
    var name: String
    var colors : Dictionary<String,Color>
    var id : UUID
    
    init(name: String, colors:Dictionary<String,Color>)
    {
        self.name = name
        self.id = UUID()
        self.colors = colors
        
        self.bodyColor = colors[colorName.body.rawValue] ?? Color.black
        self.accentColor = colors[colorName.accent.rawValue] ?? Color.orange
        self.nameColor = colors[colorName.name.rawValue] ?? Color.black
        self.minorColor = colors[colorName.minor.rawValue] ?? Color.black
        self.linkColor = colors[colorName.link.rawValue] ?? Color.blue
        self.dateColor = colors[colorName.date.rawValue] ?? Color.mint
        self.blockColor = colors[colorName.block.rawValue] ?? Color.gray
    }
    
    func color(name:colorName) -> Color
    {
        return colors[name.rawValue] ?? Color.white
    }
}


class Settings: ObservableObject
{
    @Published var theme : Theme
            
    var themes : [Theme]
    
    
    var prefsBlockColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    let fontsize = 40.0
    
    let hugeFont : Font
    let titleFont : Font
    let headingFont : Font
    let mainFont : Font
    let smallFont : Font
    
    let blockPadding = 8.0
    
    init()
    {
        themes = Array<Theme>()
        let themeNames = ["Hyper","Serious"]
        
        for index in 0..<themeNames.count
        {
            let colors = [Theme.colorName.body.rawValue:Color("body\(index)"),
                          Theme.colorName.accent.rawValue:Color("accent\(index)"),
                          Theme.colorName.name.rawValue:Color("name\(index)"),
                          Theme.colorName.minor.rawValue:Color("minor\(index)"),
                          Theme.colorName.link.rawValue:Color("link\(index)"),
                          Theme.colorName.date.rawValue:Color("date\(index)"),
                          Theme.colorName.block.rawValue:Color("date\(index)"),

                           ]
            
            let theme = Theme(name: themeNames[index], colors: colors)
            themes.append(theme)
        }

        theme = themes[0]
        
         hugeFont = Font.system(size: fontsize,weight: .bold)
         titleFont = Font.system(size: fontsize - 5.0)
         headingFont = Font.system(size: fontsize - 22.0)
         mainFont = Font.system(size: fontsize - 25.0)
         smallFont = Font.system(size: fontsize - 30.0)
    }
}

 


