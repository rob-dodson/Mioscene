//
//  ContentView.swift
//  Miocene
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit




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
        
        HStack(alignment: .center,spacing: 20)
        {
            Spacer()
            
            TabBarButton(text: "Timelines", isSelected: .constant(settings.tabIndex == .TimeLine))
                .onTapGesture { onButtonTapped(index: .TimeLine) }
            
            TabBarButton(text: "Accounts", isSelected: .constant(settings.tabIndex == .Accounts))
                .onTapGesture { onButtonTapped(index: .Accounts) }
            
            TabBarButton(text: "Search", isSelected: .constant(settings.tabIndex == .Search))
                .onTapGesture { onButtonTapped(index: .Search) }
            
            TabBarButton(text: "Settings", isSelected: .constant(settings.tabIndex == .Settings))
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
    
    @Binding var isSelected: Bool
    
    var body: some View
    {
        Text(text)
            .fontWeight(isSelected ? .bold : .regular)
            .font(.title2)
            .foregroundColor(isSelected ? settings.theme.accentColor : settings.theme.minorColor)
            .padding(.bottom,10)
            .border(width: isSelected ? 3 : 1, edges: [.bottom], color: .black)
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
    
extension View
{
    func border(width: CGFloat, edges: [Edge], color: SwiftUI.Color) -> some View
    {
            overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
