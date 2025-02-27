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
    @ObservedObject var mstat : MStatus
    var notification : MastodonKit.Notification?
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var alertSystem : AlertSystem
    
    @State private var showSensitiveContent : Bool = false
    @State private var showContentWarning : Bool = false
    @State private var shouldPresentDirectSheet = false
    @State private var shouldPresentSheet = false
    @State private var shouldPresentImageSheet = false
    @State private var imageShowIndex : Int  = 1
    @State var datePublished = ""
    @State var hoursstr : String = ""
    @State var replyStatus : MStatus?
    @State var replyTo: Bool = false
    
    
    static var timer : Timer.TimerPublisher?
    
    
    var body: some View
    {
        let status = mstat.status
        
        if status.reblog != nil
        {
            return dopost(status: status.reblog!,mstatus:mstat)
        }
        else
        {
            return dopost(status: status,mstatus:mstat)
        }
    }
    
    
    func dopost(status:Status,mstatus:MStatus) -> some View
    {
        return GroupBox()
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
                    
                    AccountSmall(account: note.account,showDetails: false)
                }
                .font(settings.font.footnote)
                .foregroundColor(settings.theme.accentColor)
                .padding(.bottom)
            }

           
            VStack
            {
                if replyTo == false
                {
                    if let replyid = status.inReplyToID
                    {
                        getReplyToStatus(id: replyid)
                    }
                }
            
                HStack(alignment: .top)
                {
                    //
                    // Poster's avatar
                    //
                    let account = status.account
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
                        appState.showAccount(showaccount:account)
                    }
                    
                    
                    VStack(alignment: .leading,spacing: 10)
                    {
                        //
                        // names
                        //
                        VStack(alignment: .leading,spacing: -2)
                        {
                            HStack
                            {
                                Text(status.account.displayName)
                                    .contentShape(Rectangle())
                                    .font(settings.font.headline)
                                    .foregroundColor(settings.theme.nameColor)
                                    .onTapGesture
                                {
                                    appState.showAccount(showaccount:status.account)
                                }
                                
                                if status.account.bot == true && UserDefaults.standard.bool(forKey: "flagbots") == true
                                {
                                    Text("[BOT]")
                                        .foregroundColor(settings.theme.accentColor)
                                        .font(settings.font.footnote)
                                }
                            }
                            
                            Text("@\(status.account.acct)")
                                .font(settings.font.subheadline)
                                .foregroundColor(settings.theme.minorColor)
                                .onTapGesture
                            {
                                appState.showAccount(showaccount:status.account)
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
                            HStack(alignment: .center)
                            {
                                PopButton(text: "", icon: "exclamationmark.triangle", isSelected: showContentWarning == true ? false : true,help:"Toggle Content Warning (CW)")
                                {
                                    showContentWarning.toggle()
                                }
                                
                                Text(status.spoilerText)
                                    .baselineOffset(15.0)
                            }
                            .padding(EdgeInsets(top: 4, leading: 4, bottom: -12, trailing: 4))
                            .border(width: 1, edges: [.top,.bottom,.leading,.trailing], color: settings.theme.accentColor)
                            .onTapGesture
                            {
                                showContentWarning.toggle()
                            }
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
                                    let player = AVPlayer(url: URL(string:attachment.url)!)
                                    VideoPlayer(player: player)
                                        .frame(width: 400, height: 300, alignment: .center)
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
                                    Text("ATTACHMENT TYPE NOT SUPPORTED \(attachment.type.rawValue)")
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
                                            .frame(height:90)
                                    }
                                placeholder:
                                    {
                                        Image(systemName: "person.fill.questionmark")
                                    }
                                    
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
                                .frame(width: 300,height: 90)
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
                                           isSelected: true,
                                           help:"Toggle Sensitive")
                            {
                                showSensitiveContent.toggle()
                            }
                        }
                        
                        
                        //
                        // Poll
                        //
                        if let poll = status.poll
                        {
                            PollView(poll:poll)
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
                                    appState.showAccount(showaccount: mstatus.status.account)
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
                            if settings.hideStatusButtons == false && replyTo == false
                            {
                                //
                                // reply
                                //
                                PopButton(text: "", icon: "arrowshape.turn.up.left",isSelected: false,help:"Reply to this author")
                                {
                                    shouldPresentSheet.toggle()
                                }
                                
                                
                                
                                //
                                // favorite
                                //
                                PopButtonColor(text: "\(mstatus.favoritesCount)",
                                               icon: "star",
                                               textColor:settings.theme.minorColor,
                                               iconColor:mstatus.favorited == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false,help:"Mark as favorite")
                                {
                                    if mstatus.favorited == true
                                    {
                                        appState.mastio()?.unfavorite(status: status)
                                        mstatus.favoritesCount -= 1
                                    }
                                    else
                                    {
                                        appState.mastio()?.favorite(status: status)
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
                                               iconColor:mstatus.reblogged == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false,help:"Reblog this post")
                                {
                                    if mstatus.reblogged == true
                                    {
                                        appState.mastio()?.unreblog(status: status)
                                        mstatus.reblogsCount -= 1
                                    }
                                    else
                                    {
                                        appState.mastio()?.reblog(status: status)
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
                                               iconColor:mstatus.bookmarked == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false,help:"Bookmark this post")
                                {
                                    if mstatus.bookmarked == true
                                    {
                                        appState.mastio()?.unbookmark(status: status)
                                    }
                                    else
                                    {
                                        appState.mastio()?.bookmark(status: status)
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
            }
            .padding(.bottom,5)
        }
        .sheet(isPresented: $shouldPresentDirectSheet)
        {
        }
    content:
        {
            EditPost(newPost: "@\(status.account.acct): ",replyTo:mstat.status.id,postVisibility:.direct)
            {
                shouldPresentDirectSheet = false
            }
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
        }
    content:
        {
            EditPost(newPost: "@\(status.account.acct): ",replyTo:mstat.status.id,postVisibility:.public)
            {
                shouldPresentSheet = false
            }
        }
        .background(status.account.id == appState.currentMastodonAccount()?.id ?
                    (replyTo == false ? settings.theme.ownpostColor : settings.theme.replyToColor) :
                        (replyTo == false ? settings.theme.blockColor : settings.theme.replyToColor))
        .cornerRadius(5)
        .padding(EdgeInsets(top: replyTo == false ? 0.0 : 0.0,
                            leading: replyTo == false ? 0.0 : 20.0,
                            bottom: replyTo == false ? 0.0 : 20.0,
                            trailing: replyTo == false ? 0.0 : 20.0))
        .contextMenu
        {
            contextMenu(status:status)
        }
    }
    
    
    func getReplyToStatus(id:String) -> some View
    {
        Task
        {
            if let reply = await appState.mastio()?.getStatus(id:id)
            {
                replyStatus = reply
            }
        }
        
        return VStack(alignment: .leading)
        {
            Text("In reply to:")
                .contentShape(Rectangle())
                .font(settings.font.headline)
                .foregroundColor(settings.theme.accentColor)
                .onTapGesture
            {
            }
            
            if let status = replyStatus
            {
                Post(mstat: status,replyTo: true)
            }
        }
        
    }
    
    
    func contextMenu(status:Status) -> some View
    {
        VStack
        {
            if let account = appState.currentMastodonAccount()
            {
                if status.account.id == account.id
                {
                    Button
                    {
                        appState.mastio()?.deletePost(id:status.id)
                        AlertSystem.shared?.showMessage(type:.info,msg: "Post deleted")
                    } label: { Image(systemName: "speaker.slash.fill"); Text("Delete Post") }
                    
                    Button
                    {
                        Log.logAlert(errorType: .notimplemented, msg: "Pin coming soon")
                    } label: { Image(systemName: "pin"); Text("Pin") }
                    
                    Button
                    {
                        Log.logAlert(errorType: .notimplemented, msg: "Unpin coming soon.")
                    } label: { Image(systemName: "pin.slash"); Text("UnPin") }
                }
            }
            
            
            Button
            {
                shouldPresentDirectSheet.toggle()
            } label: {  Text("Direct Message @\(status.account.acct)") }
            
            Button
            {
                appState.mastio()?.mute(account: status.account, done: { result in })
                AlertSystem.shared?.showMessage(type:.info,msg:"\(status.account.displayName) muted")
            } label: {  Text("Mute Author") }
            
            Button
            {
                appState.mastio()?.unfollow(account: status.account, done: { result in })
                AlertSystem.shared?.showMessage(type:.info,msg:"\(status.account.displayName) unfollowed")
            } label: {  Text("Unfollow Author") }
            
            Button
            {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(status.content, forType: .string)
                AlertSystem.shared?.showMessage(type:.info,msg:"Link copied to pasteboard")
            } label: {  Text("Copy Post Text") }
            
            Button
            {
                NSPasteboard.general.clearContents()
                if let url = status.url
                {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.absoluteString, forType: .string)
                    AlertSystem.shared?.showMessage(type:.info,msg:"Link copied to pasteboard")
                }
            } label: {  Text("Copy Link to Post") }
            
            
            Button
            {
                Log.logAlert(errorType: .notimplemented,msg: "Threading coming soon!")
            } label: {  Text("Show Thread") }
            
            Button
            {
                Log.logAlert(errorType: .notimplemented,msg: "Report Post coming soon!")
            } label: {  Text("Report Post") }
            
            Button
            {
                Log.logAlert(errorType: .notimplemented,msg: "Report User coming soon!")
            } label: {  Text("Report User") }
        }
    }
    
    
    func makeDateView(status:Status) -> some View
    {
        if Post.timer == nil
        {
            Post.timer = Timer.TimerPublisher.init(interval: 60, runLoop: .main, mode: .common)
            _ = Post.timer!.connect() // do we need to keep this around?
        }
        
        return Text(hoursstr)
            .font(settings.font.footnote)
            .foregroundColor(settings.theme.minorColor)
            .onAppear(perform:
                        {
                calcDate(status: status)
            })
            .help(datePublished)
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
                            displayTag(tag: tags[index])
                            if (index + 1 < tags.count)
                            {
                                displayTag(tag: tags[index + 1])
                            }
                        }
                    }
                }
            }
        }
    }
 
    
    func displayTag(tag:Tag) -> some View
    {
        var following = false
        
        if let tagdict = appState.getTagDict()
        {
            if tagdict[tag.name.uppercased()] != nil
            {
               following = true
            }
        }
        
        let textcolor = following == false ? settings.theme.minorColor : settings.theme.accentColor
        
        return  PopTextButton(text: "#\(tag.name)", font: settings.font.subheadline, textColor: textcolor ,help:"Tag #\(tag.name)", ontap:
        { tag in
            appState.showTag(showtag: tag)
        })
        .help("#\(tag.name)")
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
        .contextMenu
        {
                if following == false
                {
                    Button
                    {
                        appState.followTag(tag: tag)
                    }
                label:
                    {
                        Text("Follow this tag")
                    }
                }
                else
                {
                    Button
                    {
                        appState.unfollowTag(tag: tag)
                    }
                label:
                    {
                        Text("Unfollow this tag")
                    }
                }
        }
    }
}


func gifimage(urlstring:String,done: @escaping (Image) -> some View) -> some View
{
    if let url = URL(string:urlstring)
    {
        Task
        { @MainActor in
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


