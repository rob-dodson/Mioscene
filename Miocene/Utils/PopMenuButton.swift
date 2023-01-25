//
//  PopMenuButton.swift
//  Miocene
//
//  Created by Robert Dodson on 1/24/23.
//

import SwiftUI

struct PopMenuItem
{
    let text : String
}


struct PopMenu : View
{
    let icon : String
    let menuItems : [PopMenuItem]
    let picked: (PopMenuItem) -> Void
    
    @State private var showMenu = false
    @State private var currentItem : Int = 0
    
    @EnvironmentObject var settings: Settings
  
    var body: some View
    {
        HStack
        {
            PopButton(text: menuItems[currentItem].text,icon:icon)
                .onTapGesture
            {
                showMenu = true
            }
        }
        .popover(isPresented: $showMenu,arrowEdge:.bottom)
        {
            menu(food: menuItems)
        }
    }
    
    func menu(food:[PopMenuItem]) -> some View
    {
        VStack(alignment: .leading)
        {
            ForEach(food.indices,id:\.self)
            { idx in
                HStack
                {
                    if idx == currentItem
                    {
                        Image(systemName: "checkmark")
                            .foregroundColor(settings.theme.accentColor)
                    }
                    
                    Text(food[idx].text)
                        .onTapGesture
                    {
                        showMenu = false
                        currentItem = idx
                        picked(food[idx])
                    }
                }
            }
        }
        .padding()
        .font(settings.font.body)
        .foregroundColor(settings.theme.bodyColor)
        .background(settings.theme.blockColor)
        .opacity(60.0)
    }
    
}

func foo()
{
    
}

struct PopButton: View
{
    @EnvironmentObject var settings: Settings
    
    let text : String
    let icon : String
    
    var body: some View
    {
        VStack(alignment: .center,spacing: 3)
        {
            Image(systemName:icon)
                .font(.system(size: CGFloat(settings.iconSize), weight: .light))
                .foregroundColor(settings.theme.minorColor)

            Text(text)
        }
    }
}
