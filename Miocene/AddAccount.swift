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
    @State private var server : String = "mastodon.social" // ""
    @State private var email : String = "robdod@gmail.com" // ""
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
                    .font(settings.font.title)
                    .padding(.top)
                
                TextField("Mastodon Server", text: $server)
                    .padding()
                    .font(settings.font.title)
                
                TextField("Email", text: $email)
                    .padding()
                    .font(settings.font.title)
                
                    SecureField("Password", text: $password)
                        .padding()
                        .font(settings.font.title)
            }
            .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage,done:
            {
                if errorSystem.errorType == .ok
                {
                    shouldPresentSheet = false
                    appState.showHome()
                }
            })
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

