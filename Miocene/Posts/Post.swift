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
    @EnvironmentObject var errorSystem : ErrorSystem
    
    @State private var showSensitiveContent : Bool = false
    @State private var showContentWarning : Bool = false
    @State private var shouldPresentDirectSheet = false
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
                    
                    AccountSmall(account: note.account)
                }
                .font(settings.font.headline)
                .foregroundColor(settings.theme.accentColor)
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
                                appState.showAccount(showaccount:status.account)
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
                                appState.showAccount(showaccount:status.account)
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
                        HStack(alignment: .center)
                        {
                            PopButton(text: "", icon: "exclamationmark.triangle", isSelected: showContentWarning == true ? false : true)
                            {
                                showContentWarning.toggle()
                            }
                            
                            Text(status.spoilerText)
                                .baselineOffset(15.0)
                        }
                        .padding(EdgeInsets(top: 4, leading: 4, bottom: -12, trailing: 4))
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
                        if settings.hideStatusButtons == false
                        {
                            //
                            // reply
                            //
                            PopButton(text: "", icon: "arrowshape.turn.up.left",isSelected: false)
                            {
                                shouldPresentSheet.toggle()
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
                                           iconColor:mstatus.reblogged == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false)
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
                                           iconColor:mstatus.bookmarked == true ? settings.theme.accentColor : settings.theme.bodyColor,isSelected: false)
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
            .padding(.bottom,5)
        }
        .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage,done: {  })
        .messageAlert(title: "Info", show:$errorSystem.infoType, msg: errorSystem.infoMessage, done: {  })
        .sheet(isPresented: $shouldPresentDirectSheet)
        {
        }
    content:
        {
            EditPost(newPost: "@\(status.account.acct): ",replyTo:status.account.id,postVisibility:.direct)
            {
                shouldPresentDirectSheet = false
            }
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
        }
    content:
        {
            EditPost(newPost: "@\(status.account.acct): ",replyTo:status.account.id,postVisibility:.public)
            {
                shouldPresentSheet = false
            }
        }
        .background(settings.theme.blockColor)
        .cornerRadius(5)
        .contextMenu
        {
            contextMenu(status:status)
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
                    Button  // PopMenuHere?
                    {
                        appState.mastio()?.deletePost(id:status.id)
                        errorSystem.showMessage(type:.info,msg: "Post deleted")
                    } label: { Image(systemName: "speaker.slash.fill"); Text("Delete Post") }
                    
                    Button
                    {
                        errorSystem.reportError(type: .notimplemented,msg: "Soon!")
                    } label: { Image(systemName: "pin"); Text("Pin") }
                    
                    Button
                    {
                        errorSystem.reportError(type: .notimplemented,msg: "Soon!")
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
                errorSystem.showMessage(type:.info,msg: "\(status.account.displayName) muted")
            } label: {  Text("Mute Author") }
            
            Button
            {
                appState.mastio()?.unfollow(account: status.account, done: { result in })
                errorSystem.showMessage(type:.info,msg: "\(status.account.displayName) unfollowed")
            } label: {  Text("Unfollow Author") }
            
            Button
            {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(status.content, forType: .string)
                errorSystem.showMessage(type:.info,msg: "Text copied to pasteboard")
            } label: {  Text("Copy Post Text") }
            
            Button
            {
                NSPasteboard.general.clearContents()
                if let url = status.url
                {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(url.absoluteString, forType: .string)
                    errorSystem.showMessage(type:.info,msg: "Link copied to pasteboard")
                }
            } label: {  Text("Copy Link to Post") }
            
            
            Button
            {
                errorSystem.reportError(type: .notimplemented,msg: "Soon!")
            } label: {  Text("Show Thread") }
            
            Button
            {
                errorSystem.reportError(type: .notimplemented,msg:  "Soon!")
            } label: {  Text("Report Post") }
            
            Button
            {
                errorSystem.reportError(type: .notimplemented,msg:  "Soon!")
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
            appState.showTag(showtag: tag)
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


