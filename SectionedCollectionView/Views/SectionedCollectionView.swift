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

public struct SectionedCollectionViewSettings {
    
    public struct ViewCells {
        public var itemCollectionViewCellNibName: String = ItemCollectionViewCell.nibName
        public var itemCollectionViewCellReuseIdentifier: String = ItemCollectionViewCell.cellReuseIdentifier
        public var headerViewCellNibName: String = ItemCollectionViewCell.nibName
        public var headerViewCellReuseIdentifier: String = ItemCollectionViewCell.cellReuseIdentifier
        public var footerViewCellNibName: String = ItemCollectionViewCell.nibName
        public var footerViewCellReuseIdentifier: String = ItemCollectionViewCell.cellReuseIdentifier
    }
    
    public struct Style {
        public var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 2, left: 12, bottom: 10, right: 12)
        public var backgroundColor: UIColor = UIColor(red: 239/255, green: 241/255, blue: 247/255, alpha: 1)
    }
    
    public struct Data {
        public var selectedLimit: Int?
    }
    
    public struct HeaderStyle {
        public var headerReferenceHeight: CGFloat = 40
    }
    
    public struct FooterStyle {
        public var footerReferenceHeight: CGFloat = 2
    }
    
    public struct ItemsSetup {
        public var itemsForRows: Int = 3
        public var heightRatio: CGFloat = 0.9
        public var minimumLineSpacing: CGFloat = 8
        public var minimumInteritemSpacing: CGFloat = 8
    }
    
    public var viewCells = ViewCells()
    public var style = Style()
    public var data = Data()
    public var headerStyle = HeaderStyle()
    public var footerStyle = FooterStyle()
    public var itemsSetup = ItemsSetup()
    
}

class SectionedCollectionView: UIView {
 
    public var settings = SectionedCollectionViewSettings()
    
    var collectionView: UICollectionView!
    var dataSource: RxCollectionViewSectionedReloadDataSource<SectionOfCustomData>!
    
    let disposeBag = DisposeBag()
    
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
        
        self.setupCollectionView()
        self.setupView()
        self.setupBindings()
    }
    
    func setupView() {
        backgroundColor = settings.style.backgroundColor
        self.setupCollectionViewLayout()
        self.registerHeaderCell()
        self.registerFooterCell()
        self.registerCollectionViewCell()
    }
    
    fileprivate func setupCollectionView(){
        self.addCollectionView()
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
        collectionViewFlowLayout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: settings.headerStyle.headerReferenceHeight)
        collectionViewFlowLayout.footerReferenceSize = CGSize(width: collectionView.frame.width, height: settings.footerStyle.footerReferenceHeight)
        
        // Setup Cell Size
        let width = (collectionView.frame.width - (settings.style.sectionInset.left + settings.style.sectionInset.right + (CGFloat(settings.itemsSetup.itemsForRows - 1) * settings.itemsSetup.minimumInteritemSpacing))) / CGFloat(settings.itemsSetup.itemsForRows)
        collectionViewFlowLayout.itemSize = CGSize(width: width, height: width * settings.itemsSetup.heightRatio)
        
        // Setup Minimun Spaces
        collectionViewFlowLayout.minimumLineSpacing = settings.itemsSetup.minimumLineSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = settings.itemsSetup.minimumInteritemSpacing
        
        // Setup Edges
        collectionViewFlowLayout.sectionInset = settings.style.sectionInset
    }
    
    fileprivate func registerHeaderCell() {
        let nib = UINib(nibName: self.settings.viewCells.headerViewCellNibName, bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.settings.viewCells.headerViewCellReuseIdentifier)
    }
    
    fileprivate func registerFooterCell() {
        let nib = UINib(nibName: self.settings.viewCells.footerViewCellNibName, bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: self.settings.viewCells.footerViewCellReuseIdentifier)
    }
    
    fileprivate func registerCollectionViewCell() {
        let nib = UINib(nibName: self.settings.viewCells.itemCollectionViewCellNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: self.settings.viewCells.itemCollectionViewCellReuseIdentifier)
    }
    
    fileprivate func setupDataSource() {
        self.dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfCustomData>(configureCell: { (dataSource, collectionView, indexPath, item) in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.settings.viewCells.itemCollectionViewCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
            cell.configure(withValue: item)
            return cell
        })
        
        self.dataSource.configureSupplementaryView = {(dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
            if (kind == UICollectionElementKindSectionHeader) {
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.settings.viewCells.headerViewCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
                header.configure(withValue: dataSource[indexPath.section])
                return header
            } else {
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: self.settings.viewCells.footerViewCellReuseIdentifier, for: indexPath) as! ItemCollectionViewCell
                footer.configure(withValue: dataSource[indexPath.section])
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
                
                if (self.sections.value[indexPath.section].items[indexPath.row].selected || self.settings.data.selectedLimit == nil || selectedItemsCount < self.settings.data.selectedLimit!) {
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
