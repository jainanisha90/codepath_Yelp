//
//  FilterSection.swift
//  Yelp
//
//  Created by Anisha Jain on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import Foundation

class FilterSection {
    var filterSectionTitle: String?
    var filterCells: [FilterCell]!
    
    init(_ filterSectionTitle: String, _ filterCells: [FilterCell]) {
        self.filterSectionTitle = filterSectionTitle
        self.filterCells = filterCells
    }
    
}

class FilterCell {
    var displayName: String?
    var code: String?
    
    init(_ displayName: String, _ code: String) {
        self.displayName = displayName
        self.code = code
    }
}
