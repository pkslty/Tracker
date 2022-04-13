//
//  SceneDelegate.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 19.03.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    var notificationManager: NotificationManager?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            
            notificationManager = NotificationManager()
            
            let navigationController = UINavigationController()
            navigationController.navigationBar.isHidden = true
            appCoordinator = AppCoordinator(navigationController: navigationController)
            appCoordinator?.start(with: nil)
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = navigationController
            window.backgroundColor = .systemBackground
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        self.window?.viewWithTag(1)?.removeFromSuperview()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        if let window = window {
            blurEffectView.frame = window.frame
        }
        blurEffectView.tag = 1
        
        self.window?.addSubview(blurEffectView)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        let minutes: TimeInterval = 0.1
        notificationManager?.makeDelayedNotification(title: "Tracker App",
                                                     subtitle: "Miss you",
                                                     body: "Please get back to track your position",
                                                     delay: minutes * 60)
    }

    
}

