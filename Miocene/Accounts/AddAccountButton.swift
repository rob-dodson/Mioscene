//
//  AddAccountButton.swift
//  Miocene
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit


struct AddAccountButton: View
{
    @ObservedObject var mast : Mastodon
    
    @State private var shouldPresentSheet = false

    var body: some View
    {
        PopButton(text: "Add Account", icon: "person.badge.plus",isSelected: false)
        {
            shouldPresentSheet = true
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
        }
        content:
        {
            AddAccountPanel(mast: mast)
            {
                shouldPresentSheet = false
            }
        }
    }
}

