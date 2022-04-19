//
//  SettingsCoordinator.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 18.04.2022.
//

import UIKit
import RealmSwift

class SettingsCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var viewController: SettingsViewController?
    var type: CoordinatorType
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.type = .settingsCoordinator
    }
    
    func start(with data: Any?) {
        viewController = SettingsViewController.instantiate()
        guard let viewController = viewController else { return }
        viewController.coordinator = self
        viewController.realm = data as? Realm
        navigationController.present(viewController, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator, with data: Any?) {
        
    }
    
    func didFinish() {
        parentCoordinator?.childDidFinish(self, with: nil)
    }
    
}
