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
    
    @ObservedObject var mast : Mastodon
    @State var account : Account
    
    @State private var relationship : Relationship?
    
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
                            if relationship != nil
                            {
                                if relationship?.following == true
                                {
                                    Button("UnFollow")
                                    {
                                        mast.unfollow(account: account)
                                        getRelationship(account: account)
                                    }
                                }
                                else
                                {
                                    Button("Follow")
                                    {
                                        mast.follow(account: account)
                                        getRelationship(account: account)
                                    }
                                }
                        
                                Button("Block") {}
                                Button("Mute") {}
                            }
                            else
                            {
                                Button("Edit") {}
                            }
                        }
                        .onAppear()
                        {
                            if account.id != mast.currentlocalAccountRecord?.usersMastodonAccount?.id
                            {
                                getRelationship(account: account)
                            }
                        }
                    }
                }
                
            VStack(alignment: .leading,spacing: 2)
            {
                VStack(alignment:.leading)
                {
                    Text("\(account.displayName)")
                        .foregroundColor(settings.theme.nameColor)
                        .font(.title)
                    
                    Text("@\(account.acct)")
                        .foregroundColor(settings.theme.minorColor)
                        .font(.title)
                    
                    Text("User since \(account.createdAt.formatted())")
                        .foregroundColor(settings.theme.minorColor)
                        .font(.footnote).italic()
                }
                .padding()
                
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
                .padding()
                .font(.subheadline)
                .foregroundColor(settings.theme.minorColor)
                
                
                if let nsAttrString = account.note.htmlAttributedString(fontSize:16,color:settings.theme.bodyColor)
                {
                    Text(AttributedString(nsAttrString))
                }
                
                
                Link(account.url,destination: URL(string:account.url)!)
                    .foregroundColor(settings.theme.linkColor)
                    .font(.headline)
                }
            }
    }
    
    func getRelationship(account:Account)
    {
        mast.getRelationships(ids: [account.id])
        { relationships in
            relationship = relationships[0]
            for relationship in relationships
            {
                print("relationship: \(relationship)")
            }
        }
    }
}

