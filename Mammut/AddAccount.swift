//
//  NewPost.swift
//  Mammut
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit

struct AddAccount: View
{
    @ObservedObject var mast : Mastodon
    @EnvironmentObject var settings: Settings
    
    @State private var shouldPresentSheet = false
    
    @State private var server : String = ""
    @State private var userName : String = ""
    @State private var password : String = ""
    
    
    var body: some View
    {
        Button()
        {
            shouldPresentSheet.toggle()
        }
        label:
        {
            HStack
            {
                Image(systemName: "person.crop.circle")
                Text("Add Account")
            }
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
            print("Sheet dismissed!")
        }
        content:
        {
            VStack
            {
                Text("Add Account")
                    .foregroundColor(settings.theme.accentColor)
                    .font(.title)
                    .padding(.top)
                
                TextField("Mastodon Server", text: $server)
                    .padding()
                    .font(.title)
                
                TextField("User name or email", text: $userName)
                    .padding()
                    .font(.title)
                
                TextField("Password", text: $password)
                    .padding()
                    .font(.title)
                
                Text("Password is not kept, it's only used to aquire a token.")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
            .frame(width: 400, height: 300)
            .toolbar
            {
                    ToolbarItem
                    {
                        Button("Cancel")
                        {
                            shouldPresentSheet = false
                        }
                    }
                    
                    ToolbarItem
                    {
                        Button("Submit")
                        {
                            mast.newAccount(server: server, userName: userName, password: password)
                            
                            shouldPresentSheet = false
                        }
                    }
            }
        }
    }
}

