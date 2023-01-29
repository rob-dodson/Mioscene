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
    @ObservedObject var mast : Mastodon
    @ObservedObject var maccount : MAccount
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    
    @State private var relationship : Relationship?
    @State private var accountStatuses = [MStatus]()
    
    static private var lastStatusesID = String()
    
    var body: some View
    {
        GroupBox
        {
            VStack(alignment:.leading)
            {
                Grid
                {
                    GridRow
                    {
                        //
                        // User's avatar image
                        //
                        AsyncImage(url: URL(string:maccount.account.avatar ?? ""))
                        { image in
                            image.resizable()
                        }
                    placeholder:
                        {
                            Image(systemName: "person.fill.questionmark")
                        }
                        .offset(x:5,y:5)
                        .frame(width: 100, height: 100)
                        .cornerRadius(5)
                        
                        
                        if let header = maccount.account.header
                        {
                            if let url = URL(string: header)
                            {
                                AsyncImage(url: url)
                                { image in
                                    image.resizable()
                                     .aspectRatio(contentMode: .fit)
                                }
                            placeholder:
                                {
                                    
                                }
                                .frame(maxWidth: 300, maxHeight: 200)
                                .cornerRadius(5)
                            }
                            else
                            {
                                Rectangle().frame(width:300,height:200).foregroundColor(settings.theme.minorColor)
                            }
                        }
                    }
                    
                    GridRow
                    {
                        Spacer()
                        //
                        // Follow actions
                        //
                        getRelationship(maccount:maccount)
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
                            Text("\(maccount.account.displayName)")
                                .foregroundColor(settings.theme.nameColor)
                                .font(settings.font.headline)
                            
                            if maccount.account.bot == true
                            {
                                Text("[BOT]")
                                    .foregroundColor(settings.theme.accentColor)
                                    .font(settings.font.headline)
                            }
                        }
                        Text("@\(maccount.account.acct)")
                            .foregroundColor(settings.theme.minorColor)
                            .font(settings.font.subheadline)
                        
                        Text("User since \(maccount.account.createdAt.formatted())")
                            .foregroundColor(settings.theme.minorColor)
                            .font(.footnote).italic()
                        
                        if let url = maccount.account.url
                        {
                            let name = url.absoluteString.replacing(/http[s]*:\/\//, with:"")
                            Link(name,destination: url)
                                .foregroundColor(settings.theme.linkColor)
                                .font(.headline)
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
                        
                        //
                        // stats
                        //
                        HStack
                        {
                            VStack
                            {
                                Text("\(maccount.account.statusesCount)")
                                Text("Posts")
                            }
                            VStack
                            {
                                Text("\(maccount.account.followersCount)")
                                Text("Followers")
                            }
                            VStack
                            {
                                Text("\(maccount.account.followingCount)")
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
                            if let nsAttrString = maccount.account.note.htmlAttributedString(color:settings.theme.bodyColor,font:settings.font.body)
                            {
                                Text(AttributedString(nsAttrString))
                                    .textSelection(.enabled)
                                    .fixedSize(horizontal: false, vertical: true) // make the text wrap
                            }
                            
                            //
                            // fields
                            //
                            if let fields = maccount.account.fields
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
                       // .frame(maxWidth: .infinity,maxHeight:.infinity)
                        .background(settings.theme.blockColor)
                        .cornerRadius(5)
                    }
                }
            }
        }
            
        SpacerLine(color: settings.theme.minorColor)
        
        getStatuses(maccount: maccount)
    }
    
    
    func getStatuses(maccount:MAccount) -> some View
    {
        if AccountLarge.lastStatusesID != maccount.account.id
        {
            AccountLarge.lastStatusesID = maccount.account.id
            mast.getStatusesForAccount(account:maccount.account)
            { mstatus in
                accountStatuses = mstatus
                
            }
        }
        
        return ScrollView
        {
            ForEach(accountStatuses)
            { mstatus in
                Post(mast:mast,mstat:mstatus)
                    .padding([.horizontal,.top])
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
    
    func getRelationship(maccount:MAccount) -> some View
    {
        if maccount.account.id != relationship?.id
        {
            let id : String = String(maccount.account.id)
            mast.getRelationships(ids: [id])
            { relationships in
                relationship = relationships[0]
            }
        }
        
        return HStack
        {
            if maccount.account.id == appState.currentUserMastAccount?.id
            {
                PopButton(text: "Edit Profile", icon: "pencil")
                {
                    if let myurl = mast.getCurrentMastodonAccount()?.url
                    {
                        NSWorkspace.shared.open(myurl)
                    }
                }
                
            }
            else if relationship != nil
            {
                VStack
                {
                    HStack(alignment: .bottom)
                    {
                        if relationship?.requested == true
                        {
                            VStack
                            {
                                Text("Follow")
                                    .font(settings.font.footnote) // Need to add: withdraw request button
                                Text("Requested")
                                    .font(settings.font.footnote)
                            }
                        }
                        else
                        {
                            toggleButton(state: relationship!.following, truelabel: "Following", falselabel: "Not Following",
                                         trueicon:"person.line.dotted.person.fill",falseicon:"person.2.slash",
                                         truefunc: { mast.unfollow(account: maccount.account, done: { result in relationship = result }) },
                                         falsefunc: { mast.follow(account: maccount.account, done: { result in relationship = result }) })
                        }
                        
                        toggleButton(state: relationship!.muting, truelabel: "Muted", falselabel: "Not Muted",
                                     trueicon:"ear.trianglebadge.exclamationmark",falseicon:"ear.badge.checkmark",
                                     truefunc: { mast.unmute(account: maccount.account, done: { result in relationship = result }) },
                                     falsefunc: { mast.mute(account: maccount.account, done: { result in relationship = result }) })
                        
                        toggleButton(state: relationship!.blocking, truelabel: "Blocked", falselabel: "Not Blocked",
                                     trueicon:"hand.raised",falseicon:"hand.thumbsup",
                                     truefunc: { mast.unblock(account: maccount.account, done: { result in relationship = result }) },
                                     falsefunc: { mast.block(account: maccount.account, done: { result in relationship = result }) })
                    }
                    .padding(EdgeInsets(top: 2, leading: 0, bottom: 1, trailing: 0))
                    
                    Text(relationship?.followedBy == true ? "Is following you" : "Is not following you")
                        .foregroundColor(settings.theme.minorColor).italic()
                }
            }
        }
    }
    
    
    func toggleButton(state:Bool,truelabel:String,falselabel:String,trueicon:String,falseicon:String,truefunc: @escaping () -> Void,falsefunc:@escaping () -> Void) -> some View
    {
        return PopButton(text: state == true ? truelabel : falselabel,
                         icon: state == true ? trueicon : falseicon)
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

