//
//  MStatus.swift
//  Miocene
//
//  Created by Robert Dodson on 1/22/23.
//

import Foundation
import MastodonKit

class MStatus : Identifiable,ObservableObject
{
    var status : Status
    
    @Published var favorited : Bool = false
    @Published var favoritesCount : Int = 0
    @Published var reblogged : Bool = false
    @Published var reblogsCount: Int = 0

    init(status:Status)
    {
        self.status = status
        self.favorited = status.favourited ?? false
        self.favoritesCount = status.favouritesCount
        self.reblogged = status.reblogged ?? false
        self.reblogsCount = status.reblogsCount
    }
    
    var id = UUID()
}
