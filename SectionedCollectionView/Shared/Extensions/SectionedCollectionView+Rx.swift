//
//  SectionedCollectionView+Reactive.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

extension Reactive where Base: SectionedCollectionView {
    
    var items: Binder<[SectionOfCustomData]> {
        return Binder(self.base) { (view, sections) -> () in
            view.setSections.onNext(sections)
        }
    }
    
    var selectedItems: Observable<[CustomData]> {
        return base.selectedSections
    }
    
    var limitReached: Observable<Void> {
        return base.limitReached
    }
    
}
