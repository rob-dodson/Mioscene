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
    
    @State private var searchTerm : String = ""
    @State private var results : Results?
    
    
    var body: some View
    {
        VStack(alignment: .leading)
        {
            VStack(alignment: .trailing)
            {
                TextField("Search", text: $searchTerm)
                    .padding()
                    .font(settings.font.title)
                
                Button("Search")
                {
                    results = nil
                    let request =  MastodonKit.Search.search(query:searchTerm,resolve:false)
                    mast.client.run(request)
                    { result in
                        
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
                    AccountSmall(account: accounts[index])
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
                    Button
                    {
                        
                    } label:
                    {
                        Text("#\(hashtags[index].name)")
                        Text(hashtags[index].url.path)
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

