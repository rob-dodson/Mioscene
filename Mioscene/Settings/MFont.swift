//
//  Fonts.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/11/23.
//

import Foundation
import SwiftUI


class MFont : ObservableObject
{
    enum TextSize : String,Identifiable,CaseIterable
    {
        case tiny = "Tiny"
        case small = "Small"
        case normal = "Normal"
        case large = "Large"
    
        var id: Self { return self }
    }
    
    @Published var currentSizeName = TextSize.normal
    @Published var name : String
    
    var title : Font!
    var headline : Font!
    var subheadline : Font!
    var body : Font!
    var footnote : Font!
    
    static var fontList = ["System","SF Pro","SF Pro Rounded","Avenir","Helvetica Neue","Georgia","Menlo","Myriad","Times New Roman","Gill Sans","Baskerville"]
    
    init(fontName:String,sizeName:TextSize)
    {
        name = fontName
        
        currentSizeName = sizeName
        
        let newsize = MFont.getSizeFromName(size:currentSizeName)
        
        title = Font.custom(name, size:newsize * 2.0)
        headline = Font.custom(name, size:newsize * 1.25)
        subheadline = Font.custom(name, size:newsize * 0.90)
        body = Font.custom(name, size:newsize * 1.0)
        footnote = Font.custom(name, size:newsize * 0.85)
    }
    
    func getSize() -> CGFloat
    {
        return MFont.getSizeFromName(size: currentSizeName)
    }
    
    static func getSizeFromName(size: TextSize) -> CGFloat
    {
        switch size
        {
        case .tiny:
            return 10.0
        case .small:
            return 14.0
        case .normal :
            return 18.0
        case .large:
            return 26.0
        }
    }
    
    static func getEnumFromString(string:String) -> TextSize
    {
        switch string
        {
        case "Tiny":
            return TextSize.tiny
        case "Small":
            return TextSize.small
        case "Normal":
            return TextSize.normal
        case "Large":
            return TextSize.large
        default:
            return TextSize.normal
        }
    }
}

