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
    @EnvironmentObject var alertSystem : AlertSystem
    @EnvironmentObject var appState : AppState
    
    @State private var server : String = "mastodon.social"
    @State private var password : String = ""
    @State private var useOAuth = true
    @State private var step = 0
    
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
        .errorAlert(error: $alertSystem.errorType,msg:alertSystem.errorMessage)
        {
            if alertSystem.errorType == .ok
            {
                appState.showHome()
                done()
            }
        }
        .onAppear()
        {
            step = 0
        }
        .frame(width: 400)
        .toolbar
        {
            ToolbarItem(placement: .automatic)
            {
                PopButton(text: "Cancel", icon: "trash.slash",isSelected: false,help: "Cancel")
                {
                    done()
                }
            }
            
            if step == 0
            {
                ToolbarItem(placement: .primaryAction)
                {
                    PopButton(text: "Next", icon: "arrow.forward",isSelected: true,help:"Next Step")
                    {
                        appState.addAccount(server: server)
                        { mioceneerror, msg in
                            step = 1
                            Log.logAlert(errorType: .accountError, msg: msg)
                        }
                    }
                }
            }
            else if step == 1
            {
                ToolbarItem(placement: .primaryAction)
                {
                    PopButton(text: "Complete", icon: "arrow.forward",isSelected: true,help:"Complete Account Setup")
                    {
                        step = 2
                        Log.logAlert(errorType: .ok,msg: "Account added")
                    }
                }
                
            }
                 
        }
        
    }
}
