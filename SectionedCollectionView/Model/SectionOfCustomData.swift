//
//  SectionOfCustomData.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation

struct SectionOfCustomData {
    var header: String
    var items: [Item]
}

extension SectionOfCustomData {
    typealias Item = CustomData
    
    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
    
    func selectedItems() -> SectionOfCustomData {
        return SectionOfCustomData(header: self.header, items: self.items.filter({ item -> Bool in
            item.selected
        }))
    }
}
