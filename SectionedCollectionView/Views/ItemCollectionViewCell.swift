//
//  CollectionViewCell.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/8/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    static let nibName = "ItemCollectionViewCell"
    static let cellReuseIdentifier = "ItemCollectionViewCell"
    
    private let gradientStartColor = UIColor(red: 46/255, green: 132/255, blue: 250/255, alpha: 1)
    private let gradientEndColor = UIColor(red: 83/255, green: 99/255, blue: 236/255, alpha: 1)
    private var gradientBackgroundLayer: CAGradientLayer?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupStyle()
    }
    
    func configure(with name: String, selected: Bool) {
        nameLabel.text = name
        nameLabel.textColor = selected ? .white : .black
        activeGradientBackground(selected: selected)
    }
    
    private func setupStyle() {
        backgroundColor = .white
        layer.cornerRadius = 20
        setupGradientBackground()
    }
    
    private func setupGradientBackground() {
        gradientBackgroundLayer = CAGradientLayer()
        gradientBackgroundLayer?.frame = self.bounds
        gradientBackgroundLayer?.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        gradientBackgroundLayer?.locations = [0, 1]
        gradientBackgroundLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientBackgroundLayer?.endPoint = CGPoint(x: 1, y: 1)
        layer.masksToBounds = true
    }
    
    private func activeGradientBackground(selected: Bool) {
        gradientBackgroundLayer?.frame = self.bounds
        gradientBackgroundLayer?.removeFromSuperlayer()
        if(selected){
            layer.insertSublayer(gradientBackgroundLayer!, at: 0)
        }
    }
    
}
