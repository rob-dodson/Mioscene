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
                    .font(settings.fonts.title)
                    .foregroundColor(settings.theme.accentColor)
                
                ForEach($settings.themes.themeslist.indices, id:\.self)
                { index in
                    HStack
                    {
                        Button()
                        {
                            pickTheme(index:index)
                        }
                    label:
                        {
                            if settings.themes.themeslist[index].name == settings.theme.name
                            {
                                Image(systemName: "checkmark")
                            }
                            else
                            {
                                Image(systemName: "circle")
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Text(settings.themes.themeslist[index].name)
                        
                        let theme = settings.themes.themeslist[index]
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
                Picker("Text Size", selection: $settings.fonts.textSize)
                {
                    ForEach(Fonts.TextSize.allCases, id: \.self)
                    { text in
                        Text(text.rawValue)
                    }
                }
                .onChange(of: settings.fonts.textSize)
                { newValue in
                    settings.fonts.textSize = newValue
                    settings.fonts.setFonts()
                }
                
                
                Text(".largeTitle").font(.largeTitle)
                Text(".title").font(settings.fonts.title)
                Text(".title2").font(.title2)
                Text(".title3").font(.title3)
                Text(".headline").font(.headline)
            }
            VStack
            {
                Text(".subheadline").font(.subheadline)
                Text(".body").font(.body)
                Text(".callout").font(.callout)
                Text(".caption").font(.caption)
                Text(".caption2").font(.caption2)
               Text(".footnote").font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
    
   
    func pickTheme(index:Int)
    {
        settings.theme = settings.themes.themeslist[index]
    }
}

