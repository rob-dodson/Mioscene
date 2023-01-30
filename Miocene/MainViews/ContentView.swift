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
    @EnvironmentObject var errorSystem : ErrorSystem
    @EnvironmentObject var appState: AppState
    
    
    var body: some View
    {
                VStack
                {
                    GeometryReader
                    { geo in
                        VStack
                        {
                            CustomTopTabBar(tabIndex: $appState.tabIndex)
                            
                            switch appState.tabIndex
                            {
                                case .TimeLine: TimeLineView(mast: mast)
                                case .Accounts: AccountView(mast: mast,maccount: MAccount(displayname: appState.currentUserMastAccount!.displayName, acct: appState.currentUserMastAccount!))
                                case .Search: SearchView(mast: mast)
                                case .Settings: SettingsView()
                            }
                            
                            Spacer()
                        }
                        .frame(minWidth:100,maxHeight: geo.size.height * 1.0)
                    }
            }
            .padding(.horizontal, 20)
    }
}
       
struct CustomTopTabBar: View
{
    @Binding var tabIndex: TabIndex
    
    @EnvironmentObject var settings : Settings
    @EnvironmentObject var appState: AppState
    
    var body: some View
    {
        Spacer()
        
        HStack(alignment: .center,spacing: 70)
        {
            Spacer()
            
            TabBarButton(text: "Timelines",icon:"house", isSelected: .constant(tabIndex == .TimeLine))
                .onTapGesture { onButtonTapped(index: .TimeLine) }
            
            TabBarButton(text: "Accounts",icon:"person", isSelected: .constant(tabIndex == .Accounts))
                .onTapGesture { onButtonTapped(index: .Accounts) }
            
            TabBarButton(text: "Search", icon:"magnifyingglass",isSelected: .constant(tabIndex == .Search))
                .onTapGesture { onButtonTapped(index: .Search) }
            
            TabBarButton(text: "Settings",icon:"gear", isSelected: .constant(tabIndex == .Settings))
                .onTapGesture { onButtonTapped(index: .Settings) }
                         
           Spacer()
        }
        .border(width: 1, edges: [.bottom], color: .black)
    }
    
    private func onButtonTapped(index: TabIndex)
    {
        appState.tabIndex = index
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
                .font(.system(size: CGFloat(settings.iconSize), weight: .light))
                .foregroundColor(isSelected ? settings.theme.accentColor : settings.theme.minorColor)
                .padding(.bottom,10)
        }
    }
}




