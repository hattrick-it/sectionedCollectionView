//
//  AppCoordinator.swift
//  SectionedCollectionView
//
//  Created by Esteban Arrua on 6/8/18.
//  Copyright © 2018 Hattrick. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class AppCoordinator: BaseCoordinator<Void> {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() -> Observable<Void> {
        let viewController = SectionedCollectionViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        return Observable.never()
    }
    
}
