//
//  AccountView.swift
//  Miocene
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI
import MastodonKit

struct AccountView: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @State private var currentAccountServer = "server"
    
    var body: some View
    {
        VStack
        {
            HStack(alignment: .bottom, spacing: settings.hideIconText == true ? 80 : 40)
            {
                if let account = appState.currentLocalAccountRecord()
                {
                    PopMenu(icon: "person.crop.circle",selected:$currentAccountServer ,
                            menuItems: [PopMenuItem(text: "@\(account.username)",help:"Select Account @\(account.username)",userData: account),
                                       ])
                    { item in
                    }
                }
                
                PopButton(text:"My Account", icon:"person",isSelected: false,help:"Show My Account")
                {
                    if let account = appState.currentMastodonAccount()
                    {
                        appState.showAccount(showaccount: account)
                    }
                }

                AddAccountButton()
                
            }
            
            SpacerLine(color: settings.theme.minorColor)
            if let account = appState.getShowAccount()
            {
                AccountLarge(account: account)
            }
            else if let account = appState.currentMastodonAccount()
            {
                AccountLarge(account: account)
            }
        }
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
        .textSelection(.enabled)
    }
}


