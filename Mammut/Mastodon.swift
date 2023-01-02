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
    static let accessTokenKeyName = "Mammut.mastodon.access.token"
    static let accessURLKeyName = "Mammut.mastodon.baseurl"
    
    var client : Client!
    var useraccount : Account!
    var currentTimeline : TimeLine = .home
   
    
    init()
    {
        connect()
    }
    
    func connect()
    {
        let token = Keys.getFromKeychain(name: Mastodon.accessTokenKeyName)
        let baseurl = Keys.getFromKeychain(name: Mastodon.accessURLKeyName)
        
        guard token != nil && baseurl != nil else
        {
                print("no token or url")
                return
        }
        
        client = Client(baseURL: baseurl!,accessToken: token)
        
        let request = Clients.register(
            clientName: "Mammut",
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
            catch
            {
                print("Error getting user account \(error)")
            }
        }
    }

    
    func newAccount(server:String,userEmail:String,password:String)
    {
        let serverurl = "https://\(server)"
        let newClient = Client(baseURL: serverurl)
        
        let request = Clients.register(
            clientName: "Mammut",
            scopes: [.read, .write, .follow],  // follow depricated? .push?
            website: "https://shyfrogproductions.com"
        )
        
        var clientid = ""
        var clientsecret = ""
        
        newClient.run(request)
        { result in
            if let application = try? result.get().value
            {
                clientid = application.clientID
                clientsecret = application.clientSecret
                
                let loginrequest = Login.silent(clientID: clientid, clientSecret: clientsecret, scopes: [.read, .write, .follow], username: userEmail, password: password)
                
                newClient.run(loginrequest)
                { result in
                    if let loginsettings = try? result.get().value
                    {
                        Keys.storeInKeychain(name: Mastodon.accessTokenKeyName, value: loginsettings.accessToken)
                        Keys.storeInKeychain(name: Mastodon.accessURLKeyName, value: serverurl)
                    }
                }
            }
            else
            {
                print("result error \(result)")
            }
        }
    }
        
    
    func getCurrentUserAccount() -> Account
    {
        return useraccount
    }
    
    
    func unfavorite(status:Status)
    {
        let request = Statuses.unfavourite(id: status.id)
        client.run(request)
        { result in
            print("unfavorite result \(result)")
        }
    }
    
    
    func favorite(status:Status)
    {
        let request = Statuses.favourite(id: status.id)
        client.run(request)
        { result in
            print("favorite result \(result)")
        }
    }
    
    
    func reblog(status:Status)
    {
        let request = Statuses.reblog(id: status.id)
        client.run(request)
        { result in
            print("reblog result \(result)")
        }
    }
    
    
    func unreblog(status:Status)
    {
        let request = Statuses.unreblog(id: status.id)
        client.run(request)
        { result in
            print("unreblog result \(result)")
        }
    }
    
    
    func post(newpost:String)
    {
        let request = Statuses.create(status:newpost)
        client.run(request)
        { result in
            print("result \(result)")
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
                if let statuses = try? result.get().value
                {
                    for status in statuses
                    {
                        returnstats.append(self.convert(status: status))
                    }
                    done(returnstats)
                }
        }
       
    }
    
    func convert(status:Status) -> MStatus
    {
        let newmstatus = MStatus(status: status)

        return newmstatus
    }

}

class MStatus : Identifiable,ObservableObject
{
    var status : Status
    @Published var favorited : Bool = false
    @Published var favoritesCount : Int = 0
    @Published var reblogged : Bool = false
    @Published var reblogsCount: Int = 0

    init(status:Status)
    {
        self.status = status
        self.favorited = status.favourited ?? false
        self.favoritesCount = status.favouritesCount
        self.reblogged = status.reblogged ?? false
        self.reblogsCount = status.reblogsCount
    }
    
    var id = UUID()
}

