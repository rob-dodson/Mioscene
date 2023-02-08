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
                        case .Search:  SearchView(mast: mast)
                        case .Settings: SettingsView(mast: mast)
                    }
                }
                .frame(minWidth:100,maxHeight: geo.size.height * 1.0)
            }
        }
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
        
        HStack(alignment: .center,spacing: 40)
        {
            PopButton(text: "Timelines",icon:"house", isSelected: tabIndex == .TimeLine ? true : false)
                { onButtonTapped(index: .TimeLine) }
            
            PopButton(text: "Accounts",icon:"person", isSelected: tabIndex == .Accounts ? true : false)
                { onButtonTapped(index: .Accounts) }
            
            PopButton(text: "Search", icon:"magnifyingglass",isSelected: tabIndex == .Search ? true : false)
                 { onButtonTapped(index: .Search) }
            
            PopButton(text: "Settings",icon:"gear", isSelected:tabIndex == .Settings ? true : false)
                { onButtonTapped(index: .Settings) }
        }
        .padding(.bottom,5)
        .border(width: 1, edges: [.bottom], color: .black)
    }
    
    
    private func onButtonTapped(index: TabIndex)
    {
        appState.tabIndex = index
    }
}






