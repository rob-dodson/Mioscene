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
    @State private var showContentWarning : Bool = false
    @State private var contentWarning : String = ""
    @State private var postVisibility : MastodonKit.Visibility = .public
    
    
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
                .foregroundColor(settings.theme.accentColor)
                .font(.title)
                .padding(.top)
            
            VStack(alignment: .leading)
            {
                if showContentWarning == true
                {
                    TextField("Content Warning", text: $contentWarning)
                        .foregroundColor(settings.theme.bodyColor)
                        .font(.title)
                        .padding()
                }
                
                TextEditor(text: $newPost)
                    .foregroundColor(settings.theme.bodyColor)
                    .font(.title)
                    .scrollIndicators(.automatic)
                
                VStack
                {
                    switch postVisibility
                    {
                    case .public:
                        Text("The post is public.\nVisible on Profile: Anyone including anonymous viewers.\nVisible on Public Timeline: Yes.\nFederates to other instances: Yes.")
                    case .unlisted:
                        Text("The post is unlisted.\nVisible on Profile: Anyone including anonymous viewers.\nVisible on Public Timeline: No.\nFederates to other instances: Yes.")
                    case .private:
                        Text("The post is private.\nVisible on Profile: Followers only.\nVisible on Public Timeline: No.\nFederates to other instances: Only remote @mentions.")
                    case .direct:
                        Text("The post is direct.\nVisible on Profile: No.\nVisible on Public Timeline: No.\nFederates to other instances: Only remote @mentions.")
                    }
                }
                .padding(EdgeInsets(top: 1, leading: 10, bottom: 10, trailing: 10))
                .font(.footnote).italic()
                .foregroundColor(settings.theme.minorColor)
                
            }
            .toolbar
            {
                ToolbarItem
                {
                    Button
                    {
                        showContentWarning.toggle()
                    }
                label:
                    {
                        Image(systemName: "exclamationmark.triangle")
                    }
                }
               
                
                ToolbarItem
                {
                    Picker("Visibility", selection: $postVisibility)
                    {
                        Text(MastodonKit.Visibility.public.rawValue).tag(MastodonKit.Visibility.public)
                        Text(MastodonKit.Visibility.unlisted.rawValue).tag(MastodonKit.Visibility.unlisted)
                        Text(MastodonKit.Visibility.private.rawValue).tag(MastodonKit.Visibility.private)
                        Text(MastodonKit.Visibility.direct.rawValue).tag(MastodonKit.Visibility.direct)
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
                        mast.post(newpost:newPost,spoiler:showContentWarning == true ? contentWarning : nil,visibility:postVisibility)
                        shouldPresentSheet = false
                    }
                }
            }
            .frame(width: 400, height: 300)
        }
    }
}

