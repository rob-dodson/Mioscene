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

enum FilterSetType : String,Identifiable,CaseIterable,Equatable
{
    case AnyFilter = "Match Any"
    case AllFilters = "Match All"
    
    var id: Self { return self }
}

struct FilterSet : Hashable,Identifiable
{
    var name : String
    var filters : [Filter]
    var setType : FilterSetType
    
    var id = UUID()
}

struct Filter : Hashable,Identifiable
{
    var name : String
    var isOn : Bool
    var keepOrReject : KeepOrReject
    var isRegex : Bool
    var ingoreCase : Bool = true
    var filterString : String
    var type : FilterType
    
    var id = UUID()
}

struct FilterTools
{
    static var shared = FilterTools()
    
    //
    // load saved filters from defaults or database
    //
    func getFilters() -> [FilterSet]
    {
        let filter000 = Filter(name: "All Are Good", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "", type: .body)
        let filterset0 = FilterSet(name: "No Filter", filters: [filter000],setType: .AnyFilter)
        
        let filter1 = Filter(name: "BMW", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "BMW", type: .body)
        let filter2 = Filter(name: "BMW Hashtag", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "#bmw", type: .hashtag)
        let filter3 = Filter(name: "No Audi", isOn: true, keepOrReject: .reject, isRegex: true, filterString: ".*Audi.*", type: .body)
        let filterset1 = FilterSet(name: "BMW", filters: [filter1,filter2,filter3],setType: .AnyFilter)
        
        let filter00 = Filter(name: "macOS name", isOn: true, keepOrReject: .keep, isRegex: true, filterString: ".*macos.*", type: .displayName)
        let filter01 = Filter(name: "macOS", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "MacOS", type: .body)
        let filter02 = Filter(name: "macOS Hashtag", isOn: true, keepOrReject: .keep, isRegex: false, filterString: "#bmw", type: .hashtag)
        let filter03 = Filter(name: "No Windows", isOn: true, keepOrReject: .reject, isRegex: false, filterString: "Windows", type: .body)
        let filterset2 = FilterSet(name: "macOS", filters: [filter00,filter01,filter02,filter03],setType: .AnyFilter)
        
        var filtersets = [FilterSet]()
        filtersets.append(filterset0)
        filtersets.append(filterset1)
        filtersets.append(filterset2)
        
        return filtersets
    }
    
    
    func makeItems(filtersets:[FilterSet]) -> [PopMenuItem<FilterSet>]
    {
        var items = [PopMenuItem<FilterSet>]()
        
        for index in 0..<filtersets.count
        {
            let menuitem = PopMenuItem(text: filtersets[index].name, userData:filtersets[index] )
            items.append(menuitem)
        }
        items.append(PopMenuItem(text: "Edit Filters", userData: nil))
        
        return items
    }
    
    
    func strcmp(a:String,b:String,ignoreCase:Bool) -> Bool
    {
        if ignoreCase == true
        {
            if a.uppercased() == b.uppercased() { return true } else { return false }
        }
        else
        {
            if a == b { return true } else { return false }
        }
    }
    
    
    func keepItem(filter:Filter,stat:MStatus) -> Bool
    {
        var match = false
        
        switch filter.type
        {
            case .accountName:
                match = strcmp(a:stat.status.account.acct,b:filter.filterString,ignoreCase:filter.ingoreCase)
                
            case .displayName:
                match = strcmp(a:stat.status.account.displayName,b:filter.filterString,ignoreCase:filter.ingoreCase)
                
            case .hashtag:
                for hashtag in stat.status.tags
                {
                    if hashtag.name == filter.filterString { match = true }
                }
                
            case .body:
                if stat.status.content.contains(try! Regex(filter.filterString)) { match = true }
        }
        
        switch filter.keepOrReject
        {
            case .keep:
                return match == true ? true : false
                
            case .reject:
                return match == true ? false : true
        }
    }
    
    func filterStats(filterSet:FilterSet,stats:[MStatus]) -> [MStatus]
    {
        var filteredstats = [MStatus]()
        
        for stat in stats
        {
            var keepit = false
            
            for filter in filterSet.filters
            {
                if filter.isOn == false { continue }
                
                let match = keepItem(filter: filter, stat: stat)
                
                switch filterSet.setType
                {
                    case .AllFilters:
                        if match == false { keepit = false }
                    case .AnyFilter:
                        if match == true { keepit = true }
                }
            }
            
            if keepit == true
            {
                filteredstats.append(stat)
            }
        }
        
        return filteredstats
    }
}
