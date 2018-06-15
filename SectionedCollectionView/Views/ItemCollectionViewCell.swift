//
//  CollectionViewCell.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/8/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit

public class ItemCollectionViewCell: UICollectionViewCell {
    
    class var nibName: String {
        return "ItemCollectionViewCell"
    }
    class var cellReuseIdentifier: String {
        return "ItemCollectionViewCell"
    }
    
    func configure(withValue value: Any){}
    
}
