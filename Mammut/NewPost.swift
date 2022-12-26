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
    @ObservedObject var settings: Settings
    @State var selectedTimeline : Binding<TimeLine>
    
    
    @State private var shouldPresentSheet = false
    @State private var newPost : String = ""
    
    
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
            
            VStack(alignment: .trailing)
            {
                TextEditor(text: $newPost)
                    .foregroundColor(settings.theme.bodyColor)
                    .font(.custom("HelveticaNeue", size: 18))
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
                        let request = Statuses.create(status:$newPost.wrappedValue)
                        mast.client.run(request)
                        { result in
                            print("result \(result)")
                        }
                        // $newPost = "" only on success
                        shouldPresentSheet = false
                    }
                }
                
                ToolbarItem
                {
                    Text("\(500 - $newPost.wrappedValue.count)")
                        .foregroundColor(.green)
                }
            }
            .frame(width: 400, height: 300)
        }
    }
}

