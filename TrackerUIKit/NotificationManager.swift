//
//  NotificationManager.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 13.04.2022.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    private var center: UNUserNotificationCenter?
    
    init() {
        self.center = UNUserNotificationCenter.current()
        center?.requestAuthorization(options: [.alert, .badge]) { granted, error in
            if granted {
                print("Notifications granted")
            }
            else {
                print("Notifications not granted")
            }
        }
    }
    
    func removeNotification(identifier: [String]) {
        center?.removePendingNotificationRequests(withIdentifiers: identifier)
    }
    
    func removeAllNotifications() {
        center?.removeAllPendingNotificationRequests()
    }
    
    func makeDelayedNotification(title: String?,
                                 subtitle: String? = nil,
                                 body: String? = nil,
                                 delay: TimeInterval,
                                 repeats: Bool = false,
                                 completion: ((String?) -> Void)? = nil) {
        
        center?.getNotificationSettings { [weak self] in
            guard let self = self else { return }
            guard $0.authorizationStatus == .authorized else {
                completion?(nil)
                return
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: repeats)
            let content = self.makeNotificationContent(title: title ?? "",
                                                  subtitle: subtitle ?? "",
                                                  body: body ?? "")
            let identifier: String? = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier ?? "", content: content, trigger: trigger)
            self.center?.add(request) { error in
                if let error = error {
                    print("Error sending notification: \(error.localizedDescription)")
                    completion?(nil)
                } else {
                    completion?(identifier)
                }
            }
        }
    }
    
    private func makeNotificationContent(title: String, subtitle: String, body: String) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        
        return content
    }
}
