//
//  SettingsView.swift
//  Miocene
//
//  Created by Robert Dodson on 1/3/23.
//


import SwiftUI

struct SettingsView: View
{
    @EnvironmentObject var settings: Settings
    
    let colorBlockSize = 20.0
    
    var body: some View
    {
        VStack(alignment: .center)
        {
            
            Text("Appearance")
                .font(settings.font.title)
                .foregroundColor(settings.theme.accentColor)
        
            VStack(alignment:.leading)
            {
                
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
                            .font(settings.font.headline)
                        
                        HStack()
                        {
                            let theme = settings.themes.themeslist[index]
                            
                            ForEach(Theme.colorName.allCases)
                            { name in
                                Rectangle().fill(theme.colors[name.rawValue]!).frame(width: colorBlockSize, height: colorBlockSize)
                            }
                        }
                    }
                }
            }
            
            //
            // Text and icon size
            //TextSize
            
            VStack
            {
                Picker("Text Size", selection: $settings.currentTextSize)
                {
                    ForEach(MFont.TextSize.allCases)
                    { text in
                        Text("\(text.rawValue)")
                    }
                }
                .frame(width:200)
                .onChange(of: settings.currentTextSize)
                { newValue in
                    settings.font = MFont(fontName: settings.font.name, size: newValue)
                }
            }
            
            VStack
            {
                Picker("Font", selection: $settings.font.name)
                {
                    ForEach(MFont.fontList.indices, id: \.self)
                    { index in
                        Text(MFont.fontList[index]).tag(MFont.fontList[index])
                    }
                }
                .frame(width:200)
                .onChange(of: settings.font.name)
                { newValue in
                    settings.font = MFont(fontName: newValue, size: settings.currentTextSize)
                }
            }
             
        }
       .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
    
   
    func pickTheme(index:Int)
    {
        settings.theme = settings.themes.themeslist[index]
    }
}

