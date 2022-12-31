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
        VStack
        {
            VStack
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
                                    print("search result: \(result)")
                                    results = try result.get().value
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                            }
                            catch
                            {
                                
                            }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
            }
            
            Rectangle().frame(width:500, height: 1).foregroundColor(.gray)
            
            ScrollView
            {
                if let res = results
                {
                        VStack(alignment: .leading)
                        {
                        
                            Text("Accounts \(res.accounts.count)")
                                .foregroundColor(.orange)
                                .font(.title)
                            
                            ForEach(res.accounts.indices, id:\.self)
                            { index in
                                AccountSmall(account: res.accounts[index])
                            }
                        }
                    
                   
                        VStack(alignment: .leading)
                        {
                            Text("Statuses \(res.statuses.count)")
                                .foregroundColor(.orange)
                                .font(.title)
                        }
                    
                    
                        VStack(alignment: .leading)
                        {
                            Text("Hashtags \(res.hashtags.count)")
                                .foregroundColor(.orange)
                                .font(.title)
                            
                            ForEach(res.hashtags.indices, id:\.self)
                            { index in
                                Link("\(res.hashtags[index].name)",destination: URL(string:res.hashtags[index].url)!)
                            }
                        }
                }
            }
            .frame(width:500)
            
        }
    }
}

