//
//  ContentView.swift
//  Mammut
//
//  Created by Robert Dodson on 12/16/22.
//

import SwiftUI
import MastodonKit


struct ContentView: View
{
    @ObservedObject var mast : Mastodon

    var mtoolbar = MToolBar()
    
    var body: some View
    {
        ZStack()
        {
            ScrollView()
            {
                ForEach(mast.getStats())
                { mstat in
                    Post(mstat: mstat)
                        .padding(.horizontal)
                        .padding(.top)
                }
            }
        }
        .toolbar
        {
            mtoolbar.mammutToolBar()
        }
        
    }
}

