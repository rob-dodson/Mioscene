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
    @EnvironmentObject var alertSystem : AlertSystem
    @EnvironmentObject var appState : AppState

    
    var body: some View
    {
        VStack
        {
            GeometryReader
            { geo in
                
                HStack(alignment: .top,spacing: 10)
                {
                    CustomTopTabBar(tabIndex: $appState.tabIndex)
                    
                    Rectangle().frame(width:0.5,height: geo.size.height).foregroundColor(settings.theme.minorColor)
                    
                    switch appState.tabIndex
                    {
                        case .TimeLine: TimeLineView(timelineManger: TimelineManager())
                        case .Accounts: AccountView()
                        case .Search:  SearchView()
                        case .Settings: SettingsView()
                    }
                }
                .frame(minWidth:100,maxHeight: geo.size.height)
            }
        }
        .background(settings.theme.appbackColor)
        .errorAlert(error: $alertSystem.errorType,msg:alertSystem.errorMessage,done: {})
        .messageAlert(title: "Info", show:$alertSystem.infoType, msg: alertSystem.infoMessage, done: {})
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
        
        VStack(alignment: .center,spacing: 30)
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
        .padding(.top,15)
        //.border(width: 1, edges: [.bottom], color: .black)
    }
    
    
    private func onButtonTapped(index: TabIndex)
    {
        appState.tabIndex = index
    }
}




/*
 
 var body: some View
 {
 GeometryReader
 { geo in
 VStack(alignment: .leading)
 {
 NavigationStack
 {
 NavigationLink { TimeLineView(timelineManger: TimelineManager()) } label: { Text("Timeline") }
 NavigationLink { AccountView() } label: { Text("Accounts") }
 NavigationLink { SearchView() } label: { Text("Search") }
 NavigationLink { SettingsView() } label: { Text("Settings") }
 }
 }
 .frame(width: geo.size.width,height:geo.size.height)
 .background(settings.theme.appbackColor)
 .errorAlert(error: $alertSystem.errorType,msg:alertSystem.errorMessage,done: {})
 .messageAlert(title: "Info", show:$alertSystem.infoType, msg: alertSystem.infoMessage, done: {})
 }
 }
 */

