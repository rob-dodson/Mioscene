//
//  Search.swift
//  Mammut
//
//  Created by Robert Dodson on 12/26/22.
//

import SwiftUI
import MastodonKit


struct Search: View
{
    @ObservedObject var mast : Mastodon
    @ObservedObject var settings: Settings
    
    
    @State private var shouldPresentSheet = false
    @State private var searchTerm : String = ""
    
    var body: some View
    {
        Button()
        {
            shouldPresentSheet.toggle()
        }
        label:
        {
            Image(systemName: "magnifyingglass")
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
            print("Sheet dismissed!")
        }
        content:
        {
            Text("Search")
                .foregroundColor(settings.theme.nameColor)
                .padding(.top)
            
            VStack(alignment: .trailing)
            {
                TextField("Search", text: $searchTerm)
                    .padding()
                    .font(.title)
            }
            .toolbar
            {
                ToolbarItem
                {
                    Button("Cancel")
                    {
                        shouldPresentSheet = false
                    }
                }
                
                ToolbarItem
                {
                    Button("Search")
                    {
                        mast.search(query: $searchTerm.wrappedValue)
                        shouldPresentSheet = false
                    }
                }
            }
            .frame(width: 400, height: 100)
        }
    }
}

