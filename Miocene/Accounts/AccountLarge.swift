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
    @State var account : MastodonKit.Account
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    
    @State private var relationship : Relationship?
    @State private var accountStatuses = [MStatus]()
    
    static private var lastStatusesID = String()
    
    var body: some View
    {
        ScrollView
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
                            AsyncImage(url: URL(string:account.avatar ?? ""))
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
                            
                            
                            if let header = account.header
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
                            getRelationship(account:account)
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
                            
                            let url = account.url
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
                            // .frame(maxWidth: .infinity,maxHeight:.infinity)
                            .background(settings.theme.blockColor)
                            .cornerRadius(5)
                        }
                    }
                }
            }
            
            SpacerLine(color: settings.theme.minorColor)
            
            getStatuses(account: account)
        }
    }
    
    
    func getStatuses(account:Account) -> some View
    {
        if AccountLarge.lastStatusesID != account.id
        {
            AccountLarge.lastStatusesID = account.id
            appState.mastio()?.getStatusesForAccount(account:account)
            { mstatus in
                accountStatuses = mstatus
                
            }
        }
        
        return VStack
        {
            ForEach(accountStatuses)
            { mstatus in
                Post(mstat:mstatus)
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
    
    func getRelationship(account:Account) -> some View
    {
        if account.id != relationship?.id
        {
            let id : String = String(account.id)
            appState.mastio()?.getRelationships(ids: [id])
            { relationships in
                if relationships.count > 0
                {
                    relationship = relationships[0]
                }
            }
        }
        
        return HStack
        {
            if let mastaccount = appState.currentMastodonAccount()
            {
                if account.id == mastaccount.id
                {
                    PopButton(text: "Edit Profile", icon: "pencil",isSelected: false,help:"Edit Profile")
                    {
                        let myurl = mastaccount.url
                        NSWorkspace.shared.open(myurl)
                    }
                }
            }
            
            if relationship != nil
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
                                         truefunc: { appState.mastio()?.unfollow(account: account, done: { result in relationship = result }) },
                                         falsefunc: { appState.mastio()?.follow(account: account, done: { result in relationship = result }) })
                        }
                        
                        toggleButton(state: relationship!.muting, truelabel: "Muted", falselabel: "Not Muted",
                                     trueicon:"ear.trianglebadge.exclamationmark",falseicon:"ear.badge.checkmark",
                                     truefunc: { appState.mastio()?.unmute(account: account, done: { result in relationship = result }) },
                                     falsefunc: { appState.mastio()?.mute(account: account, done: { result in relationship = result }) })
                        
                        toggleButton(state: relationship!.blocking, truelabel: "Blocked", falselabel: "Not Blocked",
                                     trueicon:"hand.raised",falseicon:"hand.thumbsup",
                                     truefunc: { appState.mastio()?.unblock(account: account, done: { result in relationship = result }) },
                                     falsefunc: { appState.mastio()?.block(account: account, done: { result in relationship = result }) })
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
        return PopButtonColor(text: state == true ? truelabel : falselabel,
                              icon: state == true ? trueicon : falseicon,
                              textColor: settings.theme.minorColor,
                              iconColor: state == true ? settings.theme.accentColor : settings.theme.bodyColor,
                              isSelected: false,
                              help: "Toggle \(truelabel)/\(falselabel)"
                                )
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

