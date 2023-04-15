//
//  Utils.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/10/23.
//

import Foundation
import SwiftUI




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


struct EdgeBorder: Shape
{
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path
    {
        var path = Path()
        for edge in edges
        {
            var x: CGFloat
            {
                switch edge
                {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat
            {
                switch edge
                {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat
            {
                switch edge
                {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat
            {
                switch edge
                {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

 
extension Color
{
    var nsColor: NSColor?
    {
        NSColor.init(self).usingColorSpace(.deviceRGB)
    }
    
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    
    var rgba: RGBA?
    {
        var (r, g, b, a): RGBA = (0, 0, 0, 0)
        
        nsColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return (r, g, b, a)
    }
    
    var hexaRGB: String?
    {
        guard let (red, green, blue, _) = rgba else { return nil }
        
        return String(format: "#%02x%02x%02x",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255))
    }
    
    var hexaRGBA: String?
    {
        guard let (red, green, blue, alpha) = rgba else { return nil }
        
        return String(format: "#%02x%02x%02x%02x",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255),
            Int(alpha * 255))
    }
}



extension String
{
    func htmlAttributedString(color : Color = Color.black,linkColor : Color = Color.blue,font:Font) -> NSAttributedString?
    {
        
        let htmlTemplate = """
        <!doctype html>
        <html>
          <head>
            <style>
        p { padding:5em; }
                body {
                    color: \(color.hexaRGB ?? "#555555");
                }
                a {
                    color: \(linkColor.hexaRGB ?? "#000088");
                     text-decoration: none;
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
        
        guard let attributedString = try? NSMutableAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes:  nil
            )
        else
        {
            return nil
        }
        
        attributedString.addAttribute(NSAttributedString.Key.font, value:font, range:NSRange(location: 0, length: attributedString.length))

       // print("HTML \(self)")
        return attributedString
    }
}



func showOpenPanel() -> [URL]?
{
    let openPanel = NSOpenPanel()
    //openPanel.allowedContentTypes =
    openPanel.allowsMultipleSelection = true
    openPanel.canChooseDirectories = false
    openPanel.canChooseFiles = true
    let response = openPanel.runModal()
    return response == .OK ? openPanel.urls : nil
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
