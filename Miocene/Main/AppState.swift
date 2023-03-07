//
//  AppState.swift
//  Miocene
//
//  Created by Robert Dodson on 1/21/23.
//

import Foundation
import MastodonKit


enum TabIndex : Int
{
    case TimeLine = 0
    case Accounts
    case Search
    case Settings
}


class AppState : ObservableObject
{
    private var currentAccountKey : AccountKey = AccountKey(server: "noserver", username: "nouser")
    private var showAccount : MastodonKit.Account?
    
    @Published var tabIndex : TabIndex = .TimeLine
    @Published var userLoggedIn : Bool = false
    @Published var showTag : String = ""
    @Published var selectedTimeline : TimeLine = .home
    @Published var currentTimelineName : String = TimeLine.home.rawValue
    
    static var localAccountRecords = Dictionary<AccountKey,LocalAccountRecord>()
    static var mastIOs = Dictionary<AccountKey,MastodonIO>()
    static var userMastAccounts = Dictionary<AccountKey,MastodonKit.Account>()
    
    
    init()
    {
        Log.log(msg:"Starting up...",rewindfile:true)
        loadAccounts()
    }
    
    
    func setAccount(accountKey:AccountKey)
    {
        currentAccountKey = accountKey
    }
    
    
    func mastio() -> MastodonIO?
    {
        return AppState.mastIOs[currentAccountKey]
    }
    
    
    func currentLocalAccountRecord() -> LocalAccountRecord?
    {
        return AppState.localAccountRecords[currentAccountKey]
    }
    
    
    func currentMastodonAccount() -> Account?
    {
        return AppState.userMastAccounts[currentAccountKey]
    }
    
    
    func showTag(showtag:String)
    {
        showTag = showtag
        tabIndex = .TimeLine
        selectedTimeline = .tag
        currentTimelineName = selectedTimeline.rawValue
    }
    
    func showHome()
    {
        tabIndex = .TimeLine
    }
    
    func showAccount(showaccount:MastodonKit.Account)
    {
        showAccount = showaccount
        tabIndex = .Accounts
    }
    
    
    func getShowAccount() -> MastodonKit.Account?
    {
        return showAccount
    }
    
    
    func loadAccounts()
    {
        do
        {
            Log.log(msg:"Loading accounts")
            
            let sql = SqliteDB()
            let localAccountRecords = try sql.loadAccounts()
            
            if localAccountRecords.count > 0
            {
                for localrec in localAccountRecords
                {
                    Log.log(msg: "Loading account: \(localrec.desc())")
                    AppState.localAccountRecords[localrec.accountKey()] = localrec
                    AppState.mastIOs[localrec.accountKey()] = MastodonIO()
                    
                    connectMastIOForAccount(localrec: localrec)
                    
                    if localrec.lastViewed == true
                    {
                        self.userLoggedIn = true
                        self.setAccount(accountKey: localrec.accountKey())
                        currentAccountKey = localrec.accountKey()
                    }
                }
            }
        }
        catch
        {
            Log.logAlert(errorType:.sqlError,msg:"sql error \(error)")
        }
    }

    
    func connectMastIOForAccount(localrec:LocalAccountRecord)
    {
        guard let token = Keys.getFromKeychain(name: localrec.makeKeyChainName()) else
        {
            Log.logAlert(errorType: .loginError,msg: "Failed to get a keychain token for \(localrec.desc())")
            return
        }
        
        guard let mastio = AppState.mastIOs[localrec.accountKey()] else
        {
            Log.logAlert(errorType: .loginError,msg: "Failed to get mastio for \(localrec.desc())")
            return
        }
        
        mastio.connect(serverurl: localrec.server, token: token)
        { result in
            
            if let account = result.value
            {
                AppState.userMastAccounts[localrec.accountKey()] = account
                
                Log.log(msg: "Account \(account.username) is connected to \(localrec.server)!")
            }
            else if let error = result.error
            {
                Log.logAlert(errorType: .loginError,msg: "error from mastio.connect: \(error)")
            }
        }
    }
    
    
    func addAccount(server:String,done:@escaping (MioceneError,String) -> Void)
    {
        let mastio = MastodonIO()
        
        mastio.newAccountOAuth(server: server)
        { mioceneerror,msg_or_token in
            
            if mioceneerror != .ok
            {
                done(mioceneerror,msg_or_token)
            }
            else
            {
                mastio.connect(serverurl: server, token:msg_or_token)
                { result in
                    
                    if let account = result.value
                    {
                        do
                        {
                            let sql = SqliteDB()
                            
                            let localaccount = LocalAccountRecord(username: account.username, email:"", server: server, lastViewed: true)
                            
                            try sql.updateAccount(account: localaccount)
                           
                            AppState.mastIOs[localaccount.accountKey()] = mastio
                            Keys.storeInKeychain(name: localaccount.makeKeyChainName(), value: msg_or_token)
                            
                            self.setAccount(accountKey: localaccount.accountKey())
                            AppState.userMastAccounts[localaccount.accountKey()] = account
                            
                            done(.ok,"Account stored in db, logged in OK")
                        }
                        catch
                        {
                            done(.sqlError,"Sql error storing account: \(error)")
                        }
                    }
                    else if let error = result.error
                    {
                        done(.accountError,"error getting account: \(error)")
                    }
                }
            }
        }
    }
}
