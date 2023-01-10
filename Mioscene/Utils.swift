//
//  Utils.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/10/23.
//

import Foundation
import SwiftUI


class Log
{
    static var fileName : String?
    
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


func SpacerLine(color:Color) -> some View
{
    return Rectangle().frame(height: 1).foregroundColor(color)
}


func dateSinceNowToString(date:Date) -> String
{
    let hours = abs(date.timeIntervalSinceNow) / 60 / 60
    if hours > 1.0
    {
        if hours > 24
        {
            return "\(Int(hours / 24))d"
        }
        else
        {
            return "\(Int(hours))h"
        }
    }
    else
    {
        let minutes = 60 * hours
        if minutes >= 1.0
        {
            return "\(Int(minutes))m"
        }
        else
        {
            let seconds = 60 * minutes
            return "\(Int(seconds))s"
        }
    }
    
}

extension View
{
    func border(width: CGFloat, edges: [Edge], color: SwiftUI.Color) -> some View
    {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

extension String
{
    func htmlAttributedString(fontSize: CGFloat = 16, color : Color = Color.black,linkColor : Color = Color.blue,fontFamily: String = "SF Pro") -> NSAttributedString?
    {
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
                body {
                    color: \(color);
                    font-family: \(fontFamily);
                    font-size: \(fontSize)px;
                }
                a {
                    color: \(linkColor);
                }
            </style>
          </head>
          <body>
            \(self)
          </body>
        </html>
        """

        guard let data = htmlTemplate.data(using: .unicode) else
        {
            return nil
        }

        guard let attributedString = try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
            ) else {
            return nil
        }

        return attributedString
    }
}



func showOpenPanel() -> URL?
{
    let openPanel = NSOpenPanel()
    //openPanel.allowedContentTypes =
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    let response = openPanel.runModal()
    return response == .OK ? openPanel.url : nil
}


enum ImageFormat: RawRepresentable
{
    case unknown, png, jpeg, gif, tiff1, tiff2
    
    init?(rawValue: [UInt8])
    {
        switch rawValue {
        case [0x89]: self = .png
        case [0xFF]: self = .jpeg
        case [0x47]: self = .gif
        case [0x49]: self = .tiff1
        case [0x4D]: self = .tiff2
        default: return nil
        }
    }
    
    var rawValue: [UInt8]
    {
        switch self
        {
        case .png: return [0x89]
        case .jpeg: return [0xFF]
        case .gif: return [0x47]
        case .tiff1: return [0x49]
        case .tiff2: return [0x4D]
        case .unknown: return []
        }
    }
}


extension NSData
{
    var imageFormat: ImageFormat
    {
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        return ImageFormat(rawValue: buffer) ?? .unknown
    }
}


extension Data
{
    var imageFormat: ImageFormat
    {
        (self as NSData?)?.imageFormat ?? .unknown
    }
}
