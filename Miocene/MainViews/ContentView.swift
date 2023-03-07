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
    @EnvironmentObject var settings : Settings
    @EnvironmentObject var errorSystem : AlertSystem
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
                        case .TimeLine: TimeLineView(timelineManger: TimelineManager(settings: settings, appState: appState))
                        case .Accounts: AccountView()
                        case .Search:  SearchView()
                        case .Settings: SettingsView()
                    }
                }
                .frame(minWidth:100,maxHeight: geo.size.height * 1.0)
            }
        }
        .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage,done: {})
        .messageAlert(title: "Info", show:$errorSystem.infoType, msg: errorSystem.infoMessage, done: {})
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
            PopButton(text: "Timelines",icon:"house", isSelected: tabIndex == .TimeLine ? true : false,help:"Show Timelines")
                { onButtonTapped(index: .TimeLine) }
            
            PopButton(text: "Accounts",icon:"person", isSelected: tabIndex == .Accounts ? true : false,help:"Show Accounts")
                { onButtonTapped(index: .Accounts) }
            
            PopButton(text: "Search", icon:"magnifyingglass",isSelected: tabIndex == .Search ? true : false,help:"Search")
                 { onButtonTapped(index: .Search) }
            
            PopButton(text: "Settings",icon:"gear", isSelected:tabIndex == .Settings ? true : false,help:"Settings")
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






