//
//  Post.swift
//  Mammut
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
                AsyncImage(url: URL(string: status.account.avatar))
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
                    settings.setSeeAccount(account:status.account)
                    settings.tabIndex = 1
                }
              
                
                VStack(alignment: .leading,spacing: 10)
                {
                    //
                    // names
                    //
                    VStack(alignment: .leading)
                    {
                        Text(status.account.displayName)
                            .font(.title)
                            .foregroundColor(settings.theme.nameColor)
                        
                        let name = "@\(status.account.acct)"
                        Text(name)
                            .font(.title3)
                            .foregroundColor(settings.theme.minorColor)
                        
                        if let appname = status.application?.name
                        {
                            Text("posted with \(appname)")
                                .font(.footnote).italic()
                                .foregroundColor(settings.theme.minorColor)
                        }
                        
                    }
                   
                    
                    //
                    // html body of post
                    //
                    if let nsAttrString = status.content.htmlAttributedString(color:settings.theme.bodyColor,linkColor: settings.theme.linkColor)
                    {
                        Text(AttributedString(nsAttrString))
                            .font(.body)
                            .foregroundColor(settings.theme.bodyColor)
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
                                    settings.setSeeAccount(account:mstatus.status.account)
                                    settings.tabIndex = 1
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
                            .font(.callout)
                            .foregroundColor(settings.theme.dateColor)
                    }
                }
                .frame(maxWidth:.infinity, alignment: .leading)  // .infinity
           }
        }
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
        let max = 300.0
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
                        settings.currentTag = name
                        settings.tabIndex = 0
                    }).help(name)
                }
            }
        }
    }
}





func dateSinceNowToString(date:Date) -> String
{
    let hours = abs(date.timeIntervalSinceNow) / 60 / 60
    if hours > 1.0
    {
        if hours > 24
        {
            return "\(Int(hours / 24))d"
        }
        else
        {
            return "\(Int(hours))h"
        }
    }
    else
    {
        let minutes = 60 * hours
        if minutes >= 1.0
        {
            return "\(Int(minutes))m"
        }
        else
        {
            let seconds = 60 * minutes
            return "\(Int(seconds))s"
        }
    }
    
}


extension String
{
    func htmlAttributedString(fontSize: CGFloat = 16, color : Color = Color.black,linkColor : Color = Color.blue,fontFamily: String = "SF Pro") -> NSAttributedString?
    {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
                body {
                    color: \(color);
                    font-family: \(fontFamily);
                    font-size: \(fontSize)px;
                }
                a {
                    color: \(linkColor);
                }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .unicode) else
        {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }

        return attributedString
    }
}


