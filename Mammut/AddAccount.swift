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
                
                TextField("Email", text: $email)
                    .padding()
                    .font(.title)
                
                    SecureField("Password", text: $password)
                        .padding()
                        .font(.title)
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

