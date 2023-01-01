//
//  NewPost.swift
//  Mammut
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit


struct NewPost: View
{
    @ObservedObject var mast : Mastodon
    @EnvironmentObject var settings: Settings
    @State var selectedTimeline : Binding<TimeLine>
    
    
    @State private var shouldPresentSheet = false
    @State private var newPost : String = ""
    @State private var countColor = Color.green
    
    var body: some View
    {
        Button()
        {
            shouldPresentSheet.toggle()
        }
        label:
        {
            Image(systemName: "square.and.pencil")
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
            print("Sheet dismissed!")
        }
        content:
        {
            Text("New Post")
                .foregroundColor(settings.theme.nameColor)
                .padding(.top)
            
            VStack(alignment: .trailing)
            {
                TextEditor(text: $newPost)
                    .foregroundColor(settings.theme.bodyColor)
                    .font(.title)
                    .scrollIndicators(.automatic)
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
                    Button("Post")
                    {
                        mast.post(newpost:$newPost.wrappedValue)
                        shouldPresentSheet = false
                    }
                }
                
                ToolbarItem
                {
                    if $newPost.wrappedValue.count <= 500
                    {
                        Text("\(500 - $newPost.wrappedValue.count)")
                            .foregroundColor(.green)
                    }
                    else
                    {
                        Text("\(500 - $newPost.wrappedValue.count)")
                            .foregroundColor(.red)
                    }
                }
            }
            //.frame(width: 400, height: 300)
        }
    }
}

