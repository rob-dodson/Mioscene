//
//  Mastodon.swift
//  Mammut
//
//  Created by Robert Dodson on 12/16/22.
//

import Foundation
import MastodonKit

enum TimeLine : String,CaseIterable, Identifiable,Equatable
{
    case home, localTimeline = "Local Timeline", publicTimeline = "Public Timeline", notifications = "Notifications"
    var id: Self { self }
}

@MainActor
class Mastodon : ObservableObject
{
    static let shared = Mastodon()
    
    var client : Client!
    var useraccount : Account!
    var currentTimeline : TimeLine = .home
    
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
                if let application = try? result.get().value
                {
                    print("id: \(application.id)")
                    print("redirect uri: \(application.redirectURI)")
                    print("client id: \(application.clientID)")
                    print("client secret: \(application.clientSecret)")
                }
        }
        
        client.run(Accounts.currentUser())
        { result in
            do
            {
                self.useraccount = try result.get().value
            }
            catch{
                
            }
        }
    }

    
    func getCurrentUserAccount() -> Account
    {
        return useraccount
    }
    
    
    func post(newpost:String)
    {
        let request = Statuses.create(status:newpost)
        client.run(request)
        { result in
            print("result \(result)")
        }
    }
    
    
    func search(query:String)
    {
        let request =  MastodonKit.Search.search(query:query,resolve:false)
        client.run(request)
        { result in
            
            switch result
            {
              case .success:
                print("search result: \(result)")
              case .failure(let error):
                  print(error.localizedDescription)
              }
        }
    }
    
    
    func getTimeline(timeline:TimeLine,done: @escaping ([MStatus]) -> Void)
    {
        currentTimeline = timeline
        
        var request : Request<[Status]>
        
        switch timeline
        {
        case .home:
            request = Timelines.home(range: .limit(50))
        case .localTimeline:
            request = Timelines.public(local:true,range: .limit(50))
        case .publicTimeline:
            request = Timelines.public(local:false,range: .limit(50))
        case .notifications:
            request = Timelines.tag("#help")
        }
        
        var returnstats = [MStatus]()
        
        client.run(request)
        { result in
            do
            {
                if let statuses = try? result.get().value
                {
                    for status in statuses
                    {
                        returnstats.append(convert(status: status))
                    }
                    done(returnstats)
                }
            }
            catch{
                
            }
        }
       
    }
}

struct MStatus : Identifiable
{
    var status  : Status
    var id = UUID()
}

func convert(status:Status) -> MStatus
{
    let newmstatus = MStatus(status: status)

    return newmstatus
}
