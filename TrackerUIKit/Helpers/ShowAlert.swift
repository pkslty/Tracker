//
//  ShowAlert.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 24.03.2022.
//

import UIKit

extension UIViewController {
    func showAlert(_ title: String?,_ message: String?, withCancelButton: Bool = true, _ okCompletion: ((UIAlertAction) -> Void)?, _ cancelCompletion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                     message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: okCompletion))
        if withCancelButton {
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: cancelCompletion))
        }
        present(alert, animated: true, completion: nil)
    }
}
