//
//  RegisterCoordinator.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 14.04.2022.
//

import UIKit
import RealmSwift

class RegisterCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator? = nil
    var navigationController: UINavigationController
    var viewController: RegisterViewController?
    var type: CoordinatorType

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.type = .registerCoordinator
    }
    
    func start(with data: Any?) {
        viewController = RegisterViewController.instantiate()
        guard let viewController = viewController else { return }
        viewController.coordinator = self
        if let data = data as? RegisterControllerData {
            viewController.username = data.0
            viewController.realm = data.1
        }
        navigationController.present(viewController, animated: true)
        
        
        if navigationController.viewControllers.count > 1 {
            navigationController.viewControllers.removeFirst()
        }
    }

    func childDidFinish(_ child: Coordinator, with data: Any?) {
    }
    
    func didFinish(with data: Any?) {
        parentCoordinator?.childDidFinish(self, with: data)
    }
}
