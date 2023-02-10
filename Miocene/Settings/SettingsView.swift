//
//  SettingsView.swift
//  Miocene
//
//  Created by Robert Dodson on 1/3/23.
//


import SwiftUI

struct SettingsView: View
{
    @ObservedObject var mast : Mastodon
    @EnvironmentObject var settings: Settings
    
    let colorBlockSize = 20.0
    
    var body: some View
    {
        VStack
        {
            ScrollView
            {
                VStack(alignment: .trailing)
                {
                    appearance()
                    textSize()
                    font()
                    behaviors()
                }
                
                SpacerLine(color: settings.theme.minorColor)
                
                Text("Help")
                    .font(settings.font.title)
                    .foregroundColor(settings.theme.accentColor)
                
                VStack(alignment: .leading)
                {
                    Link("Miocene 1.0", destination: URL(string:"https://miocene.app/about")!)
                    Link("Miocene Support", destination: URL(string:"https://miocene.app/support")!)
                    Link("Privacy", destination: URL(string:"https://miocene.app/privacy")!)
                    Link("Copyright Shy Frog Productions LLC", destination: URL(string:"https://miocene.app/about")!)
                }
            }
        }
        .frame(maxHeight: .infinity,alignment: .top)
        
    }
    
    
    func appearance() -> some View
    {
        return VStack
        {
            HStack(spacing: 2)
            {
                Link(destination: URL(string:"https://joinmastodon.org/")!)
                {
                    Image("MastodonSymbol")
                        .foregroundColor(settings.theme.accentColor)
                        .font(.largeTitle)
                }
                
                Text("Appearance")
                    .font(settings.font.title)
                    .foregroundColor(settings.theme.accentColor)
            }.symbolRenderingMode(.multicolor)
            
            ForEach($settings.themes.themeslist.indices, id:\.self)
            { index in
                HStack
                {
                    Button()
                    {
                        settings.theme = settings.themes.themeslist[index]
                        UserDefaults.standard.set(settings.theme.name, forKey: "theme")
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
    }
    
    
    func textSize() -> some View
    {
        return VStack
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
    }
    
    
    func font() -> some View
    {
        return VStack
        {
            Picker("Font", selection: $settings.font.name)
            {
                ForEach(settings.font.fontList.indices, id: \.self)
                { index in
                    Text(settings.font.fontList[index]).tag(settings.font.fontList[index])
                        .font(Font.custom(settings.font.fontList[index],size:15))
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
    }
    
    
    func behaviors() -> some View
    {
        return VStack(alignment: .leading)
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
            
            Toggle("Hide Icon Text", isOn: $settings.hideIconText)
                .onChange(of: settings.hideIconText)
            { newValue in
                let defaults = UserDefaults.standard
                defaults.set(settings.hideIconText, forKey: "hideicontext")
            }
            
            Toggle("Add Mentions to Home Timeline", isOn: $settings.addMentionsToHome)
                .onChange(of: settings.addMentionsToHome)
            { newValue in
                let defaults = UserDefaults.standard
                defaults.set(settings.addMentionsToHome, forKey: "addmentionstohome")
            }
            
            Toggle("Flag Bots", isOn: $settings.flagBots)
                .onChange(of: settings.flagBots)
            { newValue in
                let defaults = UserDefaults.standard
                defaults.set(settings.flagBots, forKey: "flagbots")
            }
        }
        .padding()
    }
}
