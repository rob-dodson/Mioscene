//
//  AccountSmall.swift
//  Miocene
//
//  Created by Robert Dodson on 12/29/22.
//

import SwiftUI
import MastodonKit


struct AccountSmall: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @State var account : MastodonKit.Account
    @State var showDetails : Bool
    @State var superSmall : Bool = false
    
    var body: some View
    {
        GroupBox
        {
            VStack(alignment: .leading)
            {
                HStack(alignment: .top)
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
                    .cornerRadius(5)
                    .onTapGesture
                    {
                        appState.showAccount(showaccount:account)
                    }
                    
                    VStack(alignment: .leading,spacing: 3)
                    {
                        Text(account.displayName)
                            .font(settings.font.headline)
                            .foregroundColor(settings.theme.nameColor)
                        
                        Text("@\(account.acct)")
                            .font(settings.font.subheadline)
                            .foregroundColor(settings.theme.minorColor)
                        
                        if showDetails == true
                        {
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
                            }
                        }
                        
                        if superSmall == false
                        {
                            if let fields = account.fields
                            {
                                if fields.count > 0
                                {
                                    ForEach(fields.indices, id:\.self)
                                    { index in
                                        
                                        if fields[index].verification != nil
                                        {
                                            HStack
                                            {
                                                Text("\(fields[index].name):")
                                                    .foregroundColor(settings.theme.minorColor)
                                                    .font(settings.font.subheadline)
                                                
                                                if let nsAttrString = fields[index].value.htmlAttributedString(color:settings.theme.bodyColor,font:settings.font.title)
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
                            }
                        }
                    }
                    .onTapGesture
                    {
                        appState.showAccount(showaccount:account)
                    }
                }
            }
        }
    }
}

