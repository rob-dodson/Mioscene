//
//  Mastodon.swift
//  Miocene
//
//  Created by Robert Dodson on 12/16/22.
//

import Foundation
import MastodonKit



struct AttachmentURL : Identifiable
{
    var url : URL?
    let id = UUID()
}


enum TimeLine : String,CaseIterable, Identifiable,Equatable
{
    case home,
         localTimeline = "Local Timeline",
         publicTimeline = "Public Timeline",
         tag = "Tag",
         favorites = "Favorites",
         notifications = "Notifications"
    
    var id: Self { self }
}


@MainActor
class Mastodon : ObservableObject
{
    static let accessTokenKeyNamePrefix = "Miocene.mastodon.access.token"
    
    var client : Client!
    var currentTimeline : TimeLine = .home
    var sql : SqliteDB
    var currentlocalAccountRecord : LocalAccountRecord?
    var localAccountRecords : [LocalAccountRecord]?
    
    
    init()
    {
        do
        {
            Log.log(msg:"Starting up",rewindfile:true)
            
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
            Log.log(msg:"sql error \(error)")
        }
    }
    
    func connect(localaccount:LocalAccountRecord,serverurl:String,token:String)
    {
        client = Client(baseURL: "https://\(serverurl)",accessToken: token)
        
        let request = Clients.register(
            clientName: "Mioscene",
            scopes: [.read, .write, .follow],
            website: "https://shyfrogproductions.com"
        )

        client.run(request)
        { result in
                if let application = try? result.get().value
                {
                    Log.log(msg:"id: \(application.id)")
                    Log.log(msg:"redirect uri: \(application.redirectURI)")
                    Log.log(msg:"client id: \(application.clientID)")
                    Log.log(msg:"client secret: \(application.clientSecret)")
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
                Log.log(msg:"Error getting user account \(error)")
            }
        }
    }
    
    func getCurrentMastodonAccount() -> Account?
    {
        return currentlocalAccountRecord?.usersMastodonAccount ?? nil
    }

    
    func newAccount(server:String,email:String,password:String)
    {
        let serverurl = "https://\(server)"
        let newClient = Client(baseURL: serverurl)
        
        let request = Clients.register(
            clientName: "Mioscene",
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
                
                let loginrequest = Login.silent(clientID: clientid, clientSecret: clientsecret, scopes: [.read, .write, .follow], username: email, password: password)
                
                newClient.run(loginrequest)
                { result in
                    if let loginsettings = try? result.get().value
                    {
                        do
                        {
                            let localaccount = LocalAccountRecord(username: email, email:email, server: server, lastViewed: true)
                            try self.sql.updateAccount(account: localaccount)
                            Keys.storeInKeychain(name: localaccount.makeKeyChainName(), value: loginsettings.accessToken)
                            Log.log(msg:"Account created OK")
                        }
                        catch
                        {
                            Log.log(msg:"error saving account \(error)")
                        }
                    }
                    else
                    {
                        Log.log(msg:"failed to get login credentials \(result)")
                    }
                }
            }
            else
            {
                Log.log(msg:"result error \(result)")
            }
        }
    }
   
    
    func getRelationships(ids:[String],done: @escaping ([Relationship]) -> Void)
    {
        let request = Accounts.relationships(ids: ids)
        client.run(request)
        { result in
            Log.log(msg:"getRelationships result \(result)")
            if let relationships = try? result.get().value
            {
                done(relationships)
            }
            else
            {
                done([Relationship]())
            }
        }
    }
    
    
    func follow(account:Account,done: @escaping (Relationship) -> Void)
    {
        let request = Accounts.follow(id: account.id)
        client.run(request)
        { result in
            Log.log(msg:"follow result \(result)")
            if let relationship = try? result.get().value
            {
                done(relationship)
            }
        }
    }
    
    func unfollow(account:Account,done: @escaping (Relationship) -> Void)
    {
        let request = Accounts.unfollow(id: account.id)
        client.run(request)
        { result in
            Log.log(msg:"unfollow result \(result)")
            if let relationship = try? result.get().value
            {
                done(relationship)
            }
        }
    }
    
    
    func mute(account:Account,done: @escaping (Relationship) -> Void)
    {
        let request = Accounts.mute(id: account.id)
        client.run(request)
        { result in
            Log.log(msg:"mute result \(result)")
            if let relationship = try? result.get().value
            {
                done(relationship)
            }
        }
    }
    
    func unmute(account:Account,done: @escaping (Relationship) -> Void)
    {
        let request = Accounts.unmute(id: account.id)
        client.run(request)
        { result in
            Log.log(msg:"unmute result \(result)")
            if let relationship = try? result.get().value
            {
                done(relationship)
            }
        }
    }
    
    
    func block(account:Account,done: @escaping (Relationship) -> Void)
    {
        let request = Accounts.block(id: account.id)
        client.run(request)
        { result in
            Log.log(msg:"block result \(result)")
            if let relationship = try? result.get().value
            {
                done(relationship)
            }
        }
    }
    
    func unblock(account:Account,done: @escaping (Relationship) -> Void)
    {
        let request = Accounts.unblock(id: account.id)
        client.run(request)
        { result in
            Log.log(msg:"unblock result \(result)")
            if let relationship = try? result.get().value
            {
                done(relationship)
            }
        }
    }
    
    func voteOnPoll(poll:Poll,choices:[Int],done: @escaping (Poll) -> Void)
    {
        let request = Polls.vote(id: poll.id, choices: choices)
        
        client.run(request)
        { result in
            switch result
            {
            case .success(let response):
                done(response.value)
            case .failure(let error):
                Log.log(msg:"error in vote on poll \(error)")
            }
        }
    }
    
    func unfavorite(status:Status)
    {
        let request = Statuses.unfavourite(id: status.id)
        client.run(request)
        { result in
            Log.log(msg:"unfavorite result \(result)")
        }
    }
    
    
    func favorite(status:Status)
    {
        let request = Statuses.favourite(id: status.id)
        client.run(request)
        { result in
            Log.log(msg:"favorite result \(result)")
        }
    }
    
    
    func reblog(status:Status)
    {
        let request = Statuses.reblog(id: status.id)
        client.run(request)
        { result in
            Log.log(msg:"reblog result \(result)")
        }
    }
    
    
    func unreblog(status:Status)
    {
        let request = Statuses.unreblog(id: status.id)
        client.run(request)
        { result in
            Log.log(msg:"unreblog result \(result)")
        }
    }
    
    
    func post(newpost:String,spoiler:String?,visibility:Visibility,attachedURLS:[AttachmentURL]?)
    {
        if let urls = attachedURLS
        {
            Task
            {
                let waitcounttotal = urls.count
                var waitcount = 0
                var retrywait = 0
                let maxwait = 10
                
                var mediaIDs = [String]()
                
                for index in urls.indices
                {
                    do
                    {
                        if let url = urls[index].url
                        {
                            let imageData = try Data(contentsOf: url)
                            let imgFormat = imageData.imageFormat
                            
                            let media : MediaAttachment
                            switch imgFormat
                            {
                            case .gif:
                                media = MediaAttachment.gif(imageData)
                            case .jpeg:
                                media = MediaAttachment.jpeg(imageData)
                            case .png:
                                media = MediaAttachment.png(imageData)
                            default:
                                Log.log(msg:"unsupported media type")
                                continue
                            }
                            
                            let mediarequest = Media.upload(media: media)
                            client.run(mediarequest)
                            { result in
                                Log.log(msg:"media upload result \(result)")
                                
                                if let attachment = try? result.get().value
                                {
                                    mediaIDs.append(attachment.id)
                                    waitcount += 1
                                }
                            }
                        }
                    }
                    catch
                    {
                        Log.log(msg:"bad image url \(error)")
                    }
                }
                
                while waitcount < waitcounttotal || retrywait > maxwait
                {
                    try await Task.sleep(for: .seconds(3))
                    retrywait += 1
                }
                
                let request = Statuses.create(status:newpost,mediaIDs:mediaIDs,spoilerText:spoiler,visibility: visibility)
                client.run(request)
                { result in
                    Log.log(msg:"post with media result \(result)")
                }
            }
        }
        else
        {
            let request = Statuses.create(status:newpost,spoilerText:spoiler,visibility: visibility)
            client.run(request)
            { result in
                Log.log(msg:"post result \(result)")
            }
        }
    }
    
    func deleteNotification(id:String)
    {
        let request = MastodonKit.Notifications.dismiss(id: id)
        client.run(request)
        { result in
            Log.log(msg:"deleteNotification result \(result)")
        }
    }
    
    func deleteAllNotifications()
    {
        let request = MastodonKit.Notifications.dismissAll()
        client.run(request)
        { result in
            Log.log(msg:"deleteAllNotifications result \(result)")
        }
        
    }
    
    func getNotifications(done: @escaping ([MastodonKit.Notification]) -> Void)
    {
        let request  = MastodonKit.Notifications.all()
        
        var returnnotes = [MastodonKit.Notification]()
        
        client.run(request)
        { result in
                if let notes = try? result.get().value
                {
                    for note in notes
                    {
                        returnnotes.append(note)
                    }
                    done(returnnotes)
                }
        }
    }
    
    
    func getNotifications(done: @escaping ([MNotification]) -> Void)
    {
        var returnnotes = [MNotification]()
        
        let request = Notifications.all()
        client.run(request)
        { result in
            if let notifications = try? result.get().value
            {
                for note in notifications
                {
                    returnnotes.append(self.convert(notification: note))
                }
                done(returnnotes)
            }
            else
            {
                Log.log(msg:"error getting notifications \(result)")
            }
        }
    }
    
    func getTimeline(timeline:TimeLine,tag:String,done: @escaping ([MStatus]) -> Void)
    {
        if client == nil
        {
            return
        }
        
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
        case .favorites:
            request = Favourites.all()
        case .tag:
            request = Timelines.tag(tag)
        case .notifications:
            Log.log(msg:"timeline error")
            return
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
            else
            {
                Log.log(msg:"error getting statuses \(result)")
            }
        }
       
    }
    
    func convert(status:Status) -> MStatus
    {
        let newmstatus = MStatus(status: status)

        return newmstatus
    }

    func convert(notification:MastodonKit.Notification) -> MNotification
    {
        let newnote = MNotification(notification: notification)

        return newnote
    }
}

class MNotification : Identifiable,ObservableObject
{
    var notification : MastodonKit.Notification
    
    init(notification:MastodonKit.Notification)
    {
        self.notification = notification
    }
    var id = UUID()
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

