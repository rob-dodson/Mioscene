//
//  SQLiteDB.swift
//  Miocene
//
//  Created by Robert Dodson on 1/2/23.
//

import Foundation

import GRDB


class SqliteDB
{
    static let ACCOUNT : String = "account"
    
    #if DEBUG
    static let DATABASE_NAME : String = "miocene-v1-DEBUG.sqlite"
    #else
    static let DATABASE_NAME : String = "miocene-v1.sqlite"
    #endif
    
    var dbqueue : DatabaseQueue!
    
    
    init()
    {
        do
        {
            let databaseURL = try FileManager.default
                .url(for: .applicationSupportDirectory,
                      in: .userDomainMask,
          appropriateFor: nil,
                  create: true)
                 .appendingPathComponent("Miocene")
        
            try FileManager().createDirectory(at: databaseURL,
                                              withIntermediateDirectories: true,
                                              attributes: nil)
            
            dbqueue = try DatabaseQueue(path:"\(databaseURL.path)/\(SqliteDB.DATABASE_NAME)")
            Log.log(msg:"DB opened: \(dbqueue.path)")
            
            try makeTables()
            Log.log(msg:"tables ok")
        }
        catch
        {
            Log.log(msg:"sqlite error: \(error)")
        }
    }
    
    
    
    func makeTables() throws
    {
        try dbqueue.write
        { db in
            
            try db.create(table: SqliteDB.ACCOUNT, ifNotExists: true)
            { t in
                t.column(LocalAccountRecord.CodingKeys.uuid.rawValue,.text).notNull()
                t.column(LocalAccountRecord.CodingKeys.username.rawValue,.text)
                t.column(LocalAccountRecord.CodingKeys.email.rawValue,.text).notNull()
                t.column(LocalAccountRecord.CodingKeys.server.rawValue,.blob)
                t.column(LocalAccountRecord.CodingKeys.lastViewed.rawValue,.blob)
                t.primaryKey([LocalAccountRecord.CodingKeys.uuid.rawValue,LocalAccountRecord.CodingKeys.username.rawValue])
            }
        }
    }
    
    
    func loadAccounts() throws -> [LocalAccountRecord]
    {
        try dbqueue.write
        { db in
           
            let accounts = try LocalAccountRecord.fetchAll(db)
            
            if accounts.count > 0
            {
               return accounts
            }
            else
            {
                return [LocalAccountRecord]()
            }
            
        }
    }
    
    
    func deleteAccount(account:LocalAccountRecord) throws
    {
        try dbqueue.write
        { db in
            
            try account.delete(db)
            Log.log(msg:"account deleted: \(account.username)")
        }
    }
      
    
    func updateAccount(account:LocalAccountRecord) throws
    {
       try dbqueue.write
       { db in
           
           try account.save(db)
           Log.log(msg:"account saved: \(account.username)")
       }
    }
}
