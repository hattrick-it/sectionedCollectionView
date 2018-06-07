//
//  SectionedCollectionView.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/11/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import RxDataSources
import RxSwift

class SectionedCollectionView: UIView {
 
    private let background = UIColor(red: 239/255, green: 241/255, blue: 247/255, alpha: 1)
    
    var collectionView: UICollectionView!
    var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfCustomData>!
    
    let disposeBag = DisposeBag()
    
    var selectedLimit: Int?
    
    // MARK: - Outputs
    
    var selectedSections: Observable<[CustomData]> {
        return sections.asObservable().map({ sections -> [CustomData] in
            return sections.compactMap({ sections -> [CustomData] in
                return sections.selectedItems().items
            }).flatMap({ $0 })
        })
    }
    
    var limitReached: Observable<Void> {
        return _limitReached.asObservable()
    }
    
    // MARK: - Inputs
    
    var setSections: AnyObserver<[SectionOfCustomData]> {
        return _sections.asObserver()
    }
    
    // MARK: - RxSwift varable
    private let sections = Variable<[SectionOfCustomData]>([])
    private let _sections = PublishSubject<[SectionOfCustomData]>()
    private let _limitReached = PublishSubject<Void>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
       
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupView()
        self.setupCollectionView()
        self.setupBindings()
    }
    
    fileprivate func setupView(){
        backgroundColor = background
    }
    
    fileprivate func setupCollectionView(){
        self.addCollectionView()
        self.setupCollectionViewLayout()
        self.registerHeaderCell()
        self.registerFooterCell()
        self.registerCollectionViewCell()
        self.setupDataSource()
    }
    
    fileprivate func addCollectionView() {
        collectionView = UICollectionView(frame: self.frame, collectionViewLayout: UICollectionViewFlowLayout())
        self.addSubview(collectionView)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        constraints.append(NSLayoutConstraint(item: self.collectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        self.addConstraints(constraints)
    }
    
    fileprivate func setupCollectionViewLayout() {
        let collectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // Setup Header & Footer Size
        collectionViewFlowLayout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: 40)
        collectionViewFlowLayout.footerReferenceSize = CGSize(width: collectionView.frame.width, height: 2)
        
        // Setup Cell Size
        collectionViewFlowLayout.itemSize = CGSize(width: ((collectionView.frame.width - 40) / 3), height: ((collectionView.frame.width - 40) / 3) * 0.9)
        
        // Setup Minimun Spaces
        collectionViewFlowLayout.minimumLineSpacing = 8
        collectionViewFlowLayout.minimumInteritemSpacing = 8
        
        // Setup Edges
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 2, left: 12, bottom: 10, right: 12)
    }
    
    fileprivate func registerHeaderCell() {
        let nib = UINib(nibName: HeaderViewCell.nibName, bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderViewCell.cellReuseIdentifier)
    }
    
    fileprivate func registerFooterCell() {
        let nib = UINib(nibName: FooterViewCell.nibName, bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FooterViewCell.cellReuseIdentifier)
    }
    
    fileprivate func registerCollectionViewCell() {
        let nib = UINib(nibName: ItemCollectionViewCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ItemCollectionViewCell.cellReuseIdentifier)
    }
    
    fileprivate func setupDataSource() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: { (dataSource, collectionView, indexPath, item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.cellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
            cell.configure(with: item.name, selected: item.selected)
            return cell
        })
        
        self.dataSource.configureSupplementaryView = {(dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            if (kind == UICollectionElementKindSectionHeader) {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderViewCell.cellReuseIdentifier, for: indexPath) as! HeaderViewCell
                header.configure(withName: dataSource[indexPath.section].header)
                return header
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: FooterViewCell.cellReuseIdentifier, for: indexPath) as! FooterViewCell
                return footer
            }
        }
    }
    
    fileprivate func setupBindings() {
        _sections.asObservable()
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        self.sections.asObservable()
            .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let selectedItemsCount = self.sections.value.compactMap({ sections -> [CustomData] in
                    return sections.selectedItems().items
                }).flatMap({ $0 }).count
                
                if (self.sections.value[indexPath.section].items[indexPath.row].selected || (self.selectedLimit != nil && selectedItemsCount < self.selectedLimit!)) {
                    self.sections.value[indexPath.section].items[indexPath.row].selected = !self.sections.value[indexPath.section].items[indexPath.row].selected
                } else {
                    self._limitReached.asObserver().onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public override variables
    
    var headerReferenceSize: CGSize {
        
        set {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewFlowLayout?.headerReferenceSize = newValue
        }
        
        get {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            return collectionViewFlowLayout?.headerReferenceSize ?? .zero
        }
        
    }
    
    var footerReferenceSize: CGSize {
        
        set {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewFlowLayout?.footerReferenceSize = newValue
        }
        
        get {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            return collectionViewFlowLayout?.footerReferenceSize ?? .zero
        }
        
    }
    
    var itemSize: CGSize {
        
        set {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewFlowLayout?.itemSize = newValue
        }
        
        get {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            return collectionViewFlowLayout?.itemSize ?? .zero
        }
    
    }
    
    var minimumLineSpacing: CGFloat {
        set {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewFlowLayout?.minimumLineSpacing = newValue
        }
        
        get {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            return collectionViewFlowLayout?.minimumLineSpacing ?? 0
        }
        
    }
    
    var minimumInteritemSpacing: CGFloat {
        
        set {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewFlowLayout?.minimumInteritemSpacing = newValue
        }
        
        get {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            return collectionViewFlowLayout?.minimumInteritemSpacing ?? 0
        }
        
    }
    
    var sectionInset: UIEdgeInsets {
        
        set {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            collectionViewFlowLayout?.sectionInset = newValue
        }
        
        get {
            let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            return collectionViewFlowLayout?.sectionInset ?? .zero
        }
        
    }

}
