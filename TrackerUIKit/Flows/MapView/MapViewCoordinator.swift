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
    
    var viewController: MapViewController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.type = .mapViewCoordinator
    }
    
    func start(with data: Any?) {
        viewController = MapViewController.instantiate()
        guard let viewController = viewController else { return }
        viewController.coordinator = self
        viewController.realm = data as? Realm
        navigationController.pushViewController(viewController, animated: true)
        
        if navigationController.viewControllers.count > 1 {
            navigationController.viewControllers.removeFirst()
        }
    }
    
    func childDidFinish(_ child: Coordinator, with data: Any?) {
        
    }
    
    func didFinish() {
        viewController?.coordinator = nil
        viewController = nil
        parentCoordinator?.childDidFinish(self, with: nil)
    }
}
