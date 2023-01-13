//
//  NewPost.swift
//  Miocene
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit

enum PollType : String, Identifiable, CaseIterable
{
    case single = "Single Choice"
    case muliple = "Multiple Choice"
    
    var id: Self { return self }
}

enum PollTimes : String, Identifiable, CaseIterable
{
    case fiveMinutes = "5 minutes"
    case thirtyMinutes = "30 minutes"
    case oneHour = "1 hour"
    case sixHours = "6 hours"
    case oneDay = "1 day"
    case threeDays = "3 days"
    case oneWeek = "1 week"

    var id: Self { return self }
}


struct NewPost: View
{
    @ObservedObject var mast : Mastodon
    @EnvironmentObject var settings: Settings
    @State var selectedTimeline : Binding<TimeLine>
    
    @State private var shouldPresentSheet = false
    @State private var newPost : String = ""
    @State private var countColor = Color.green
    @State private var showContentWarning = false
    @State private var contentWarning : String = ""
    @State private var postVisibility : MastodonKit.Visibility = .public
    @State private var attachedurls = [AttachmentURL]()
    @State private var showPoll = false
    @State private var pollOptionNames  = Array(repeating: "", count: 4)
    @State private var pollType : PollType = .single
    @State private var pollTime : PollTimes = .fiveMinutes
    
    
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
            Log.log(msg:"Sheet dismissed!")
        }
        content:
        {
            Text("New Post")
                .foregroundColor(settings.theme.accentColor)
                .font(settings.fonts.title)
                .padding(.top)
            
            
            VStack(alignment: .leading)
            {
                if showContentWarning == true
                {
                    TextField("Content Warning", text: $contentWarning)
                        .foregroundColor(settings.theme.bodyColor)
                        .font(settings.fonts.title)
                        .padding()
                }
                
                TextEditor(text: $newPost)
                    .foregroundColor(settings.theme.bodyColor)
                    .font(settings.fonts.title)
                    .scrollIndicators(.automatic)
                    .frame(height:200)
                
                
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
                
                SpacerLine(color: settings.theme.minorColor)

                
                //
                // help text
                //
                VStack(alignment: .leading)
                {
                    HStack
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
                    .font(settings.fonts.small)
                    .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 0))
                
                    
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
                    .font(.footnote).italic()
                    .foregroundColor(settings.theme.minorColor)
                    .frame(height: 65)
                }
                .padding(EdgeInsets(top: 2, leading: 10, bottom: 10, trailing: 10))
                
                
                
                //
                // poll builder
                //
                if showPoll == true
                {
                    SpacerLine(color: settings.theme.minorColor)
                    
                    VStack(alignment: .center)
                    {
                        Text("Poll")
                            .foregroundColor(settings.theme.accentColor)
                            .font(settings.fonts.title)
                        
                        VStack(alignment: .leading,spacing: 10)
                        {
                            ForEach(pollOptionNames.indices, id:\.self)
                            { index in
                                HStack
                                {
                                    TextField("Poll Option Name", text: $pollOptionNames[index])
                                    
                                    Button
                                    {
                                        if pollOptionNames.count > 2
                                        {
                                            pollOptionNames.remove(at: index)
                                        }
                                    }
                                label:
                                    {
                                        Text("- Remove")
                                    }
                                }
                            }
                        }

                        HStack
                        {
                            Button
                            {
                                if pollOptionNames.count < 10 // WHAT IS MAX?
                                {
                                    pollOptionNames.append("")
                                }
                            }
                        label:
                            {
                                Text("+ Add")
                            }

                       
                            Picker("", selection: $pollType)
                            {
                                ForEach(PollType.allCases)
                                { polltype in
                                    Text(polltype.rawValue.capitalized)
                                }
                            }
                            .frame(width: 150)
                            
                            Picker("", selection: $pollTime)
                            {
                                ForEach(PollTimes.allCases)
                                { polltime in
                                    Text(polltime.rawValue.capitalized)
                                }
                            }
                            .frame(width: 150)
                        }
                    }
                    .padding()
                }
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
                        if showContentWarning == true
                        {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(settings.theme.accentColor)
                        }
                        else
                        {
                            Image(systemName: "exclamationmark.triangle")
                        }
                    }
                }
               
                ToolbarItem
                {
                    Button
                    {
                        showPoll.toggle()
                    }
                label:
                    {
                        if showPoll == true
                        {
                            Image(systemName: "chart.bar.doc.horizontal")
                                .foregroundColor(settings.theme.accentColor)
                        }
                        else
                        {
                            Image(systemName: "chart.bar.doc.horizontal")
                        }
                    }

                }
                
                ToolbarItem
                {
                    Picker("", selection: $postVisibility)
                    {
                        Text(MastodonKit.Visibility.public.rawValue).tag(MastodonKit.Visibility.public)
                        Text(MastodonKit.Visibility.unlisted.rawValue).tag(MastodonKit.Visibility.unlisted)
                        Text(MastodonKit.Visibility.private.rawValue).tag(MastodonKit.Visibility.private)
                        Text(MastodonKit.Visibility.direct.rawValue).tag(MastodonKit.Visibility.direct)
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
            .frame(width:400,height:.infinity)
        }
    }
    
}

