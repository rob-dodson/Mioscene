//
//  Account.swift
//  Mammut
//
//  Created by Robert Dodson on 1/2/23.
//

import Foundation

import GRDB

class LocalAccountRecord : Record,Codable
{
    var uuid : UUID
    var username : String
    var server : String
    var lastViewed : Bool
    
    enum CodingKeys: String,CodingKey
    {
        case uuid
        case username
        case server
        case lastViewed
    }
    
    init(uuid: UUID = UUID(), username: String, server: String, lastViewed: Bool)
    {
        self.uuid = uuid
        self.username = username
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
        container[CodingKeys.uuid.rawValue]           = uuid
        container[CodingKeys.username.rawValue]       = username
        container[CodingKeys.server.rawValue]          = server
        container[CodingKeys.lastViewed.rawValue]       = lastViewed
    }

    
    required init(row: Row)
    {
        uuid = row[CodingKeys.uuid.rawValue]
        username = row[CodingKeys.username.rawValue]
        server = row[CodingKeys.server.rawValue]
        lastViewed = row[CodingKeys.lastViewed.rawValue]
        
        super.init()
    }
    
    
    func makeKeyChainName() -> String
    {
        return "\(Mastodon.accessTokenKeyNamePrefix).\(username).\(server)"
    }
}
