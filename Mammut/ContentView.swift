//
//  ContentView.swift
//  Mammut
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
            case 0: TimeLineView(mast: mast)
            case 1: AccountView(mast: mast)
            case 2: SearchView(mast: mast)
            case 3: SettingsView(mast: mast)
            default:
                TimeLineView(mast: mast)
            }
            Spacer()
        }
        .frame(minWidth: 400, alignment: .center)
        .padding(.horizontal, 12)
    }
}
       
struct CustomTopTabBar: View
{
    @Binding var tabIndex: Int
    @EnvironmentObject var settings : Settings
    
    var body: some View
    {
        Spacer()
        
        HStack(alignment: .center,spacing: 20)
        {
            Spacer()
            
            TabBarButton(text: "Timelines", isSelected: .constant(settings.tabIndex == 0))
                .onTapGesture { onButtonTapped(index: 0) }
            
            TabBarButton(text: "Accounts", isSelected: .constant(settings.tabIndex == 1))
                .onTapGesture { onButtonTapped(index: 1) }
            
            TabBarButton(text: "Search", isSelected: .constant(settings.tabIndex == 2))
                .onTapGesture { onButtonTapped(index: 2) }
            
            TabBarButton(text: "Settings", isSelected: .constant(settings.tabIndex == 3))
                .onTapGesture { onButtonTapped(index: 3) }
                         
           Spacer()
        }
        .border(width: 1, edges: [.bottom], color: .black)
    }
    
    private func onButtonTapped(index: Int)
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
