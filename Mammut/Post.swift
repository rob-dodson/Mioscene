//
//  Post.swift
//  Mammut
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit



struct Post: View
{
    var mstat : MStatus
    
    
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
                    AsyncImage(url: URL(string: status.account.avatar)) { image in
                        image.resizable()
                    } placeholder: {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(15)
              
                
                
                VStack(alignment: .leading,spacing: 10)
                {
                    VStack(alignment: .leading)
                    {
                        Text(status.account.displayName)
                            .font(.title)
                            .foregroundColor(.white)
                        Text(status.account.acct)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    
                    if let nsAttrString = status.content.htmlAttributedString()
                    {
                        Text(AttributedString(nsAttrString))
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    
                    if status.tags.count > 0
                    {
                        HStack
                        {
                            ForEach(status.tags.indices)
                            { index in
                                Button("\(status.tags[index].name)", action:
                                {
                                    if let url = URL(string:status.tags[index].url)
                                    {
                                        NSWorkspace.shared.open(url)
                                    }
                                })
                            }
                        }
                    }
                            
                    if mstatus.status.reblog != nil
                    {
                        HStack
                        {
                            Image(systemName: "arrow.2.squarepath")
                            Text("by \(mstatus.status.account.displayName)").foregroundColor(.orange)
                        }
                    }
                
                    
                        
                    HStack(spacing: 10)
                    {
                        Button
                        {
                            
                        }
                    label:
                        {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                        }
                        
                        Button
                        {
                            
                        }
                    label:
                        {
                            HStack
                            {
                                Image(systemName: "star.fill")
                                Text("\(status.favouritesCount)")
                            }
                        }
                        
                        Button
                        {
                            
                        }
                    label:
                        {
                            HStack
                            {
                                Image(systemName: "arrow.2.squarepath")
                                Text("\(status.reblogsCount)")
                            }
                        }
                        
                        let hoursstr = dateSinceNowToString(date: status.createdAt)
                        Text("\(hoursstr) · \(status.createdAt.formatted(date: .abbreviated, time: .omitted)) · \(status.createdAt.formatted(date: .omitted, time: .standard))").foregroundColor(.cyan)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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





extension String {
    func htmlAttributedString(
        fontSize: CGFloat = 16,
        color : Color = Color.white,
        linkColor : Color = Color.blue,
        fontFamily: String = "SF Pro"
    ) -> NSAttributedString? {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
                body {
                    color: #bbbbbb;
                    font-family: \(fontFamily);
                    font-size: \(fontSize)px;
                }
                a {
                    color: #005500;
                }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .unicode) else {
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


