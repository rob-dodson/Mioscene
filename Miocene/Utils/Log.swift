//
//  Log.swift
//  Miocene
//
//  Created by Robert Dodson on 3/30/23.
//

import Foundation

class Log
{
    static var fileName : String?
    
    static func logAlert(errorType:MioceneError,msg:String)
    {
        Log.log(msg:msg)
        AlertSystem.shared?.reportError(type:errorType, msg: msg)
    }
    
    
    static func log(msg:String)
    {
        log(msg: msg, rewindfile: false)
    }
    
    
    static func log(msg:String, rewindfile:Bool)
    {
        print("debug: \(msg)")
        
        do
        {
            if fileName == nil
            {
                let logdir = try FileManager.default
                    .url(for: .applicationSupportDirectory,
                         in: .userDomainMask,
                         appropriateFor: nil,
                         create: true)
                    .appendingPathComponent("Miocene")
                
                fileName = "\(logdir.path)/Logging.txt"
            }
            
            if let filepath = fileName
            {
                let logmsg = "\(Date().description): \(msg)"
                
                if rewindfile == true
                {
                    try FileManager.default.removeItem(atPath: filepath)
                }
                
                if FileManager.default.fileExists(atPath: filepath) == false
                {
                    FileManager.default.createFile(atPath: filepath, contents: nil, attributes: nil)
                }
                
                guard let file = FileHandle.init(forWritingAtPath: filepath) else { return }
                
                file.seekToEndOfFile()
                file.write(logmsg.data(using: .utf8)!)
                file.write("\n".data(using: .utf8)!)
                file.closeFile()
            }
        }
        catch
        {
            print("write to debug file failed. error: \(error) - msg: \(msg)")
        }
    }
}
