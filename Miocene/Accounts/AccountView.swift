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
    @ObservedObject var mast : Mastodon
    @ObservedObject var maccount : MAccount
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    
    var body: some View
    {
        VStack
        {
            HStack(alignment: .bottom, spacing: settings.hideIconText == true ? 80 : 40)
            {
                if let accounts = mast.localAccountRecords
                {
                    PopMenu(icon: "person.crop.circle",
                            menuItems: [PopMenuItem(text: "@\(accounts[0].username)",userData: accounts[0]),
                                       ])
                    { item in
                    }
                }
                
                PopButton(text:"My Account", icon:"person")
                {
                    appState.showAccount(maccount: MAccount(displayname: appState.currentUserMastAccount!.displayName, acct: appState.currentUserMastAccount!))
                }

                
                AddAccount(mast: mast)
                
            }
            
            SpacerLine(color: settings.theme.minorColor)
            
            AccountLarge(mast:mast,maccount: appState.currentViewingMastAccount!)
        }
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
        .textSelection(.enabled)
    }
}


