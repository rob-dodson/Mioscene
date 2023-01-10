//
//  Account.swift
//  Miocene
//
//  Created by Robert Dodson on 1/2/23.
//

import Foundation

import MastodonKit
import GRDB


class LocalAccountRecord : Record,Codable,Identifiable
{
    var uuid : UUID
    var username : String
    var email : String
    var server : String
    var lastViewed : Bool
    
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
        self.uuid = uuid
        self.username = username
        self.email = email
        self.server = server
        self.lastViewed = lastViewed
        
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
        uuid = row[CodingKeys.uuid.rawValue]
        username = row[CodingKeys.username.rawValue]
        email = row[CodingKeys.email.rawValue]
        server = row[CodingKeys.server.rawValue]
        lastViewed = row[CodingKeys.lastViewed.rawValue]
        
        super.init()
    }
    
    
    func makeKeyChainName() -> String
    {
        return "\(Mastodon.accessTokenKeyNamePrefix).\(email).\(server)"
    }
}
