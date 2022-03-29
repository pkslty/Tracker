//
//  LoginCoordinator.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 29.03.2022.
//

import UIKit
import RealmSwift

class LoginCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var type: CoordinatorType
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.type = .loginCoordinator
    }
    
    func start(with data: Any?) {
        let viewController = LoginViewController.instantiate()
        viewController.coordinator = self
        viewController.realm = data as? Realm
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator, with data: Any?) {
        
    }
    
    func didFinish(with data: Any?) {
        parentCoordinator?.childDidFinish(self, with: data)
    }
}
