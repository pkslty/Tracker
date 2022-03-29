//
//  AppCoordinator.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 29.03.2022.
//

import UIKit
import RealmSwift

class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var type: CoordinatorType = .appCoordinator
    
    @UserDefault(key: "userId", defaultValue: nil) var userId: String?
    var realm: Realm?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(with data: Any?) {
        configureRealm()
        guard realm != nil else {
            let coordinator = MapViewCoordinator(navigationController: navigationController)
            childCoordinators.append(coordinator)
            coordinator.parentCoordinator = self
            coordinator.start(with: nil)
            return
        }
        if let userId = userId,
           let _ = realm?.objects(User.self).first(where: { $0.id.uuidString == userId }) {
            let coordinator = MapViewCoordinator(navigationController: navigationController)
            childCoordinators.append(coordinator)
            coordinator.parentCoordinator = self
            coordinator.start(with: realm)
        } else {
            self.userId = nil
            let coordinator = LoginCoordinator(navigationController: navigationController)
            childCoordinators.append(coordinator)
            coordinator.parentCoordinator = self
            coordinator.start(with: realm)
        }
    }
    
    func childDidFinish(_ child: Coordinator, with data: Any?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
            }
        }
        switch child.type {
        case .loginCoordinator:
            let newChild = MapViewCoordinator(navigationController: navigationController)
            childCoordinators.append(newChild)
            newChild.parentCoordinator = self
            newChild.start(with: realm)
        case .mapViewCoordinator:
            userId = nil
            let newChild = LoginCoordinator(navigationController: navigationController)
            childCoordinators.append(newChild)
            newChild.parentCoordinator = self
            newChild.start(with: realm)
        default: break
        }
    }
    
    private func configureRealm() {
        do {
            realm = try Realm()
        }
        catch {
            print("Realm open error")
        }
    }
   
}
