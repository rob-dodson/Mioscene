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
    @ObservedObject var client : Mastodon

    var body: some View
    {
        ZStack
        {
            ScrollView()
            {
                ForEach(client.getStats())
                { mstat in
                        Post(mstat: mstat)
                            .padding(.horizontal)
                            .padding(.top)
                }
            }
        }
        .toolbar
        {
            
            ToolbarItem
            {
                Picker(selection: .constant(1),label: Text("Account"),content:
                        {
                            Text("@rdodson").tag(1)
                            Text("@frogradio").tag(2)
                        })
            }
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
            
            ToolbarItem
            {
                Button
                {
                    
                }
                label:
                {
                    Image(systemName: "square.and.pencil")
                }

            }
            ToolbarItem
            {
                Button
                {
                    
                }
                label:
                {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
}

