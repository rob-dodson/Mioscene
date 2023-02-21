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
    @Published var currentlocalAccountRecord : LocalAccountRecord?
    @Published var currentUserMastAccount : MastodonKit.Account?
    @Published var currentViewingMastAccount : MAccount?
    @Published var tabIndex : TabIndex = .TimeLine
    @Published var userLoggedIn : Bool = false
    
    static var localAccountRecords = Dictionary<LocalAccountRecord.AccountKey,LocalAccountRecord>()
    static var mastIOs = Dictionary<LocalAccountRecord.AccountKey,MastodonIO>()
    
    init()
    {
        Log.log(msg:"Starting up...",rewindfile:true)
        loadAccounts()
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
                }
            }
        }
        catch
        {
            Log.log(msg:"sql error \(error)")
        }
    }

    
    func connectMastIOForAccount(localrec:LocalAccountRecord)
    {
        guard let token = Keys.getFromKeychain(name: localrec.makeKeyChainName()) else { Log.log(msg: "Failed to get a keychain token for \(localrec.desc())"); return }
        guard let mastio = AppState.mastIOs[localrec.accountKey()] else { Log.log(msg: "Failed to get mastio for \(localrec.desc())"); return}
        
        mastio.connect(serverurl: localrec.server, token: token)
        { result in
            
            if let account = result.value
            {
                DispatchQueue.main.async
                {
                    self.userLoggedIn = true
                    self.currentlocalAccountRecord = localrec
                    self.currentUserMastAccount = account
                    self.currentViewingMastAccount = MAccount(displayname: account.displayName, acct: account)
                    
                    Log.log(msg: "Account \(account.username) is connected to \(localrec.server)!")
                }
            }
            else if let error = result.error
            {
                Log.log(msg: "error from mastio.connect: \(error)")
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
                            
                            self.currentUserMastAccount = account
                            self.currentViewingMastAccount = MAccount(displayname: account.displayName, acct: account)
                            
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
    
    func getCurrentMastodonAccount() -> Account?
    {
        return currentlocalAccountRecord?.usersMastodonAccount ?? nil
    }
    
    
    func mastio() -> MastodonIO?
    {
        if let localrec = currentlocalAccountRecord
        {
            if let mastio = AppState.mastIOs[localrec.accountKey()]
            {
                return mastio
            }
        }
        
        return nil
    }
    
    func showTag(tag:String)
    {
        tabIndex = .TimeLine
    }
    
    func showHome()
    {
        tabIndex = .TimeLine
    }
    
    func showAccount(maccount:MAccount)
    {
        currentViewingMastAccount = maccount
        tabIndex = .Accounts
    }
}
