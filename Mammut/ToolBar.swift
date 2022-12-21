//
//  ToolBar.swift
//  Mammut
//
//  Created by Robert Dodson on 12/18/22.
//

import SwiftUI
import MastodonKit


class MToolBar
{
    @ObservedObject var mast = Mastodon.shared
    @State private var selectedTimeline: TimeLine = .home

    
    
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
            Picker("Timeline",selection: $selectedTimeline)
                    {
                        ForEach(TimeLine.allCases)
                        { timeline in
                               Text(timeline.rawValue.capitalized)
                        }
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


