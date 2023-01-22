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
                HStack
                {
                    Picker(selection: .constant(1),label: Text("Accounts"),content:
                            {
                        if let accounts = mast.localAccountRecords
                        {
                            ForEach(accounts.indices, id:\.self)
                            { index in
                                Text("@\(accounts[index].username)").tag(1)
                            }
                        }
                    })
                    
                    Button("My Account")
                    {
                        appState.showAccount(maccount: MAccount(displayname: appState.currentUserMastAccount!.displayName, acct: appState.currentUserMastAccount!))
                    }

                    
                    AddAccount(mast: mast)
                    
                }
                .padding()
                
                SpacerLine(color: settings.theme.minorColor)
                
                AccountLarge(mast:mast,maccount: appState.currentViewingMastAccount!)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding()
            .textSelection(.enabled)

    }
}


