//
//  Filter.swift
//  Mazima Mzima
//
//  Created by Robert Dodson on 12/21/22.
//

import SwiftUI
import MastodonKit

enum KeepOrReject : String,Identifiable,CaseIterable
{
    case keep = "Keep"
    case reject = "Reject"
    
    var id: Self { return self }
}

enum FilterType : String,Identifiable,CaseIterable
{
    case displayName = "Display Name"
    case accountName = "Account Name"
    case body = "Body"
    case hashtag = "Hashtag"
    
    var id: Self { return self }
}

struct FilterSet : Hashable,Identifiable
{
    var name : String
    var filters : [Filter]
    
    var id = UUID()
}

struct Filter : Hashable,Identifiable
{
    var name : String
    var isOn : Bool
    var keepOrReject : KeepOrReject
    var isRegex : Bool
    var filterString : String
    var type : FilterType
    
    var id = UUID()
}

func getFilters() -> [FilterSet]
{
    let filter1 = Filter(name: "BMW", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "BMW", type: .body)
    let filter2 = Filter(name: "BMW Hashtag", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "#bmw", type: .hashtag)
    let filter3 = Filter(name: "No Audi", isOn: true, keepOrReject: .reject, isRegex: true, filterString: ".*Audi.*", type: .body)
    let filterset1 = FilterSet(name: "BMW Filters", filters: [filter1,filter2,filter3])

    let filter00 = Filter(name: "macOS name", isOn: true, keepOrReject: .keep, isRegex: true, filterString: ".*macos.*", type: .displayName)
    let filter01 = Filter(name: "macOS", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "MacOS", type: .body)
    let filter02 = Filter(name: "macOS Hashtag", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "#bmw", type: .hashtag)
    let filter03 = Filter(name: "No Windows", isOn: true, keepOrReject: .reject, isRegex: false, filterString: "Windows", type: .body)
    let filterset2 = FilterSet(name: "macOS Filters", filters: [filter00,filter01,filter02,filter03])

    var filtersets = [FilterSet]()
    filtersets.append(filterset1)
    filtersets.append(filterset2)
    
    return filtersets
}

struct Filters: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var errorSystem : ErrorSystem
    @EnvironmentObject var appState : AppState
    
    @State private var shouldPresentSheet = false
    @State private var filterSets = [FilterSet]()
    @State private var currentFilterSet : FilterSet?
    
    
    var body: some View
    {
        HStack
        {
            if filterSets.count > 0
            {
                Picker("", selection: $currentFilterSet)
                {
                    ForEach(filterSets.indices, id:\.self)
                    { idx in
                        Text(filterSets[idx].name)
                    }
                }
                .frame(maxWidth: 200)
                .onChange(of: currentFilterSet)
                { newValue in
                 print("FILTER \(newValue)")
                }
            }
        }
        
        Button()
        {
            shouldPresentSheet.toggle()
        }
    label:
        {
            HStack
            {
                Image(systemName: "camera.filters")
                Text("Edit Filters")
            }
        }
        .onAppear()
        {
            filterSets = getFilters()
            currentFilterSet = filterSets[0]
        }
        .sheet(isPresented: $shouldPresentSheet)
        {
            Log.log(msg:"Sheet dismissed!")
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
                
                ForEach(filterset.filters.indices, id:\.self)
                { idx in
                    showFilter(setIndex:setindex,filterIndex: idx)
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
        .padding(10)
        .background(settings.theme.blockColor)
    }
}
