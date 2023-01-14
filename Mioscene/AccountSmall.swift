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
    
    @State var account : Account
    
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
                    .cornerRadius(15)
                    .onTapGesture
                    {
                        settings.showAccount(account:account)
                    }
                    
                    VStack(alignment: .leading,spacing: 3)
                    {
                        Text(account.displayName)
                            .font(settings.fonts.title)
                            .foregroundColor(settings.theme.nameColor)
                        
                        Text("@\(account.acct)")
                            .font(.title3)
                            .foregroundColor(settings.theme.minorColor)
                    }
                    .onTapGesture
                    {
                        settings.showAccount(account:account)
                    }
                }
                
                HStack(alignment: .top)
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
                .foregroundColor(settings.theme.minorColor)
                .font(.footnote)
            }
        }
    }
}

