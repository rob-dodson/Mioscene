//
//  SettingsView.swift
//  Mammut
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
        
        VStack(spacing: 100)
        {
            Text("Settings")
                .frame(alignment:.topLeading)
            
            
            VStack (alignment:.leading)
            {
                Text("Themes")
                    .frame(alignment:.topLeading)
                
                ForEach(0 ..< settings.themes.count)
                { index in
                    
                    HStack(alignment: .center)
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
                        .frame(alignment: .leading)
                        
                        Text(settings.themes[index].name)
                                
                        let theme = settings.themes[index]
                        HStack()
                        {
                            Rectangle().fill(theme.accentColor).frame(width: themesize, height: themesize)
                        }
                    }
                }
            }
        }
        .frame(width: 300, height: 300)
        .padding()
        .cornerRadius(15)
        .opacity(60.0)
    }
   
    func pickTheme(index:Int)
    {
        settings.theme = settings.themes[index]
    }
}

