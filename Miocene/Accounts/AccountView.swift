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
    @ObservedObject var maccount : MAccount
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    
    var body: some View
    {
        VStack
        {
            HStack(alignment: .bottom, spacing: settings.hideIconText == true ? 80 : 40)
            {
                if let account = appState.currentlocalAccountRecord
                {
                    PopMenu(icon: "person.crop.circle",selected: "",
                            menuItems: [PopMenuItem(text: "@\(account.username)",userData: account),
                                       ])
                    { item in
                    }
                }
                
                PopButton(text:"My Account", icon:"person",isSelected: false)
                {
                    appState.showAccount(maccount: MAccount(displayname: appState.currentUserMastAccount!.displayName, acct: appState.currentUserMastAccount!))
                }

                AddAccountButton()
                
            }
            
            SpacerLine(color: settings.theme.minorColor)
            
            AccountLarge(maccount: appState.currentViewingMastAccount!)
        }
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
        .textSelection(.enabled)
    }
}


