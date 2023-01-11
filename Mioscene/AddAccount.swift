//
//  NewPost.swift
//  Miocene
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
    @State private var email : String = ""
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
            Log.log(msg:"Sheet dismissed!")
        }
        content:
        {
            VStack
            {
                Text("Add Account")
                    .foregroundColor(settings.theme.accentColor)
                    .font(settings.fonts.title)
                    .padding(.top)
                
                TextField("Mastodon Server", text: $server)
                    .padding()
                    .font(settings.fonts.title)
                
                TextField("Email", text: $email)
                    .padding()
                    .font(settings.fonts.title)
                
                    SecureField("Password", text: $password)
                        .padding()
                        .font(settings.fonts.title)
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
                        mast.newAccount(server: server, email: email, password: password)
                        shouldPresentSheet = false
                    }
                }
            }
        }
    }
}

