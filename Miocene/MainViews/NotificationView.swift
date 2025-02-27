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
    @ObservedObject var mnotification : MNotification
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    var body: some View
    {
        let note = mnotification.notification
        
        VStack
        {
            if let status = mnotification.notification.status
            {
                Post(mstat: MStatus(status:status),notification: note)
            }
        }
        .contextMenu
        {
            Button { appState.mastio()?.deleteNotification(id:note.id) } label: { Text("Delete Notification") }
            Button { appState.mastio()?.deleteAllNotifications()} label: { Text("Delete All Notifications") }
        }
    }
}




