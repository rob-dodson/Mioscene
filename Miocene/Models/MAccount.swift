//
//  MAccount.swift
//  Miocene
//
//  Created by Robert Dodson on 1/22/23.
//

import Foundation
import MastodonKit

class MAccount : ObservableObject
{
    @Published var displayName : String
    var account : MastodonKit.Account
    
    init(displayname:String,acct:MastodonKit.Account)
    {
        displayName = displayname
        account = acct
    }
}
