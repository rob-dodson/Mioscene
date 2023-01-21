//
//  AccountView.swift
//  Miocene
//
//  Created by Robert Dodson on 12/28/22.
//

import SwiftUI


struct AccountView: View
{
    @ObservedObject var mast : Mastodon
    
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
                
                AddAccount(mast: mast)
            }
            .padding()
            
            SpacerLine(color: settings.theme.minorColor)
            
            if let account = appState.currentUserMastAccount
            {
                AccountLarge(mast:mast,account: account)
            }
            else if let account = appState.currentlocalAccountRecord?.usersMastodonAccount
            {
                AccountLarge(mast:mast,account: account)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .textSelection(.enabled)

    }
}


