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
    
    @State var maccount : MAccount
    
    var body: some View
    {
        GroupBox
        {
            VStack(alignment: .leading)
            {
                HStack(alignment: .top)
                {
                    AsyncImage(url: URL(string: maccount.account.avatar ?? ""))
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
                        appState.showAccount(maccount:maccount)
                    }
                    
                    VStack(alignment: .leading,spacing: 3)
                    {
                        Text(maccount.displayName)
                            .font(settings.font.headline)
                            .foregroundColor(settings.theme.nameColor)
                        
                        Text("@\(maccount.account.acct)")
                            .font(settings.font.subheadline)
                            .foregroundColor(settings.theme.minorColor)
                    }
                    .onTapGesture
                    {
                        appState.showAccount(maccount:maccount)
                    }
                }
            }
        }
    }
}

