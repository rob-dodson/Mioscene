//
//  AccountLarge.swift
//  Mammut
//
//  Created by Robert Dodson on 1/4/23.
//

import SwiftUI
import MastodonKit


struct AccountLarge: View
{
    @EnvironmentObject var settings: Settings
    @State var account : Account
    
    var body: some View
    {

        VStack(alignment:.leading)
        {
                HStack(alignment: .top)
                {
                    AsyncImage(url: URL(string:account.avatar))
                    { image in
                        image.resizable()
                    }
                placeholder:
                    {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
                    
                    VStack
                    {
                        AsyncImage(url: URL(string: account.header))
                        { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                            //.frame(maxWidth:300)
                        }
                    placeholder:
                        {
                            Image(systemName: "person.fill.questionmark")
                        }
                        .cornerRadius(15)
                        
                        HStack
                        {
                            Button("Follow") {}
                            Button("Block") {}
                            Button("Mute") {}
                            Button("Edit") {}
                        }
                    }
                }
                
            VStack(alignment: .leading,spacing: 2)
            {
                Text("\(account.displayName)")
                    .foregroundColor(settings.theme.nameColor)
                    .font(.title)
                
                Text("@\(account.acct)")
                    .foregroundColor(settings.theme.minorColor)
                    .font(.title)
                
                if let nsAttrString = account.note.htmlAttributedString(fontSize:16,color:settings.theme.bodyColor)
                {
                    Text(AttributedString(nsAttrString))
                }
                
                Text("User since \(account.createdAt.formatted())")
                    .foregroundColor(settings.theme.minorColor)
                    .font(.footnote).italic()
                
                    HStack
                    {
                        VStack
                        {
                            Text("\(account.statusesCount)")
                            Text("Posts")
                        }
                        VStack
                        {
                            Text("\(account.followersCount)")
                            Text("Followers")
                        }
                        VStack
                        {
                            Text("\(account.followingCount)")
                            Text("Following")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(settings.theme.minorColor)
                
                    Link(account.url,destination: URL(string:account.url)!)
                        .foregroundColor(settings.theme.linkColor)
                     .font(.headline)
                }
            }
    }
}

