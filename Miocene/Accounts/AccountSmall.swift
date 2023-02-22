//
//  AccountSmall.swift
//  Miocene
//
//  Created by Robert Dodson on 12/29/22.
//

import SwiftUI
import MastodonKit


struct AccountSmall: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @State var account : MastodonKit.Account
    
    var body: some View
    {
        GroupBox
        {
            VStack(alignment: .leading)
            {
                HStack(alignment: .top)
                {
                    AsyncImage(url: URL(string: account.avatar ?? ""))
                    { image in
                        image.resizable()
                    }
                placeholder:
                    {
                        Image(systemName: "person.fill.questionmark")
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(5)
                    .onTapGesture
                    {
                        appState.showAccount(showaccount:account)
                    }
                    
                    VStack(alignment: .leading,spacing: 3)
                    {
                        Text(account.displayName)
                            .font(settings.font.headline)
                            .foregroundColor(settings.theme.nameColor)
                        
                        Text("@\(account.acct)")
                            .font(settings.font.subheadline)
                            .foregroundColor(settings.theme.minorColor)
                    }
                    .onTapGesture
                    {
                        appState.showAccount(showaccount:account)
                    }
                }
            }
        }
    }
}

