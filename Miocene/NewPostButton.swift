//
//  NewPost.swift
//  Miocene
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit



struct NewPostButton: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings: Settings
    
    @State private var shouldPresentSheet = false

    
    var body: some View
    {
        Button()
        {
            shouldPresentSheet.toggle()
        }
        label:
        {
            Image(systemName: "square.and.pencil")
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
            Log.log(msg:"Sheet dismissed!")
        }
        content:
        {
            EditPost(mast: mast,newPost:"",title: "New Post",done:
            {
                shouldPresentSheet = false
            })
        }
    }
    
}
