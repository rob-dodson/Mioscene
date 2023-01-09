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
    @State private var attachedurls = [AttachmentURL]()
    
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
                
                
                //
                // Attachments
                //
                HStack
                {
                    ForEach($attachedurls)
                    { attachment in
                        AsyncImage(url: attachment.url.wrappedValue)
                        { image in
                            image.resizable()
                        }
                    placeholder:
                        {
                            Image(systemName: "photo")
                        }
                        .frame(width: 70, height: 70)
                        .cornerRadius(5)
                        .contextMenu
                        {
                            Button
                            {
                                attachedurls = attachedurls.filter { $0.id != attachment.id } // magic!
                            }
                        label:
                            { Text("Delete Attachmnt") }
                        }
                    }
                }
                
                Rectangle().frame(height: 1).foregroundColor(.gray)

                
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
                .padding(EdgeInsets(top: 2, leading: 10, bottom: 10, trailing: 10))
                .font(.footnote).italic()
                .foregroundColor(settings.theme.minorColor)
                
            }
            .toolbar
            {
                ToolbarItem
                {
                    Button
                    {
                        let url = showOpenPanel()
                        attachedurls.append(AttachmentURL(url:url))
                    }
                label:
                    {
                        Image(systemName: "photo")
                    }
                }
                
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
                        mast.post(newpost:newPost,spoiler:showContentWarning == true ? contentWarning : nil,visibility:postVisibility,attachedURLS:attachedurls)
                        shouldPresentSheet = false
                    }
                }
            }
            .frame(width: 400, height: 300)
        }
    }
    
}

func showOpenPanel() -> URL?
{
    let openPanel = NSOpenPanel()
    //openPanel.allowedContentTypes =
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    let response = openPanel.runModal()
    return response == .OK ? openPanel.url : nil
}
