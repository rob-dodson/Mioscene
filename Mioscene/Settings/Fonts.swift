//
//  Fonts.swift
//  Mioscene
//
//  Created by Robert Dodson on 1/11/23.
//

import Foundation
import SwiftUI




class Fonts
{
    enum TextSize : String,Equatable,CaseIterable
    {
        case large
        case normal
        case small
    }
    
    var textSize : TextSize = .small
    
    var title = Font.system(.largeTitle)
    var heading = Font.system(.title)
    var subheading = Font.system(.title3)
    var main = Font.system(.body)
    var small = Font.system(.footnote)
    var html = 16.0
    var iconsize = 20.0
    
    init()
    {
        setFonts()
    }
    
    func setFonts()
    {
        switch textSize
        {
        case .small:
            title = Font.system(.title)
            heading = Font.system(.title2)
            subheading = Font.system(.subheadline)
            main = Font.system(.callout)
            small = Font.system(.footnote)
            html = 12.0
            iconsize = 18.0
            
        case .normal:
            title = Font.system(.largeTitle)
            heading = Font.system(.title)
            subheading = Font.system(.title3)
            main = Font.system(.body)
            small = Font.system(.footnote)
            html = 16.0
            iconsize = 22.0
            
        case .large:
            title = Font.system(.largeTitle)
            heading = Font.system(.title)
            subheading = Font.system(.title3)
            main = Font.system(.body)
            small = Font.system(.footnote)
            html = 16.0
            iconsize = 26.0
            
       
        }
    }
}
