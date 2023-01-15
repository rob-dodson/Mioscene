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
    
    @State var error : MioceneError?
    
    
    var body: some View
    {
        VStack
        {
            HStack
            {
                Picker(selection: .constant(1),label: Text("Account"),content:
                        {
                    Text("@rdodson").tag(1)
                    Text("@FrogradioHQ").tag(2)
                })
                
                AddAccount(mast: mast)
            }
            .padding()
            
            SpacerLine(color: settings.theme.minorColor)
            
            if let account = settings.seeAccount
            {
                AccountLarge(mast:mast,account: account)
            }
            else if let account = mast.currentlocalAccountRecord?.usersMastodonAccount
            {
                AccountLarge(mast:mast,account: account)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .textSelection(.enabled)

    }
}


