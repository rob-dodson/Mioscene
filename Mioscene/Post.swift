//
//  Post.swift
//  Miocene
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit
import AVKit


struct Post: View
{
    @ObservedObject var mast : Mastodon
    @ObservedObject var mstat : MStatus
    
    @EnvironmentObject var settings: Settings
    
    @State var showSensitiveContent : Bool = false
    
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
                    .cornerRadius(15)
                    .onTapGesture
                    {
                        settings.showAccount(account:account)
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
                                    settings.showAccount(account:status.account)
                                }
                                
                            if status.account.bot == true
                            {
                                Text("[BOT]")
                                    .foregroundColor(settings.theme.accentColor)
                                    .font(settings.font.subheadline)
                            }
                            
                            Text("@\(status.account.acct)")
                                .font(settings.font.subheadline)
                                .foregroundColor(settings.theme.minorColor)
                                .onTapGesture
                                {
                                    settings.showAccount(account:status.account)
                                }
                        }
                        
                      
                        if let appname = status.application?.name
                        {
                            Text("posted with \(appname)")
                                .font(settings.font.footnote).italic()
                                .foregroundColor(settings.theme.minorColor)
                        }
                        
                    }
                   
                    if status.sensitive == true
                    {
                        HStack
                        {
                            Button
                            {
                                showSensitiveContent.toggle()
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

                    if status.sensitive == false || (status.sensitive == true && showSensitiveContent == true)
                    {
                        //
                        // html body of post
                        //
                        if let nsAttrString = status.content.htmlAttributedString(fontSize: settings.font.html,color:settings.theme.bodyColor,linkColor: settings.theme.linkColor,fontFamily: settings.font.name)
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
                    ForEach(status.mediaAttachments.indices, id:\.self)
                    { index in
                        let attachment = status.mediaAttachments[index]
                        
                        //
                        // video
                        //
                        if attachment.type == .video
                        {
                            let player = AVPlayer(url: URL(string:attachment.url)!)
                            VideoPlayer(player: player)
                                .frame(width: 400, height: 300, alignment: .center)
                            
                        }
                        //
                        // image
                        //
                        else if attachment.type == .image || attachment.type == .gifv
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
                            .cornerRadius(15)
                            .onTapGesture
                            {
                                if let url = URL(string:attachment.url)
                                {
                                    NSWorkspace.shared.open(url)
                                }
                            }
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
                                    settings.showAccount(account:mstatus.status.account)
                                }
                        }
                    }
                
                    
                    //
                    // buttons
                    //
                    HStack(spacing: 10)
                    {
                        //
                        // reply
                        //
                        Button
                        {
                        
                        }
                    label:
                        {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .foregroundColor(settings.theme.minorColor)
                        }
                        
                        
                        //
                        // favorite
                        //
                        Button
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
                    label:
                        {
                            HStack
                            {
                                if mstatus.favorited == true
                                {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                else
                                {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(settings.theme.minorColor)
                                }
                                Text("\(mstatus.favoritesCount)")
                            }
                        }
                       
                        
                        //
                        // reblog
                        //
                        Button
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
                    label:
                        {
                            HStack
                            {
                                if mstatus.reblogged == true
                                {
                                    Image(systemName: "arrow.2.squarepath")
                                        .foregroundColor(Color("AccentColor"))
                                }
                                else
                                {
                                    Image(systemName: "arrow.2.squarepath")
                                        .foregroundColor(settings.theme.minorColor)
                                }
                                Text("\(mstatus.reblogsCount)")
                            }
                        }
                        
                        //
                        // created Date
                        //
                        let hoursstr = dateSinceNowToString(date: status.createdAt)
                        Text("\(hoursstr) · \(status.createdAt.formatted(date: .abbreviated, time: .omitted)) · \(status.createdAt.formatted(date: .omitted, time: .standard))")
                            .font(settings.font.footnote)
                            .foregroundColor(settings.theme.minorColor)
                    }
                }
                .frame(maxWidth:.infinity, alignment: .leading)  // .infinity
           }
            .padding(.bottom,5)
        }
        .background(settings.theme.blockColor)
        .cornerRadius(5)
        .contextMenu
        {
            VStack
            {
                Button { } label: { Image(systemName: "mail"); Text("Mail Author") }
                Button { } label: { Image(systemName: "speaker.slash.fill"); Text("Mute Author") }
                Button { } label: { Image(systemName: "mail"); Text("Unfollow Author") }
            }
        }
    }
    
    func makeTagStack(tags:[Tag]) -> some View
    {
        let min = 50.0
        let max = 400.0
        let columns = [
            GridItem(.flexible(minimum: min, maximum: max)),
            GridItem(.flexible(minimum: min, maximum: max)),
            GridItem(.flexible(minimum: min, maximum: max)),
            GridItem(.flexible(minimum: min, maximum: max)),
            ]
        
        return Grid
        {
            LazyVGrid(columns: columns,alignment:.leading)
            {
                ForEach(tags.indices, id:\.self)
                { index in
                    let name = "#\(tags[index].name)"
                    Button(name, action:
                    {
                        settings.showTag(tag: name)
                    }).help(name)
                }
            }
        }
    }
}


