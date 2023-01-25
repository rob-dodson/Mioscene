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
            
            VStack
            {
                Picker("Text Size", selection: $settings.font.currentSizeName)
                {
                    ForEach(MFont.TextSize.allCases)
                    { text in
                        Text("\(text.rawValue)")
                    }
                }
                .font(settings.font.headline)
                .frame(width:200)
                .onChange(of: settings.font.currentSizeName)
                { newValue in
                    settings.font = MFont(fontName: settings.font.name, sizeName: newValue)
                    let defaults = UserDefaults.standard
                    defaults.set(newValue.rawValue, forKey: "fontsizename")
                }
            }
            
            VStack
            {
                Picker("Font", selection: $settings.font.name)
                {
                    ForEach(MFont.fontList.indices, id: \.self)
                    { index in
                        Text(MFont.fontList[index]).tag(MFont.fontList[index])
                            .font(Font.custom(MFont.fontList[index],size:15))
                    }
                }
                .font(settings.font.headline)
                .pickerStyle(RadioGroupPickerStyle())    
                .frame(width:200)
                .onChange(of: settings.font.name)
                { newValue in
                    settings.font = MFont(fontName: newValue, sizeName: settings.font.currentSizeName)
                    let defaults = UserDefaults.standard
                    defaults.set(settings.font.name, forKey: "font")
                }
            }
            
            
            VStack(alignment: .leading)
            {
                Text("Behaviors")
                    .font(settings.font.title)
                    .foregroundColor(settings.theme.accentColor)
                
                Toggle("Hide Status Buttons", isOn: $settings.hideStatusButtons)
                .onChange(of: settings.hideStatusButtons)
                { newValue in
                    let defaults = UserDefaults.standard
                    defaults.set(settings.hideStatusButtons, forKey: "hidestatusbuttons")
                }
                
                Toggle("Show Cards", isOn: $settings.showCards)
                .onChange(of: settings.showCards)
                { newValue in
                    let defaults = UserDefaults.standard
                    defaults.set(settings.showCards, forKey: "showcards")
                }
            }
            .padding()
            

        }
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
    
   
    func pickTheme(index:Int)
    {
        settings.theme = settings.themes.themeslist[index]
        UserDefaults.standard.set(settings.theme.name, forKey: "theme")
    }
}

