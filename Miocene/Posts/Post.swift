//
//  Post.swift
//  Miocene
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit
import AVKit
import SwiftyGif


struct Post: View
{
    @ObservedObject var mast : Mastodon
    @ObservedObject var mstat : MStatus
    var notification : MastodonKit.Notification?
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    
    @State private var showSensitiveContent : Bool = false
    @State private var showContentWarning : Bool = false
    @State private var shouldPresentSheet = false
    @State private var shouldPresentImageSheet = false
    @State private var imageShowIndex : Int  = 1
    @State var datePublished = ""
    @State var hoursstr : String = ""
    
    static var timer : Timer.TimerPublisher?
    
    var body: some View
    {
        let status = mstat.status
        
        if status.reblog != nil
        {
            dopost(status: status.reblog!,mstatus:mstat)
        }
        else
        {
            dopost(status: status,mstatus:mstat)
        }
    }
    
    
    func dopost(status:Status,mstatus:MStatus) -> some View
    {
        GroupBox()
        {
            if let note = notification
            {
                HStack
                {
                    switch note.type
                    {
                        case .favourite:
                            Text("Favorited by")
                        case .follow:
                            Text("Followed by")
                        case .mention:
                            Text("Mentioned by")
                        case .poll:
                            Text("Poll by")
                        case .reblog:
                            Text("Reblogged by")
                        case .other(let textstr):
                            Text("\(textstr)")
                    }
                    
                    AccountSmall(mast:mast,maccount: MAccount(displayname: note.account.displayName, acct: note.account))
                }
                .font(settings.font.headline)
                .foregroundColor(settings.theme.accentColor)
            }
            
            HStack(alignment: .top)
            {
                //
                // Poster's avatar
                //
                if let account = status.account
                {
                    AsyncImage(url: URL(string: account.avatar ?? ""))
                    { image in
                        image.resizable()
                    }
                placeholder:
                    {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                    .onTapGesture
                    {
                        appState.showAccount(maccount:MAccount(displayname: account.displayName, acct: account))
                    }
                }
                
                
                VStack(alignment: .leading,spacing: 10)
                {
                    //
                    // names
                    //
                    VStack(alignment: .leading)
                    {
                        HStack
                        {
                            Text(status.account.displayName)
                                .contentShape(Rectangle())
                                .font(settings.font.headline)
                                .foregroundColor(settings.theme.nameColor)
                                .onTapGesture
                            {
                                appState.showAccount(maccount:MAccount(displayname: status.account.displayName, acct: status.account))
                            }
                            
                            if status.account.bot == true && UserDefaults.standard.bool(forKey: "flagbots") == true
                            {
                                Text("[BOT]")
                                    .foregroundColor(settings.theme.accentColor)
                                    .font(settings.font.footnote)
                            }
                            
                            Text("@\(status.account.acct)")
                                .font(settings.font.subheadline)
                                .foregroundColor(settings.theme.minorColor)
                                .onTapGesture
                            {
                                appState.showAccount(maccount:MAccount(displayname: status.account.displayName, acct: status.account))
                            }
                        }
                        
                        
                        if let appname = status.application?.name
                        {
                            Text("posted with \(appname)")
                                .font(settings.font.footnote).italic()
                                .foregroundColor(settings.theme.minorColor)
                        }
                    }
                    
                    
                    //
                    // content warning
                    //
                    if status.spoilerText.count > 0
                    {
                        HStack
                        {
                            Button
                            {
                                showContentWarning.toggle()
                            }
                        label:
                            {
                                Text("CW")
                            }
                            
                            Text(status.spoilerText)
                        }
                        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
                        .border(width: 1, edges: [.top,.bottom,.leading,.trailing], color: settings.theme.accentColor)
                    }
                 
                    
                    //
                    // html body of post
                    //
                    
                    if status.spoilerText.count == 0 || (status.spoilerText.count > 0 && showContentWarning == true)
                    {
                        let betterPSpaceing = status.content.replacingOccurrences(of: "</p>", with: "</p><br />")
                        if let nsAttrString = betterPSpaceing.htmlAttributedString(color:settings.theme.bodyColor,
                                                                                   linkColor:settings.theme.linkColor,
                                                                                   font: settings.font.body)
                        {
                            Text(AttributedString(nsAttrString))
                                .font(settings.font.body)
                                .foregroundColor(settings.theme.bodyColor)
                                .textSelection(.enabled)
                                
                        }
                    }
                    
                    
                    //
                    // attachments.
                    //
                    if status.sensitive == false || (status.sensitive == true && showSensitiveContent == true)
                    {
                        ForEach(status.mediaAttachments.indices, id:\.self)
                        { index in
                            let attachment = status.mediaAttachments[index]
                            
                            //
                            // video
                            //
                            if attachment.type == .video || attachment.type == .gifv
                            {
                                
                                if  let player = AVPlayer(url: URL(string:attachment.url)!)
                                {
                                    VideoPlayer(player: player)
                                        .frame(width: 400, height: 300, alignment: .center)
                                }
                                else
                                {
                                    Image(systemName: "video.slash.fill")
                                }
                            }
                            //
                            // image
                            //
                            /*
                             else if attachment.type == .gifv
                             {
                             Text(".gifv")
                             gifimage(urlstring:attachment.url)
                             { image in
                             image.resizable()
                             }
                             }*/
                            else if attachment.type == .image
                            {
                                AsyncImage(url: URL(string:attachment.url))
                                { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth:300)
                                }
                            placeholder:
                                {
                                    Image(systemName: "photo")
                                }
                                .cornerRadius(5)
                                .onTapGesture
                                {
                                    if let url = URL(string: status.mediaAttachments[index].url)
                                    {
                                        ShowImagePanel.url = url
                                        shouldPresentImageSheet = true
                                    }
                                }
                                .onDrag()
                                {
                                    NSItemProvider(object: URL(string:attachment.url)! as NSURL) 
                                }
                                .sheet(isPresented: $shouldPresentImageSheet)
                                {
                                }
                            content:
                                {
                                    ShowImagePanel()
                                    {
                                        shouldPresentImageSheet = false
                                    }
                                }
                            }
                            else
                            {
                                Text("IMAGE TYPE NOT SUPPORTED \(attachment.type.rawValue)")
                            }
                        }
                    }
                    
                    //
                    // Cards
                    //
                    if let card = status.card
                    {
                        if settings.showCards == true && card.imageUrl != nil
                        {
                            HStack
                            {
                                AsyncImage(url: card.imageUrl)
                                { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            placeholder:
                                {
                                    Image(systemName: "person.fill.questionmark")
                                }
                                .frame(width: CGFloat(card.width ?? 50) / 3.0, height: CGFloat(card.height ?? 50) / 3.0)
                                
                                VStack
                                {
                                    Text(card.title)
                                }
                                .padding(3)
                            }
                            .onTapGesture
                            {
                                NSWorkspace.shared.open(card.url)
                            }
                            // .frame(minWidth: 150,minHeight: 75)
                            .background(settings.theme.blockColor)
                            .border(width: 1, edges: [.leading,.top,.bottom,.trailing], color: settings.theme.minorColor)
                        }
                    }
                  
                    //
                    // sensitive flag
                    //
                    if status.sensitive == true
                    {
                        PopButtonColor(text: "Sensitive",
                                       icon: "eye.slash",
                                       textColor: settings.theme.accentColor,
                                       iconColor: settings.theme.accentColor,
                                       isSelected: true)
                        {
                            showSensitiveContent.toggle()
                        }
                    }
                    
                    
                    //
                    // Poll
                    //
                    if let poll = status.poll
                    {
                        PollView(mast:mast,poll:poll)
                    }
                    
                    
                    //
                    // tags
                    //
                    if status.tags.count > 0
                    {
                        makeTagStack(tags: status.tags)
                    }
                    
                    
                    //
                    // reblogged
                    //
                    if mstatus.status.reblog != nil
                    {
                        HStack
                        {
                            Image(systemName: "arrow.2.squarepath")
                            Text("by")
                            Text("\(mstatus.status.account.displayName)")
                                .foregroundColor(settings.theme.linkColor)
                                .onTapGesture
                            {
                                appState.showAccount(maccount:MAccount(displayname: mstatus.status.account.displayName, acct: mstatus.status.account))
                            }
                            .onHover
                            { inside in
                                if inside
                                {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        }
                    }
                    
                    
                    //
                    // buttons
                    //
                    HStack(spacing: 10)
                    {
                        if settings.hideStatusButtons == false
                        {
                            //
                            // reply
                            //
                            PopButton(text: "", icon: "arrowshape.turn.up.left",isSelected: false)
                            {
                                shouldPresentSheet.toggle()
                            }
                            .sheet(isPresented: $shouldPresentSheet)
                            {
                            }
                        content:
                            {
                                EditPost(mast: mast,newPost: "@\(status.account.acct): ",title:"Reply",done:
                                {
                                    shouldPresentSheet = false
                                })
                            }
                            
                            
                            //
                            // favorite
                            //
                            PopButtonColor(text: "\(mstatus.favoritesCount)",
                                           icon: "star",
                                           textColor:settings.theme.minorColor,
                                           iconColor:mstatus.favorited == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false)
                            {
                                if mstatus.favorited == true
                                {
                                    mast.unfavorite(status: status)
                                    mstatus.favoritesCount -= 1
                                }
                                else
                                {
                                    mast.favorite(status: status)
                                    mstatus.favoritesCount += 1
                                    
                                }
                                mstatus.favorited.toggle()
                            }
                            
                            
                            //
                            // reblog
                            //
                            PopButtonColor(text: "\(mstatus.reblogsCount)",
                                           icon: "arrow.2.squarepath",
                                           textColor:settings.theme.minorColor,
                                           iconColor:mstatus.reblogged == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false)
                            {
                                if mstatus.reblogged == true
                                {
                                    mast.unreblog(status: status)
                                    mstatus.reblogsCount -= 1
                                }
                                else
                                {
                                    mast.reblog(status: status)
                                    mstatus.reblogsCount += 1
                                    
                                }
                                mstatus.reblogged.toggle()
                            }
                            
                            //
                            // bookmark
                            //
                            PopButtonColor(text: "",
                                           icon: "bookmark",
                                           textColor:settings.theme.minorColor,
                                           iconColor:mstatus.bookmarked == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false)
                            {
                                if mstatus.bookmarked == true
                                {
                                    mast.unbookmark(status: status)
                                }
                                else
                                {
                                    mast.bookmark(status: status)
                                }
                                mstatus.bookmarked.toggle()
                            }
                            
                        }
                        
                        //
                        // created Date
                        //
                        makeDateView(status: status)
                        
                    }
                }
                .frame(minWidth:150,maxWidth:.infinity, alignment: .leading)  // .infinity
            }
            .padding(.bottom,5)
        }
        .background(settings.theme.blockColor)
        .cornerRadius(5)
        .contextMenu
        {
            VStack
            {
                if status.account.id == appState.currentUserMastAccount?.id
                {
                    Button
                    {
                        mast.deletePost(id:status.id)
                    } label: { Image(systemName: "speaker.slash.fill"); Text("Delete Post") }
                }
                
                Button { } label: {  Text("Direct Message @\(status.account.acct)") }
                Button { } label: {  Text("Mute Author") }
                Button { } label: {  Text("Unfollow Author") }
                Button { } label: {  Text("Copy Post Text") }
                Button { } label: {  Text("Copy Link to Post") }
                
            }
        }
    }
    
    
    func makeDateView(status:Status) -> some View
    {
        if Post.timer == nil
        {
            Post.timer = Timer.TimerPublisher.init(interval: 60, runLoop: .main, mode: .common)
            _ = Post.timer!.connect() // do we need to keep this around?
        }
        
        return Text(datePublished)
            .font(settings.font.footnote)
            .foregroundColor(settings.theme.minorColor)
            .onAppear(perform:
                        {
                calcDate(status: status)
            })
            .onReceive(Post.timer!)
        { input in
            calcDate(status: status)
        }
    }
    
    func calcDate(status:Status)
    {
        let tmp_hoursstr = dateSinceNowToString(date: status.createdAt)
        if tmp_hoursstr != hoursstr
        {
            hoursstr = tmp_hoursstr
            datePublished = "\(hoursstr) · \(status.createdAt.formatted(date: .abbreviated, time: .omitted)) · \(status.createdAt.formatted(date: .omitted, time: .standard))"
        }
    }
    
    
    func makeTagStack(tags:[Tag]) -> some View
    {
        return Grid
        {
            Grid()
            {
                ForEach(tags.indices, id:\.self)
                { index in
                    
                    if index % 2 == 0
                    {
                        GridRow
                        {
                            displayTag(name: "#\(tags[index].name)")
                            if (index + 1 < tags.count)
                            {
                                displayTag(name: "#\(tags[index + 1].name)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayTag(name:String) -> some  View
    {
        PopTextButton(text: name, font: settings.font.subheadline, ontap:
        { tag in
            appState.showTag(tag: tag)
        })
        .help(name)
        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
        .background(settings.theme.blockColor)
        .cornerRadius(5)
    }
}


func gifimage(urlstring:String,done: @escaping (Image) -> some View) -> some View
{
        if let url = URL(string:urlstring)
        {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url)
                {
                    if let nsimage = try? NSImage(gifData: data)
                    {
                       _ = done(Image(nsImage: nsimage))
                    }
                }
            }
        }
    return Image(systemName: "gear")
}


