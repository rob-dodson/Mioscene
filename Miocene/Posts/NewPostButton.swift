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
    @EnvironmentObject var settings: Settings
    
    @State private var shouldPresentSheet = false

    
    var body: some View
    {
        HStack
        {
            PopButton(text: "New Post", icon: "square.and.pencil",isSelected: false,help: "New Post")
            {
                shouldPresentSheet.toggle()
            }
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
        }
        content:
        {
            EditPost(newPost:"",postVisibility: .public, done:
            {
                shouldPresentSheet = false
            })
        }
    }
}

