//
//  AddAccount.swift
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
    @EnvironmentObject var errorSystem : ErrorSystem
    @EnvironmentObject var appState : AppState


    @State private var shouldPresentSheet = false
    @State private var server : String = ""
    @State private var email : String = ""
    @State private var password : String = ""

    var body: some View
    {
        PopButton(text: "Add Account", icon: "person.badge.plus")
        {
            shouldPresentSheet = true
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
        }
        content:
        {
            VStack
            {
                Text("Add Account")
                    .foregroundColor(settings.theme.accentColor)
                    .font(settings.font.title)
                    .padding(.top)
                
                TextField("Mastodon Server", text: $server,prompt: Text("server name"))
                    .padding()
                    .font(settings.font.title)
                
                TextField("Email", text: $email,prompt: Text("email address"))
                    .padding()
                    .font(settings.font.title)
                
                SecureField("Password", text: $password)
                    .padding()
                    .font(settings.font.title)
                
                VStack(spacing:2)
                {
                    Text("If you need an account go to:")
                    Link("List of Mastodon Servers", destination: URL(string:"https://joinmastodon.org/servers")!)
                }
            }
            .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage,done:
            {
                if errorSystem.errorType == .ok
                {
                    shouldPresentSheet = false
                    appState.showHome()
                }
            })
            .frame(width: 400)
            .toolbar
            {
                ToolbarItem
                {
                    PopButton(text: "Cancel", icon: "trash.slash")
                    {
                        shouldPresentSheet = false
                    }
                }
                
                ToolbarItem
                {
                    PopButton(text: "Save", icon: "square.and.arrow.down")
                    {
                        mast.newAccount(server: server, email: email, password: password)
                        { mioceneerror,msg in
                            
                            Log.log(msg: msg)
                            errorSystem.reportError(type: mioceneerror,msg: msg)
                        }
                    }
                }
            }
        }
    }
}

