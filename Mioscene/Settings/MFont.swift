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
        var newsize : CGFloat
        
        switch size
        {
        case .small:
            newsize = 18.0
        case .normal :
            newsize = 16.0
        case .large:
            newsize = 26.0
        }
    
        title = Font.custom(name, size:newsize * 2.0)
        headline = Font.custom(name, size:newsize * 1.5)
        subheadline = Font.custom(name, size:newsize * 0.80)
        body = Font.custom(name, size:newsize * 1.0)
        footnote = Font.custom(name, size:newsize * 0.75)
    }
}

