//
//  Mastodon.swift
//  Mammut
//
//  Created by Robert Dodson on 12/16/22.
//

import Foundation
import MastodonKit

@MainActor
class Mastodon : ObservableObject
{
    static let shared = Mastodon()
    
    var client : Client!
    var useraccount : Account!
    
    @Published var stats = [MStatus]()
    
    init()
    {
        
        client = Client(
            baseURL: "https://mastodon.social",
            accessToken: "aEC-QUgClG1fJD0vJw3yrqFDduBwU2iI_1PM0tcfjbA"
        )
        
        let request = Clients.register(
            clientName: "Mammute Client",
            scopes: [.read, .write, .follow],
            website: "https://shyfrogproductions.com"
        )

        client.run(request)
        { result in
            if let application = result.value
            {
                print("id: \(application.id)")
                print("redirect uri: \(application.redirectURI)")
                print("client id: \(application.clientID)")
                print("client secret: \(application.clientSecret)")
            }
        }
        
        client.run(Accounts.currentUser())
        { result in
            self.useraccount = result.value
        }
        
        getTimeline()
    }
    
    func getCurrentUserAccount() -> Account
    {
        return useraccount
    }
    
    func getStats() -> [MStatus]
    {
            return stats
    }
    
    func getTimeline()
    {
        var returnstats = [MStatus]()
        let request = Timelines.home(range: .limit(50))
        
        client.run(request)
        { result in
            if let statuses = result.value
            {
                for status in statuses
                {
                    returnstats.append(convert(status: status))
                   // print(status.account.displayName)
                }
                DispatchQueue.main.async {
                    self.stats = returnstats
                }
            }
        }
    }
}

struct MStatus : Identifiable
{
    var status  : Status
   /* var account : Account
    var content : String
    var date    : Date*/
    
    var id = UUID()
}

func convert(status:Status) -> MStatus
{
   // let newmstatus = mstatus(account: status.account,content: status.content,date:status.createdAt)
    let newmstatus = MStatus(status: status)

    return newmstatus
}
