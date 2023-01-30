//
//  Mastodon.swift
//  Miocene
//
//  Created by Robert Dodson on 12/16/22.
//
// This is the interface between the app UI and MastodonKit
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
    case home = "Home",
         localTimeline = "Local Timeline",
         publicTimeline = "Public Timeline",
         tag = "Tag",
         favorites = "Favorites",
         notifications = "All Notifications",
         mentions = "Mentions Only"
    
    var id: Self { self }
}


@MainActor
class Mastodon : ObservableObject
{
    static let accessTokenKeyNamePrefix = "Miocene.mastodon.access.token"
    
    var client : Client!
    var currentTimeline : TimeLine = .home
    var sql : SqliteDB
    var localAccountRecords : [LocalAccountRecord]?
    private var appState = AppState.shared
    private var requestSize = 10
    
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
                        appState.currentlocalAccountRecord = localrec
                        
                        let token = Keys.getFromKeychain(name: appState.currentlocalAccountRecord!.makeKeyChainName())
                        if let token
                        {
                            connect(serverurl: localrec.server, token: token, done:
                            { result in
                                
                                if let account = result.value
                                {
                                    DispatchQueue.main.async {
                                        
                                        self.appState.currentUserMastAccount = account
                                        self.appState.currentViewingMastAccount = MAccount(displayname: account.displayName, acct: account)
                                        self.appState.currentlocalAccountRecord = localrec
                                        
                                        Log.log(msg: "Account \(account.username) is logged in!")
                                    }
                                }
                                else if let error = result.error
                                {
                                    Log.log(msg: "error getting account \(error)")
                                }
                            })
                        }
                        else
                        {
                            Log.log(msg: "Error getting token from Keychain")
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
    
    func connect(serverurl:String,token:String,done:@escaping (Result<Account>) -> Void)
    {
        client =  Client(baseURL: "https://\(serverurl)",accessToken: token)
        
        let request = Clients.register(
            clientName: "Miocene",
            scopes: [.read, .write,.follow],
            website: "https://shyfrogproductions.com"
        )

        client.run(request)
        { result in
            if let application = result.value
            {
                Log.log(msg:"id: \(application.id)")
                Log.log(msg:"redirect uri: \(application.redirectURI)")
                Log.log(msg:"client id: \(application.clientID)")
                Log.log(msg:"client secret: \(application.clientSecret)")
            }
        }
        
        client.run(Accounts.currentUser())
        { result in
            done(result)
        }
    }
   
    
    func getCurrentMastodonAccount() -> Account?
    {
        return appState.currentlocalAccountRecord?.usersMastodonAccount ?? nil
    }

    
    func newAccount(server:String,email:String,password:String,done:@escaping (MioceneError,String) -> Void)
    {
        let serverurl = "https://\(server)"
        let newClient = Client(baseURL: serverurl)
        
        let request = Clients.register(
            clientName: "Miocene",
            scopes: [.read, .write,.follow],
            website: "https://shyfrogproductions.com"
        )
        
        var clientid = ""
        var clientsecret = ""
        
        newClient.run(request)
        { result in
            if let application = result.value
            {
                clientid = application.clientID
                clientsecret = application.clientSecret
                
                let loginrequest = Login.silent(clientID: clientid, clientSecret: clientsecret, scopes: [.read, .write,.follow], username: email, password: password)
                
                newClient.run(loginrequest)
                { result in
                    
                    if let loginsettings = result.value
                    {
                            let localaccount = LocalAccountRecord(username: email, email:email, server: server, lastViewed: true)
                            
                            Keys.storeInKeychain(name: localaccount.makeKeyChainName(), value: loginsettings.accessToken)
                            
                            self.connect(serverurl: server, token: loginsettings.accessToken, done:
                            { result in
                                
                                if let account = result.value
                                {
                                    localaccount.username = account.username
                                    self.appState.currentUserMastAccount = account
                                    self.appState.currentViewingMastAccount = MAccount(displayname: account.displayName, acct: account)
                                    do
                                    {
                                        try self.sql.updateAccount(account: localaccount)
                                        done(.ok,"Account logged in OK")
                                    }
                                    catch
                                    {
                                        done(.sqlError,"Sql error storing account \(error)")
                                    }
                                }
                                else if let error = result.error
                                {
                                    done(.accountError,"error getting account \(error)")
                                }
                            })
                    }
                    else
                    {
                        done(.loginError,"failed to get login credentials \(result)")
                    }
                }
            }
            else
            {
                done(.registrationError,"registration error \(result)")
            }
        }
    }
   
    func getStatusesForAccount(account:Account,done: @escaping ([MStatus]) -> Void)
    {
        var returnstats = [MStatus]()
        
        let request = Accounts.statuses(id: account.id)
        client.run(request)
        { result in
            if let statuses = result.value
            {
                for status in statuses
                {
                    returnstats.append(self.convert(status: status))
                }
                done(returnstats)
            }
        }
    }
    
    
    func getRelationships(ids:[String],done: @escaping ([Relationship]) -> Void)
    {
        let request = Accounts.relationships(ids: ids)
        
        client.run(request)
        { result in
            Log.log(msg:"getRelationships result \(result)")
            if let relationships = result.value
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
            if let relationship = result.value
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
            if let relationship =  result.value
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
            if let relationship = result.value
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
            if let relationship = result.value
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
            if let relationship = result.value
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
            if let relationship = result.value
            {
                done(relationship)
            }
        }
    }
    
    func voteOnPoll(poll:Poll,choices:IndexSet,done: @escaping (Poll) -> Void)
    {
        let request = Polls.vote(pollID: poll.id, optionIndices: choices)
        
        client.run(request)
        { result in
            switch result
            {
            case .success(let poll, _):
                Log.log(msg:"success voting \(result)")
                done(poll)
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
    
    
    
    func post(newpost:String,spoiler:String?,visibility:Visibility,attachedURLS:[AttachmentURL],pollpayload:PollPayload?,done: @escaping (Result<Status>) -> Void)
    {
        if attachedURLS.count > 0
        {
            Task
            {
                let waitcounttotal = attachedURLS.count
                var waitcount = 0
                var retrywait = 0
                let maxwait = 10
                
                var mediaIDs = [String]()
                
                for index in attachedURLS.indices
                {
                    do
                    {
                        if let url = attachedURLS[index].url
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
                                
                                if let attachment = result.value
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
                    done(result)
                }
            }
        }
        else
        {
            let request = Statuses.create(status: newpost,spoilerText: spoiler,
                                          poll:pollpayload,
                                      visibility: visibility)
            client.run(request)
            { result in
                Log.log(msg:"post result \(result)")
                done(result)
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
    
    func deletePost(id:String)
    {
        let request = MastodonKit.Statuses.delete(id: id)
        client.run(request)
        { result in
            Log.log(msg:"deletePost result \(result)")
        }
    }
    
    func getNotifications(mentionsOnly:Bool,done: @escaping ([MNotification]) -> Void)
    {
        let request = Notifications.all()
        
        client.run(request)
        { result in
            
            if let notifications = result.value
            {
                var returnnotes = [MNotification]()
                for note in notifications
                {
                    if (mentionsOnly == true && note.type == .mention) || mentionsOnly == false
                    {
                        returnnotes.append(self.convert(notification: note))
                    }
                }
                done(returnnotes)
            }
            else if let error = result.error
            {
                Log.log(msg:"error getting notifications \(error)")
                done([MNotification]())
            }
        }
    }
    
    func makeRequest(timeline:TimeLine,range:RequestRange,tag:String) -> Request<[Status]>
    {
        switch timeline
        {
            case .home:
                return Timelines.home(range:range)
            case .publicTimeline:
                return Timelines.public(local: false,range:range)
            case .localTimeline:
                return Timelines.public(local: true,range:range)
            case .tag:
                return Timelines.tag(tag)
            case .favorites:
                return Favourites.all(range:range)
            case .notifications:
                return Timelines.public(local: false,range:range)
            case .mentions:
                return Timelines.public(local: true,range:range)
        }
    }
    
    func getSomeStatuses(timeline:TimeLine,tag:String,done: @escaping ([MStatus]) -> Void)
    {
        let request = makeRequest(timeline: timeline,range: .limit(requestSize),tag:tag)
        
        getTimeline(request: request)
        { statuses, pagination in
            done(statuses)
        }
    }
    
    func getOlderStatuses(timeline:TimeLine,id:String,tag:String,done: @escaping ([MStatus]) -> Void)
    {
        let request = makeRequest(timeline: timeline,range:.max(id: id, limit: requestSize),tag:tag)
        
        getTimeline(request: request)
        { statuses, pagination in
            done(statuses)
        }
    }
    
    
    func getNewerStatuses(timeline:TimeLine,id:String,tag:String,done: @escaping ([MStatus]) -> Void)
    {
        let request = makeRequest(timeline: timeline,range:.min(id: id, limit: requestSize),tag:tag)
        
        getTimeline(request: request)
        { statuses, pagination in
            done(statuses)
        }
    }
    
    
    func getTimeline(request: Request<[Status]>,done: @escaping ([MStatus],Pagination?) -> Void)
    {
        client.run(request)
        { result in
            
            var returnstats = [MStatus]()

            switch result
            {
                case .success(let statuses,let pagination):
                    
                    returnstats = statuses.map(
                    { status in
                        self.convert(status: status)
                    })
                    
                    done(returnstats,pagination)
                    
                case .failure(let error):
                    Log.log(msg:"error getting statuses \(error)")
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
