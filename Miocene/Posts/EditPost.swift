//
//  EditPost.swift
//  Miocene
//
//  Created by Robert Dodson on 1/19/23.
//

import SwiftUI
import MastodonKit


struct EditPost: View
{
    @State var newPost : String = ""
    @State var replyTo : String?
    @State var postVisibility : MastodonKit.Visibility
    var done: () -> Void
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var errorSystem : ErrorSystem
    @EnvironmentObject var appState: AppState

    @State private var shouldPresentSheet = false
    
    @State private var countColor = Color.green
    @State private var showContentWarning = false
    @State private var alertMediaUploading = false
    @State private var contentWarning : String = ""
    @State private var attachedurls = [AttachmentURL]()
    @State private var showPoll = false
    @State private var sensitive = false
    @State private var pollType : PollType = .single
    @State private var pollTime : PollTimes = .fiveMinutes
    @State private var currentSelectedVisibilty = MastodonKit.Visibility.public.rawValue
    @StateObject private var pollState = PollState()
    
    
   
    
    var body: some View
    {
        Text(getTitle())
            .foregroundColor(settings.theme.accentColor)
            .font(settings.font.title)
            .padding(.top)
        
        
        VStack(alignment: .leading)
        {
            if showContentWarning == true
            {
                TextField("Content Warning", text: $contentWarning)
                    .foregroundColor(settings.theme.bodyColor)
                    .font(settings.font.title)
                    .padding()
            }
            
            TextEditor(text: $newPost)
                .foregroundColor(settings.theme.bodyColor)
                .font(settings.font.body)
                .scrollIndicators(.automatic)
            
            
            //
            // Attachments
            //
            HStack
            {
                attachmentsView()
            }
            
            SpacerLine(color: settings.theme.minorColor)

            
            //
            // help text
            //
            VStack(alignment: .leading)
            {
                helpView()
            }
            .padding(EdgeInsets(top: 2, leading: 10, bottom: 10, trailing: 10))
            
            
            
            //
            // poll builder
            //
            if showPoll == true
            {
                SpacerLine(color: settings.theme.minorColor)
                
                PollBuilder(pollState:pollState)
                            
            }
        }
        .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage,done: {
            shouldPresentSheet = false
        })
        .toolbar
        {
            ToolbarItem
            {
                PopButton(text: "Cancel", icon: "trash.slash",isSelected: false)
                {
                    shouldPresentSheet = false
                    done()
                }
            }
            
            ToolbarItem
            {
                PopButton(text: "Photo", icon: "photo",isSelected: false)
                {
                    if let urls = showOpenPanel()
                    {
                        for url in urls
                        {
                            attachedurls.append(AttachmentURL(url:url))
                        }
                    }
                }
            }
            
            ToolbarItem
            {
                PopButton(text: "Sensitive", icon: "eye.slash",isSelected: sensitive)
                {
                    sensitive.toggle()
                }
            }
            
            ToolbarItem
            {
                PopButton(text: "Warning", icon: "exclamationmark.triangle",isSelected: showContentWarning)
                {
                    showContentWarning.toggle()
                }
            }
           
            ToolbarItem
            {
                PopButton(text: "Poll", icon: "chart.bar.doc.horizontal",isSelected: showPoll)
                {
                    showPoll.toggle()
                }
            }
            
            ToolbarItem
            {
                visibilityMenu()
            }
            
            
            
            
            ToolbarItem(placement: .primaryAction)
            {
                PopButton(text: "Post", icon: "paperplane",isSelected: true)
                {
                    let pollpayload = showPoll == true ? PollBuilder.getPollPayLoad(pollState: pollState) : nil
                    
                    alertMediaUploading = (attachedurls.count > 0) ? true : false
                    
                    appState.mastio()?.post(newpost:newPost,
                              replyTo:replyTo,
                              sensitive: sensitive,
                       spoiler:showContentWarning == true ? contentWarning : nil,
                       visibility:postVisibility,
                       attachedURLS:attachedurls,
                       pollpayload:pollpayload)
                       { result in
                            
                             switch result
                             {
                             case .success:
                                shouldPresentSheet = false
                                alertMediaUploading = false
                                done()
                             case .failure(let error):
                                 errorSystem.reportError(type: .postingError,
                                                        msg: error.localizedDescription)
                             }
                       }
                }
                .alert("Uploading media...", isPresented: $alertMediaUploading)
                {
                }
            }
        }
        .frame(height: showPoll == true ? pollViewSize() : 375)
    }
    
    
    func getTitle() -> String
    {
        if replyTo == nil
        {
            return "New Post"
        }
        else
        {
            return postVisibility == .direct ? "Direct Message" : "Reply To"
        }
    }
    
    
    func visibilityMenu() -> some View
    {
        var menuitems = [PopMenuItem<MastodonKit.Visibility>]()

        if replyTo == nil
        {
            menuitems = [PopMenuItem(text: MastodonKit.Visibility.public.rawValue,userData:MastodonKit.Visibility.public),
                        PopMenuItem(text: MastodonKit.Visibility.unlisted.rawValue,userData:MastodonKit.Visibility.unlisted),
                        PopMenuItem(text: MastodonKit.Visibility.private.rawValue,userData:MastodonKit.Visibility.private)
                        ]
        }
        else if postVisibility == .direct
        {
            DispatchQueue.main.async {
                currentSelectedVisibilty = MastodonKit.Visibility.direct.rawValue
            }
            menuitems = [PopMenuItem(text: MastodonKit.Visibility.direct.rawValue,userData:MastodonKit.Visibility.direct)]
        }
        else
        {
            menuitems = [PopMenuItem(text: MastodonKit.Visibility.public.rawValue,userData:MastodonKit.Visibility.public),
                         PopMenuItem(text: MastodonKit.Visibility.unlisted.rawValue,userData:MastodonKit.Visibility.unlisted),
                         PopMenuItem(text: MastodonKit.Visibility.private.rawValue,userData:MastodonKit.Visibility.private),
                         PopMenuItem(text: MastodonKit.Visibility.direct.rawValue,userData:MastodonKit.Visibility.direct)
            ]
        }
        
        return PopMenu(icon: "eye",selected: $currentSelectedVisibilty, menuItems: menuitems)
            { item in
                if let userdata = item.userData
                {
                    postVisibility = userdata
                    currentSelectedVisibilty = postVisibility.rawValue

                }
            }
    }

                                     
    func  pollViewSize() -> CGFloat
    {
        return CGFloat(625 + (pollState.pollOptions.count * 12))
    }
    
    
    func attachmentsView() -> some View
    {
        return HStack
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
                .frame(width: 100, height: 100)
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
    }
    
    func helpView() -> some View
    {
        return VStack(alignment: .leading)
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
            .font(settings.font.footnote)
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
        }
    }

}

