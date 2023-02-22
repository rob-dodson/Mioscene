//
//  LocalAccountRecord.swift
//  Miocene
//
//  Created by Robert Dodson on 1/2/23.
//

import Foundation

import MastodonKit
import GRDB


//
// used to key dictionaries of mastio and accounts
//
struct AccountKey : Hashable
{
    var server : String
    var username : String
}


//
// this record stored locally in an sqlite db, via GRDB.
// it contains basic info to connect to a mastodon server.
//
class LocalAccountRecord : Record,Codable,Identifiable
{
    static let accessTokenKeyNamePrefix = "Miocene.mastodon.access.token"
    
    var username : String
    var email : String
    var server : String
    var lastViewed : Bool
    var uuid : UUID
    
    var usersMastodonAccount : Account?
    
    
    enum CodingKeys: String,CodingKey
    {
        case uuid
        case username
        case email
        case server
        case lastViewed
    }
    
    
    init(uuid: UUID = UUID(), username: String, email:String, server: String, lastViewed: Bool)
    {
        self.uuid        = uuid
        self.username    = username
        self.email       = email
        self.server      = server
        self.lastViewed  = lastViewed
        
        super.init()
    }
    
    
    override class var databaseTableName: String
    {
        return SqliteDB.ACCOUNT
    }

    
    override func encode(to container: inout PersistenceContainer)
    {
        container[CodingKeys.uuid.rawValue]       = uuid
        container[CodingKeys.username.rawValue]   = username
        container[CodingKeys.email.rawValue]      = email
        container[CodingKeys.server.rawValue]     = server
        container[CodingKeys.lastViewed.rawValue] = lastViewed
    }

    
    required init(row: Row)
    {
        uuid        = row[CodingKeys.uuid.rawValue]
        username    = row[CodingKeys.username.rawValue]
        email       = row[CodingKeys.email.rawValue]
        server      = row[CodingKeys.server.rawValue]
        lastViewed  = row[CodingKeys.lastViewed.rawValue]
        
        super.init()
    }
    
   

    func desc() -> String
    {
        return "\(server)-\(email)"
    }
    
    //
    // construct key for dictionaries of mastio and accounts
    //
    func accountKey() -> AccountKey
    {
        return AccountKey(server: server, username: username)
    }
    
    
    //
    // key for Keychain storage of client login token
    //
    func makeKeyChainName() -> String
    {
        return "\(LocalAccountRecord.accessTokenKeyNamePrefix).\(email).\(server)"
    }
}
