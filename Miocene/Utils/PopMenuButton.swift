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
    let subMenu : PopMenu<UserType>?
    
    init(text: String, userData: UserType?, subMenu: PopMenu<UserType>? = nil)
    {
        self.text = text
        self.userData = userData
        self.subMenu = subMenu
    }
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
    @State private var showSubMenu = false
    
    @EnvironmentObject var settings: Settings
  
    
    var body: some View
    {
        HStack
        {
            if let item = findSelected(items: menuItems)
            {
                PopButton(text: item.text,icon:icon,isSelected: false)
                {
                    showMenu = true
                }
            }
        }
        .popover(isPresented: $showMenu,arrowEdge:.bottom)
        {
            menu(food: menuItems,picked:picked)
        }
        
    }
       
    
    func findSelected(items:[PopMenuItem<UserType>]) -> PopMenuItem<UserType>?
    {
        for item in items
        {
            if item.text == selected { return item }
            
            if let submenu = item.subMenu
            {
                for subitem in submenu.menuItems
                {
                    if subitem.text == selected { return subitem }
                }
            }
        }
        
        return nil
    }
    
    
    //
    // menu items
    //
    func menu(food:[PopMenuItem<UserType>],picked: @escaping (PopMenuItem<UserType>) -> Void) -> some View
    {
        HStack(alignment:.top)
        {
            
            VStack(alignment: .leading)
            {
                ForEach(food.indices,id:\.self)
                { idx in
                        
                    if food[idx].subMenu != nil
                    {
                        HStack
                        {
                            Image(systemName: food[idx].subMenu!.icon)
                            Text(food[idx].text)
                                .onTapGesture
                            {
                                showSubMenu = true
                            }
                            Spacer()
                            Text(">")
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: idx == food.count - 1 ? 10 : 0, trailing: 10))
                        .popover(isPresented: $showSubMenu,arrowEdge:.trailing)
                        {
                            if let sub = food[idx].subMenu
                            {
                                ForEach(sub.menuItems.indices,id:\.self)
                                { ii in
                                    makeMenuButton(item: sub.menuItems[ii],bottom: ii == sub.menuItems.count - 1,picked: sub.picked)
                                }
                            }
                        }
                    }
                    else
                    {
                        makeMenuButton(item: food[idx],bottom: idx == food.count - 1,picked:picked)
                    }
                }
            }
        }
    }
    
    
    func makeMenuButton(item:PopMenuItem<UserType>,bottom:Bool,picked: @escaping (PopMenuItem<UserType>) -> Void) -> some View
    {
        return HStack
        {
            if item.text  == selected
            {
                Image(systemName: "checkmark")
                    .foregroundColor(settings.theme.accentColor)
            }
            else
            {
                Text("   ")
            }
            Text(item.text)
                .onTapGesture
            {
                showMenu = false
                self.selected = item.text
                picked(item)
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: bottom == true ? 10 : 0, trailing:10))
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
