//
//  Search.swift
//  Mammut
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
                    .font(.title)
                
                Button("Search")
                {
                    results = nil
                    let request =  MastodonKit.Search.search(query:searchTerm,resolve:false)
                    mast.client.run(request)
                    { result in
                        
                        do
                        {
                            switch result
                            {
                            case .success:
                                results = try result.get().value
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                        catch
                        {
                            print("Error running search \(error)")
                        }
                    }
                }
                .padding([.bottom,.trailing])
                .keyboardShortcut(.defaultAction)
            }
            
            Rectangle().frame(height: 1).foregroundColor(.gray)
            
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
                            GroupBox(label: Label("Accounts", systemImage: "person.crop.circle")
                                .foregroundColor(settings.theme.accentColor)
                                .font(.title))
                            {
                                VStack(alignment: .leading)
                                {
                                    ForEach(res.accounts.indices, id:\.self)
                                    { index in
                                        AccountSmall(account: res.accounts[index])
                                    }
                                }
                            }
                        }
                        
                        //
                        // statuses
                        //
                        if res.statuses.count > 0
                        {/*
                            GroupBox(label: Label("Statuses", systemImage: "square.and.pencil")
                                .foregroundColor(settings.theme.accentColor)
                                .font(.title))
                            {
                                VStack(alignment: .leading)
                                {
                                    ForEach(res.statuses.indices, id:\.self)
                                    { index in
                                        let mstat = mast.convert(status:res.statuses[index])
                                        Post(mstat: mstat)
                                    }
                                }
                            }
                          */
                        }
                        
                        //
                        // hashtags
                        //
                        if res.hashtags.count > 0
                        {
                            GroupBox(label: Label("Hashtags", systemImage: "number")
                                .foregroundColor(settings.theme.accentColor)
                                .font(.title))
                            {
                                VStack(alignment: .leading)
                                {
                                    ForEach(res.hashtags.indices, id:\.self)
                                    { index in
                                        Link("#\(res.hashtags[index].name)",destination: URL(string:res.hashtags[index].url)!)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

