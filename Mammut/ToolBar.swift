//
//  ToolBar.swift
//  Mammut
//
//  Created by Robert Dodson on 12/18/22.
//

import SwiftUI
import MastodonKit

enum TimeLine : String, CaseIterable, Identifiable
{
    case home, localTimeline, publicTimeline, notifications
    var id: Self { self }
}

class MToolBar
{
    @State  var timeLine: TimeLine = .home
    
@ToolbarContentBuilder
func mammutToolBar() -> some ToolbarContent
    {
       
        //
        // account
        //
        ToolbarItem
        {
            Picker(selection: .constant(1),label: Text("Account"),content:
                    {
                Text("@rdodson").tag(1)
                Text("@frogradio").tag(2)
                Text("Add Account...").tag(3)
            })
        }
        
        
        //
        // timeline
        //
        ToolbarItem
        {
            Picker("Timeline",selection: $timeLine)
                    {
                        Text("Home").tag(TimeLine.home)
                        Text("Local").tag(TimeLine.localTimeline)
                        Text("Public").tag(TimeLine.publicTimeline)
                        Text("Notifications").tag(TimeLine.notifications)
                    }
        }
        
        
        //
        // new post
        //
        ToolbarItem
        {
            Button
            {
                MammutApp.openCurrentUserAccountURL()
            }
        label:
            {
                Image(systemName: "square.and.pencil")
            }
        }
        
        
        //
        // search
        //
        ToolbarItem
        {
            Button
            {
                MammutApp.openCurrentUserAccountURL()
            }
        label:
            {
                Image(systemName: "magnifyingglass")
            }
            
        }
        
        //
        // settings
        //
        ToolbarItem
        {
            Button
            {
            }
        label:
            {
                Image(systemName: "gearshape")
            }
        }
    }
}


