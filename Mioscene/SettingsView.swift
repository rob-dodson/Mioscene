//
//  SettingsView.swift
//  Miocene
//
//  Created by Robert Dodson on 1/3/23.
//

//
//  Prefs.swift
//  Weather
//
//  Created by Robert Dodson on 11/18/22.
//

import SwiftUI

struct SettingsView: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings: Settings
    
    let themesize = 20.0
    
    var body: some View
    {
        VStack
        {
            VStack
            {
                Text("Themes")
                    .font(.title)
                    .foregroundColor(settings.theme.accentColor)
                
                ForEach(0 ..< settings.themes.count)
                { index in
                    
                    HStack
                    {
                        Button()
                        {
                            pickTheme(index:index)
                        }
                    label:
                        {
                            if settings.themes[index].name == settings.theme.name
                            {
                                Image(systemName: "checkmark")
                            }
                            else
                            {
                                Image(systemName: "circle")
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text(settings.themes[index].name)
                        
                        let theme = settings.themes[index]
                        HStack()
                        {
                            Rectangle().fill(theme.accentColor).frame(width: themesize, height: themesize)
                            Rectangle().fill(theme.bodyColor).frame(width: themesize, height: themesize)
                            Rectangle().fill(theme.nameColor).frame(width: themesize, height: themesize)
                        }
                    }
                }
            }
            
            VStack
            {
                Text("Stuff")
                    .font(.title)
                    .foregroundColor(settings.theme.accentColor)
                
                Button("Setting 1") { }
                Button("Setting 1") { }
                Button("Setting 1") { }
                Button("Setting 1") { }
                Button("Setting 1") { }
                Button("Setting 1") { }
                Button("Setting 1") { }
                Button("Setting 1") { }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
    
 
   
    func pickTheme(index:Int)
    {
        settings.theme = settings.themes[index]
    }
}

