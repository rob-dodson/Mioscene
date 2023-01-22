//
//  MNotification.swift
//  Miocene
//
//  Created by Robert Dodson on 1/22/23.
//

import Foundation
import MastodonKit

class MNotification : Identifiable,ObservableObject
{
    var notification : MastodonKit.Notification
    
    init(notification:MastodonKit.Notification)
    {
        self.notification = notification
    }
    var id = UUID()
}
