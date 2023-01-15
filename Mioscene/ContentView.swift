//
//  ContentView.swift
//  Miocene
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit

/*
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .ultraLight))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .thin))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .light))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .regular))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .medium))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .semibold))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .bold))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .heavy))
Image(systemName: "checkmark.circle")
    .font(.system(size: 16, weight: .black))
*/

struct ContentView: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings : Settings
    
    var body: some View
    {
        VStack
        {
            CustomTopTabBar(tabIndex: $settings.tabIndex)
            
            switch settings.tabIndex
            {
            case .TimeLine: TimeLineView(mast: mast)
            case .Accounts: AccountView(mast: mast)
            case .Search: SearchView(mast: mast)
            case .Settings: SettingsView(mast: mast)
            }
            
            Spacer()
        }
        .frame(minWidth: 400, alignment: .center)
        .padding(.horizontal, 12)
    }
}
       
struct CustomTopTabBar: View
{
    @Binding var tabIndex: TabIndex
    @EnvironmentObject var settings : Settings
    
    var body: some View
    {
        Spacer()
        
        HStack(alignment: .center,spacing: 50)
        {
            Spacer()
            
            TabBarButton(text: "Timelines",icon:"house", isSelected: .constant(settings.tabIndex == .TimeLine))
                .onTapGesture { onButtonTapped(index: .TimeLine) }
            
            TabBarButton(text: "Accounts",icon:"person", isSelected: .constant(settings.tabIndex == .Accounts))
                .onTapGesture { onButtonTapped(index: .Accounts) }
            
            TabBarButton(text: "Search", icon:"magnifyingglass",isSelected: .constant(settings.tabIndex == .Search))
                .onTapGesture { onButtonTapped(index: .Search) }
            
            TabBarButton(text: "Settings",icon:"gear", isSelected: .constant(settings.tabIndex == .Settings))
                .onTapGesture { onButtonTapped(index: .Settings) }
                         
           Spacer()
        }
        .border(width: 1, edges: [.bottom], color: .black)
    }
    
    private func onButtonTapped(index: TabIndex)
    {
        settings.tabIndex = index
    }
}



struct TabBarButton: View
{
    @EnvironmentObject var settings: Settings
    
    let text : String
    let icon : String
    
    @Binding var isSelected: Bool
    
    var body: some View
    {
        VStack
        {
            Image(systemName:icon)
                .font(.system(size: 24, weight: .thin))
                .foregroundColor(isSelected ? settings.theme.accentColor : settings.theme.minorColor)
            //    .padding(.trailing,-2)
                //.padding(.bottom,10)
           
            Text(text)
                .fontWeight(isSelected ? .bold : .regular)
                .font(settings.fonts.small)
                .foregroundColor(isSelected ? settings.theme.accentColor : settings.theme.minorColor)
                .padding(.bottom,5)
                //  .border(width: isSelected ? 3 : 1, edges: [.bottom], color: .black)
        
        }
    }
}


struct EdgeBorder: Shape
{
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path
    {
        var path = Path()
        for edge in edges
        {
            var x: CGFloat
            {
                switch edge
                {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat
            {
                switch edge
                {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat
            {
                switch edge
                {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat
            {
                switch edge
                {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}
    

