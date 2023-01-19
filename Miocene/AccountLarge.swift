//
//  AccountLarge.swift
//  Miocene
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
    @State private var accountStatuses = [MStatus]()

    
    var body: some View
    {
        GroupBox
        {
            VStack(alignment:.leading)
            {
                HStack(alignment: .top)
                {
                    //
                    // User's avatar image
                    //
                    AsyncImage(url: URL(string:account.avatar ?? ""))
                    { image in
                        image.resizable()
                    }
                placeholder:
                    {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
                    
                    
                    //
                    // background header image
                    //
                    VStack
                    {
                        if let header = account.header
                        {
                            AsyncImage(url: URL(string: header))
                            { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth:300)
                            }
                        placeholder:
                            {
                                Image(systemName: "person.fill.questionmark")
                            }
                            .cornerRadius(15)
                        }
                        else
                        {
                            Image(systemName: "photo.fill").imageScale(.large)
                        }
                        
                        //
                        // Follow actions
                        //
                        HStack
                        {
                            if relationship != nil
                            {
                                if relationship?.requested == true
                                {
                                    Text("Follow Requested") // Need to add: withdraw request button
                                }
                                else
                                {
                                    toggleButton(state: relationship!.following, truelabel: "Unfollow", falselabel: "Follow",
                                                 truefunc: { mast.unfollow(account: account, done: { result in relationship = result }) },
                                                 falsefunc: { mast.follow(account: account, done: { result in relationship = result }) })
                                }
                                
                                toggleButton(state: relationship!.muting, truelabel: "Unmute", falselabel: "Mute",
                                             truefunc: { mast.unmute(account: account, done: { result in relationship = result }) },
                                             falsefunc: { mast.mute(account: account, done: { result in relationship = result }) })
                                
                                toggleButton(state: relationship!.blocking, truelabel: "Unblock", falselabel: "Block",
                                             truefunc: { mast.unblock(account: account, done: { result in relationship = result }) },
                                             falsefunc: { mast.block(account: account, done: { result in relationship = result }) })
                            }
                        }
                        .onAppear()
                        {
                            if account.id != mast.currentlocalAccountRecord?.usersMastodonAccount?.id
                            {
                                getRelationship(account: account)
                            }
                        }
                        
                        Text(relationship?.followedBy == true ? "Is following you" : "Is not following you")
                            .foregroundColor(settings.theme.minorColor).italic()
                    }
                }
                
                VStack(alignment: .leading,spacing: 2)
                {
                    VStack(alignment:.leading)
                    {
                        //
                        // Names
                        //
                        HStack
                        {
                            Text("\(account.displayName)")
                                .foregroundColor(settings.theme.nameColor)
                                .font(settings.font.headline)
                            
                            if account.bot == true
                            {
                                Text("[BOT]")
                                    .foregroundColor(settings.theme.accentColor)
                                    .font(settings.font.headline)
                            }
                        }
                        Text("@\(account.acct)")
                            .foregroundColor(settings.theme.minorColor)
                            .font(settings.font.subheadline)
                        
                        Text("User since \(account.createdAt.formatted())")
                            .foregroundColor(settings.theme.minorColor)
                            .font(.footnote).italic()
                        
                        if let url = account.url
                        {
                            let name = url.absoluteString.replacing(/http[s]*:\/\//, with:"")
                            Link(name,destination: url)
                                .foregroundColor(settings.theme.linkColor)
                                .font(.headline)
                        }
                        
                        //
                        // stats
                        //
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
                        .font(settings.font.body)
                        .foregroundColor(settings.theme.minorColor)
                        
                        
                        //
                        // note
                        //
                        VStack(alignment: .leading)
                        {
                            if let nsAttrString = account.note.htmlAttributedString(color:settings.theme.bodyColor,font:settings.font.body)
                            {
                                Text(AttributedString(nsAttrString))
                                    .textSelection(.enabled)
                                    .fixedSize(horizontal: false, vertical: true) // make the text wrap

                            }
                            
                            //
                            // fields
                            //
                            if let fields = account.fields
                            {
                                if fields.count > 0
                                {
                                    fieldsView(fields:fields)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(settings.theme.blockColor)
                                }
                            }
                        }
                        .padding()
                        
                        .frame(maxWidth: .infinity,maxHeight:.infinity)
                        .background(settings.theme.blockColor)
                        .cornerRadius(5)
                        

                    }
                }
            }
        }
            
        SpacerLine(color: settings.theme.minorColor)
        
        ScrollView
        {
            ForEach(accountStatuses)
            { mstatus in
                Post(mast:mast,mstat:mstatus)
                    .padding([.horizontal,.top])
            }
        }
        .task
        {
            Task
            {
                mast.getStatusesForAccount(account: account)
                { mstatus in
                    accountStatuses = mstatus
                }
            }
        }
    }
    
    func fieldsView(fields:[VerifiableMetadataField]) -> some View
    {
        VStack(alignment: .leading)
        {
            ForEach(fields.indices, id:\.self)
            { index in
                HStack
                {
                    Text("\(fields[index].name):")
                        .foregroundColor(settings.theme.minorColor)
                        .font(settings.font.subheadline)
                    
                    if let nsAttrString = fields[index].value.htmlAttributedString(color:settings.theme.bodyColor,font:settings.font.body)
                    {
                        Text(AttributedString(nsAttrString))
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true) // make the text wrap

                        
                        if fields[index].verification != nil
                        {
                            Image(systemName: "checkmark").foregroundColor(.green)
                        }
                    }
                    else
                    {
                        Text(fields[index].value)
                    }
                }
            }
        }
    }
    
    func getRelationship(account:Account)
    {
        mast.getRelationships(ids: [account.id])
        { relationships in
            relationship = relationships[0]
        }
    }
    
    
    func toggleButton(state:Bool,truelabel:String,falselabel:String,truefunc: @escaping () -> Void,falsefunc:@escaping () -> Void) -> some View
    {
        return Button(state == true ? truelabel : falselabel)
        {
            if state == true
            {
                truefunc()
            }
            else
            {
                falsefunc()
            }
        }
    }
}

