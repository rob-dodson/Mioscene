//
//  ToolBar.swift
//  Mammut
//
//  Created by Robert Dodson on 12/18/22.
//

import SwiftUI
import MastodonKit


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
                })
    }
    
    
    //
    // timeline
    //
    ToolbarItem
    {
        Picker(selection: .constant(1),label: Text("Timeline"),content:
        {
            Text("Home").tag(1)
            Text("Local").tag(2)
            Text("Public").tag(3)
            Text("Notifications").tag(4)
        })
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


