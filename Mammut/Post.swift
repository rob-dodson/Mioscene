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
    var mstat : mstatus
    
    
    var body: some View
    {
        let status = mstat.status
        
        if status.reblog != nil
        {
            dopost(status: status.reblog!,reblogged: true)
        }
        else
        {
            dopost(status: status,reblogged: false)
        }
    }

    func dopost(status:Status,reblogged:Bool) -> some View
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
                            
                    if reblogged == true
                    {
                        HStack
                        {
                            Image(systemName: "arrow.2.squarepath")
                            Text("Reblogged by \(status.account.displayName)").foregroundColor(.orange)
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
                        
                        Text(status.createdAt.formatted()).foregroundColor(.cyan)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
           }
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


