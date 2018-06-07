//
//  HeaderViewCell.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/8/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit

class HeaderViewCell: UICollectionViewCell {
    
    static let nibName = "HeaderViewCell"
    static let cellReuseIdentifier = "HeaderViewCell"
    
    private let textColor = UIColor(red: 151/255, green: 164/255, blue: 180/255, alpha: 1)
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupStyle()
    }
    
    func configure(withName name: String) {
        nameLabel.text = name
    }
    
    private func setupStyle() {
        nameLabel.textColor = textColor
    }
    
}
