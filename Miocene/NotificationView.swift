//
//  NotificationView.swift
//  Miocene
//
//  Created by Robert Dodson on 1/9/2023.
//

import SwiftUI
import MastodonKit


struct NotificationView: View
{
    @ObservedObject var mast : Mastodon
    @ObservedObject var mnotification : MNotification
    
    @EnvironmentObject var settings: Settings
    
    var body: some View
    {
        let note = mnotification.notification
        
        GroupBox()
        {
            VStack
            {
                HStack
                {
                    HStack
                    {
                        switch note.type
                        {
                        case .favourite:
                            Text("Favorited by")
                        case .follow:
                            Text("Followed by")
                        case .mention:
                            Text("Mentioned by")
                        case .poll:
                            Text("Poll by")
                        case .reblog:
                            Text("Reblogged by")
                        case .other(let textstr):
                            Text("\(textstr)")
                        }
                    }
                    .font(settings.font.headline)
                    .foregroundColor(settings.theme.accentColor)
                    
                    AccountSmall(mast:mast,account: note.account)
                }
                
                if let status = mnotification.notification.status
                {
                    let mstatus = MStatus(status:status)
                    
                    Post(mast: mast, mstat: mstatus)
                }
            }
        }
        .contextMenu
        {
            Button { mast.deleteNotification(id:note.id) } label: { Text("Delete Notification") }
            Button { mast.deleteAllNotifications()} label: { Text("Delete All Notifications") }
        }
    }
}




