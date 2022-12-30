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
    @ObservedObject var settings: Settings
    
    var body: some View
    {
        VStack
        {
            VStack
            {
                HStack(alignment: .top)
                {
                    AsyncImage(url: URL(string: mast.useraccount.avatar))
                    { image in
                        image.resizable()
                    }
                placeholder:
                    {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
                    
                    AsyncImage(url: URL(string: mast.useraccount.header))
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
                
                Text("\(mast.useraccount.displayName)")
                Text("@\(mast.useraccount.acct)")
                Text("User since \(mast.useraccount.createdAt.formatted())")
                Text("\(mast.useraccount.note)")
                HStack
                {
                    VStack
                    {
                        Text("\(mast.useraccount.statusesCount)")
                        Text("Posts")
                    }
                    VStack
                    {
                        Text("\(mast.useraccount.followersCount)")
                        Text("Followers")
                    }
                    VStack
                    {
                        Text("\(mast.useraccount.followingCount)")
                        Text("Following")
                    }
                }
            }
            
            
            VStack
            {
                Text("ID \(mast.useraccount.id)")
                Text("Username \(mast.useraccount.username)")
                Text("\(mast.useraccount.url)")
                Text("\(mast.useraccount.locked.description)")
            }
        }
    }
}

