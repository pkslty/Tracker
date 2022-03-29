//
//  MapViewCoordinator.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 29.03.2022.
//

import UIKit
import RealmSwift

class MapViewCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var type: CoordinatorType
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.type = .mapViewCoordinator
    }
    
    func start(with data: Any?) {
        let viewController = MapViewController.instantiate()
        viewController.coordinator = self
        viewController.realm = data as? Realm
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator, with data: Any?) {
        
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self, with: nil)
    }
}
