//
//  AccountSmall.swift
//  Mammut
//
//  Created by Robert Dodson on 12/29/22.
//

import SwiftUI
import MastodonKit


struct AccountSmall: View
{
    @EnvironmentObject var settings: Settings
    @State var account : Account
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            HStack(alignment: .top)
            {
                AsyncImage(url: URL(string: account.avatar))
                { image in
                    image.resizable()
                }
            placeholder:
                {
                    Image(systemName: "person.fill.questionmark")
                }
                .frame(width: 50, height: 50)
                .cornerRadius(15)
                
                VStack(alignment: .leading,spacing: 3)
                {
                    Text(account.displayName)
                        .font(.title)
                        .foregroundColor(settings.theme.nameColor)
                    
                    let name = "@\(account.acct)"
                    Link(name,destination: URL(string:account.url)!)
                        .font(.title3)
                }
            }
        }
    }
}

