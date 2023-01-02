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
    static let accessTokenKeyNamePrefix = "Mammut.mastodon.access.token"
    
    var client : Client!
    var currentTimeline : TimeLine = .home
    var sql : SqliteDB
    var currentlocalAccountRecord : LocalAccountRecord?
    var localAccountRecords : [LocalAccountRecord]?
    
    
    init()
    {
        do
        {
            sql = SqliteDB()
            localAccountRecords = try sql.loadAccounts()
            
            if localAccountRecords != nil
            {
                for localrec in localAccountRecords!
                {
                    if localrec.lastViewed == true
                    {
                        currentlocalAccountRecord = localrec
                        
                        let token = Keys.getFromKeychain(name: currentlocalAccountRecord!.makeKeyChainName())
                        if let token
                        {
                            connect(localaccount:localrec,serverurl: currentlocalAccountRecord!.server, token: token)
                        }
                    }
                }
            }
        }
        catch
        {
            print("sql error \(error)")
        }
    }
    
    func connect(localaccount:LocalAccountRecord,serverurl:String,token:String)
    {
        client = Client(baseURL: "https://\(serverurl)",accessToken: token)
        
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
                localaccount.usersMastodonAccount = try result.get().value
            }
            catch
            {
                print("Error getting user account \(error)")
            }
        }
    }
    
    func getCurrentMastodonAccount() -> Account?
    {
        return currentlocalAccountRecord?.usersMastodonAccount ?? nil
    }

    
    func newAccount(server:String,userName:String,password:String)
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
                
                let loginrequest = Login.silent(clientID: clientid, clientSecret: clientsecret, scopes: [.read, .write, .follow], username: userName, password: password)
                
                newClient.run(loginrequest)
                { result in
                    if let loginsettings = try? result.get().value
                    {
                        do
                        {
                            let localaccount = LocalAccountRecord(username: userName, server: server, lastViewed: true)
                            try self.sql.updateAccount(account: localaccount)
                            Keys.storeInKeychain(name: localaccount.makeKeyChainName(), value: loginsettings.accessToken)
                        }
                        catch
                        {
                            print("error saving account \(error)")
                        }
                    }
                    else
                    {
                        print("failed to get login credentials \(result)")
                    }
                }
            }
            else
            {
                print("result error \(result)")
            }
        }
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

