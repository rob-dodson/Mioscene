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
    
    var html = 16.0
    var iconsize = 20.0
    
    @Published var name : String
    
    var title : Font!
    var headline : Font!
    var subheadline : Font!
    var body : Font!
    var footnote : Font!
    
    static var fontList = ["System","SF Pro","Avenir","Helvetica Neue","Georgia","Menlo","Myriad","Futura","Gill Sans"]
    
    init(fontName:String,size:TextSize)
    {
        name = fontName
        var newsize = MFont.getSizeFromName(size:size)
        
        title = Font.custom(name, size:newsize * 2.0)
        headline = Font.custom(name, size:newsize * 1.25)
        subheadline = Font.custom(name, size:newsize * 0.80)
        body = Font.custom(name, size:newsize * 1.0)
        footnote = Font.custom(name, size:newsize * 0.85)
    }
    
    static func getSizeFromName(size: TextSize) -> CGFloat
    {
        switch size
        {
        case .tiny:
            return 8.0
        case .small:
            return 12.0
        case .normal :
            return 18.0
        case .large:
            return 26.0
        }
    }
}

