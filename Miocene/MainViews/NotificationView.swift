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
                if let status = mnotification.notification.status
                {
                    let mstatus = MStatus(status:status)
                    
                    Post(mast: mast, mstat: mstatus,notification: note)
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




