//
//  AddAccountPanel.swift
//  Miocene
//
//  Created by Robert Dodson on 2/15/23.
//

import SwiftUI
import MastodonKit

struct AddAccountPanel: View
{
    var done : () -> Void
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var errorSystem : ErrorSystem
    @EnvironmentObject var appState : AppState
    
    @State private var server : String = "shyfrog.masto.host"
    @State private var password : String = ""
    @State private var useOAuth = true
    
    var body: some View
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
            
            if useOAuth == false
            {
                SecureField("Password", text: $password)
                    .padding()
                    .font(settings.font.title)
            }
            
            VStack(spacing:2)
            {
                Text("If you need an account go to:")
                Link(destination: URL(string:"https://joinmastodon.org/servers")!)
                {
                    
                    Image("MastodonSymbol")
                        .foregroundColor(settings.theme.accentColor)
                        .font(.largeTitle)
                    Text("List of Mastodon Servers")
                }
                .symbolRenderingMode(.multicolor)
            }
        }
        .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage)
        {
            if errorSystem.errorType == .ok
            {
                appState.showHome()
                done()
            }
        }
        .frame(width: 400)
        .toolbar
        {
            ToolbarItem
            {
                PopButton(text: "Cancel", icon: "trash.slash",isSelected: false)
                {
                    done()
                }
            }
            
            
            ToolbarItem
            {
                PopButton(text: "Save", icon: "square.and.arrow.down",isSelected: false)
                {
                    appState.addAccount(server: server)
                    { mioceneerror, msg in
                        Log.log(msg: msg)
                        errorSystem.reportError(type: mioceneerror,msg: msg)
                    }
                }
            }
        }
    }
}
