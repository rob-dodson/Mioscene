//
//  AccountView.swift
//  Mammut
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI

struct AccountView: View
{
    @ObservedObject var mast : Mastodon
    @EnvironmentObject var settings: Settings
    
    var body: some View
    {
        ZStack
        {
            if let account = mast.currentlocalAccountRecord?.usersMastodonAccount
            {
                VStack
                {
                    VStack
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
                            
                            AsyncImage(url: URL(string: account.header))
                            { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth:300)
                            }
                        placeholder:
                            {
                                Image(systemName: "person.fill.questionmark")
                            }
                        }
                        
                        Text("\(account.displayName)")
                        Text("@\(account.acct)")
                        Text("User since \(account.createdAt.formatted())")
                        Text("\(account.note)")
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
                    }
                    
                    
                    VStack
                    {
                        Text("ID \(account.id)")
                        Text("Username \(account.username)")
                        Text("\(account.url)")
                        Text("\(account.locked.description)")
                    }
                }
            }
        }
        .toolbar
        {
            ToolbarItem
            {
                AddAccount(mast: mast)
            }
        }
    }
}

