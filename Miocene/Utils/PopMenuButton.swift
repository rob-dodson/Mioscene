//
//  PopMenuButton.swift
//  Miocene
//
//  Created by Robert Dodson on 1/24/23.
//

import SwiftUI



//
// Returned to caller when a menu item is selected
//
struct PopMenuItem<UserType>
{
    let text : String
    let userData : UserType?
}


//
// A custom pop down menu where the button is PopButton
//
struct PopMenu<UserType> : View
{
    let icon : String
    @State var selected : String
    let menuItems : [PopMenuItem<UserType>]
    let picked: (PopMenuItem<UserType>) -> Void
    
    @State private var showMenu = false
    
    @EnvironmentObject var settings: Settings
  
    
    var body: some View
    {
        HStack
        {
            if let item = menuItems.first(where: {$0.text == selected})
            {
                PopButton(text: item.text,icon:icon,isSelected: false)
                {
                    showMenu = true
                }
            }
        }
        .popover(isPresented: $showMenu,arrowEdge:.bottom)
        {
            menu(food: menuItems)
        }
    }
    
    func menu(food:[PopMenuItem<UserType>]) -> some View
    {
        //
        // draw the checkmark for the currently selected item
        //
        HStack(alignment:.top)
        {
            VStack(alignment: .leading)
            {
                ForEach(food.indices,id:\.self)
                { idx in
                    if food[idx].text  == selected
                        {
                            Image(systemName: "checkmark")
                                .foregroundColor(settings.theme.accentColor)
                                .padding(EdgeInsets(top: 2, leading: 4, bottom: 0, trailing: 0))
                        }
                        else
                        {
                            Text(" ")
                                .padding(EdgeInsets(top: 2, leading: 4, bottom: 0, trailing: 0))
                        }
                }
            }
            
            //
            // menu items
            //
            VStack(alignment: .leading)
            {
                ForEach(food.indices,id:\.self)
                { idx in
                        Text(food[idx].text)
                            .onTapGesture
                        {
                            showMenu = false
                            self.selected = food[idx].text
                            picked(food[idx])
                        }
                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 2))
                }
            }
        }
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
    }
}


//
// interface to PopButtonColor that can override the theme colors
//
struct PopButton: View
{
    @EnvironmentObject var settings: Settings
    
    let text : String
    let icon : String
    let isSelected : Bool
    var ontap: () -> Void
    
    var body : some View
    {
        PopButtonColor(text: text,
                       icon: icon,
                       textColor: settings.theme.minorColor,
                       iconColor: settings.theme.bodyColor,
                       isSelected: isSelected,
                       ontap: ontap)
    }
}


//
// icon button that glows accent color for a bit when clicked
//
struct PopButtonColor: View
{
    @EnvironmentObject var settings: Settings
    
    let text : String
    let icon : String
    let textColor : Color
    let iconColor : Color
    let isSelected : Bool
    var ontap: () -> Void // called when user clicks on this button
    
    @State private var tap = false
    
    
    var body: some View
    {
        VStack(alignment: .center,spacing: 3)
        {
            Image(systemName:icon)
                .font(.system(size: CGFloat(settings.iconSize), weight: .light))
                .foregroundColor(tap ? settings.theme.accentColor : (isSelected == true ? settings.theme.accentColor : iconColor))
                .scaleEffect(tap ? 1.2 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6),value: tap)
                .help(text)
                .onTapGesture
                {
                    tap = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                    {
                        tap = false
                        ontap()
                    }
                }
            
            if settings.hideIconText == false
            {
                Text(text)
                    .font(settings.font.footnote)
                    .foregroundColor(textColor)
            }
        }
    }
}

//
// a text only pop button
//
struct PopTextButton: View
{
    @EnvironmentObject var settings: Settings
    
    let text : String
    let font : Font
    var ontap: (String) -> Void
    
    @State private var tap = false
    
    var body: some View
    {
        VStack(alignment: .center,spacing: 3)
        {
            Text(text)
                .font(font)
                .foregroundColor(tap ? settings.theme.accentColor : settings.theme.minorColor)
                .scaleEffect(tap ? 1.1 : 1)
                .animation(.spring(response: 0.4, dampingFraction: 0.6),value: tap)
                .help(text)
                .onTapGesture
            {
                tap = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    tap = false
                    ontap(text)
                }
            }
        }
    }
}
