//
//  Search.swift
//  Miocene
//
//  Created by Robert Dodson on 12/26/22.
//

import SwiftUI
import MastodonKit


struct SearchView: View
{
    @ObservedObject var mast : Mastodon
    
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var appState: AppState
    
    @State private var searchTerm : String = ""
    @State private var results : Results?
    @State private var showLoading = false
    
    var body: some View
    {
        VStack(alignment: .center)
        {
            VStack(alignment: .trailing)
            {
                TextField("Search", text: $searchTerm)
                    .padding()
                    .font(settings.font.title)
                
                Button("Search")
                {
                    showLoading = true
                    results = nil
                    let request =  MastodonKit.Search.search(query:searchTerm,resolve:false)
                    mast.client.run(request)
                    { result in
                            showLoading = false
                            switch result
                            {
                            case .success:
                                results = result.value
                            case .failure(let error):
                                Log.log(msg:error.localizedDescription)
                            }
                    }
                }
                .padding([.bottom,.trailing])
                .keyboardShortcut(.defaultAction)
            }
            
            SpacerLine(color: settings.theme.minorColor)
            
            if showLoading
            {
                
                ProgressView("Loading...")
                    .foregroundColor(settings.theme.accentColor)
            }
            
            ScrollView
            {
                if let res = results
                {
                    VStack(alignment: .leading)
                    {
                        //
                        // accounts
                        //
                        if res.accounts.count > 0
                        {
                            accountview(accounts: res.accounts)
                        }
                        
                        //
                        // statuses
                        //
                        if res.statuses.count > 0
                        {
                            statusview(statuses:res.statuses)
                        }
                        
                        //
                        // hashtags
                        //
                        if res.hashtags.count > 0
                        {
                            hashview(hashtags: res.hashtags)
                        }
                    }
                }
            }
        }
    }
    
    func accountview(accounts:[Account]) -> some View
    {
        return GroupBox(label: Label("Accounts", systemImage: "person.crop.circle")
            .foregroundColor(settings.theme.accentColor)
            .font(settings.font.title))
        {
            VStack(alignment: .leading)
            {
                ForEach(accounts.indices, id:\.self)
                { index in
                    AccountSmall(mast:mast,account: accounts[index])
                }
            }
        }
    }
    
    
    func hashview(hashtags:[Tag]) -> some View
    {
        GroupBox(label: Label("Hashtags", systemImage: "number")
            .foregroundColor(settings.theme.accentColor)
            .font(settings.font.title))
        {
            VStack(alignment: .leading)
            {
                ForEach(hashtags.indices, id:\.self)
                { index in
                    
                    Text("#\(hashtags[index].name)")
                        .font(settings.font.body)
                        .foregroundColor(settings.theme.bodyColor)
                        .onTapGesture
                        {
                            appState.showTag(tag: "#\(hashtags[index].name)")
                        }
                }
            }
        }
    }
    
    
    func statusview(statuses:[Status]) -> some View
    {
        return GroupBox(label: Label("Statuses", systemImage: "square.and.pencil")
            .foregroundColor(settings.theme.accentColor)
            .font(settings.font.title))
        {
            VStack(alignment: .leading)
            {
                ForEach(statuses.indices, id:\.self)
                { index in
                    let mstat = mast.convert(status:statuses[index])
                    Post(mast: mast, mstat: mstat)
                }
            }
        }
    }
}

