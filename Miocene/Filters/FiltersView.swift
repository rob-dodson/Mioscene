//
//  FiltersView.swift
//  Miocene
//
//  Created by Robert Dodson on 2/9/23.
//

import Foundation
import SwiftUI


struct FiltersView: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var errorSystem : ErrorSystem
    @EnvironmentObject var appState : AppState
    
    @State private var shouldPresentSheet = false
    @State private var filterSets = [FilterSet]()
    @State private var currentFilterSetIndex : Int = 0
    
    var body: some View
    {
        HStack
        {
            if filterSets.count > 0
            {
                PopMenu(icon: "camera.filters",selected: filterSets[currentFilterSetIndex].name,menuItems:FilterTools.shared.makeItems(filtersets: filterSets))
                { item in
                    shouldPresentSheet = true
                }
            }
        }
        .onAppear()
        {
            filterSets = FilterTools.shared.getFilters()
            currentFilterSetIndex = 0
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
        }
    content:
        {
            VStack
            {
                Text("Filters")
                    .foregroundColor(settings.theme.accentColor)
                    .font(settings.font.title)
                    .padding(.top)
                
                ScrollView
                {
                    VStack(alignment: .leading)
                    {
                        ForEach(filterSets.indices, id:\.self)
                        { index in
                            showFilterSet(setindex: index)
                        }
                    }
                    .padding()
                }
            }
            .errorAlert(error: $errorSystem.errorType,msg:errorSystem.errorMessage,done:
                            {
                if errorSystem.errorType == .ok
                {
                    shouldPresentSheet = false
                    appState.showHome()
                }
            })
            .frame(width: 800, height: 700)
            .toolbar
            {
                ToolbarItem
                {
                    Button("New Filter Set")
                    {
                    }
                }
                
                ToolbarItem
                {
                    Button("Cancel")
                    {
                        shouldPresentSheet = false
                    }
                }
                
                ToolbarItem
                {
                    Button("Save")
                    {
                    }
                }
            }
        }
    }
    
    
    func showFilterSet(setindex:Int) -> some View
    {
        return VStack
        {
            if let filterset = filterSets[setindex]
            {
                Text(filterset.name)
                    .foregroundColor(settings.theme.accentColor)
                    .font(settings.font.subheadline)
                    .padding(.top)
                
                VStack(alignment:.leading)
                {
                    Picker("", selection: $filterSets[setindex].setType)
                    {
                        ForEach(FilterSetType.allCases)
                        { t in
                            Text(t.rawValue ).tag(t)
                        }
                    }
                    .frame(maxWidth: 150)
                    
                    ForEach(filterset.filters.indices, id:\.self)
                    { idx in
                        showFilter(setIndex:setindex,filterIndex: idx)
                    }
                }
            }
        }
    }
    
    
    func showFilter(setIndex:Int,filterIndex:Int) -> some View
    {
        return HStack
        {
            Text("\(filterSets[setIndex].filters[filterIndex].name)")
            
            Toggle("", isOn: $filterSets[setIndex].filters[filterIndex].isOn)
                .onChange(of: filterSets[setIndex].filters[filterIndex].isOn)
            { newValue in
            }
            
            Picker("", selection: $filterSets[setIndex].filters[filterIndex].type)
            {
                ForEach(FilterType.allCases)
                { val in
                    Text(val.rawValue)
                }
            }
            
            VStack(alignment: .leading)
            {
                TextField("", text: $filterSets[setIndex].filters[filterIndex].filterString)
                Toggle("regex", isOn:  $filterSets[setIndex].filters[filterIndex].isRegex)
            }
            .padding(4)
            .border(width: 1,edges: [.leading,.trailing,.top,.bottom],color: settings.theme.minorColor)
            
            Picker("", selection: $filterSets[setIndex].filters[filterIndex].keepOrReject)
            {
                ForEach(KeepOrReject.allCases)
                { val in
                    Text(val.rawValue)
                }
            }
            
            Button("-")
            {
            }
            Button("+")
            {
            }
        }
        .padding(5)
        .background(settings.theme.blockColor)
    }
}
