//
//  LoginViewController.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 29.03.2022.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    var coordinator: LoginCoordinator?
    var realm: Realm?
    @UserDefault(key: "userId", defaultValue: nil) var userId: String?
    private var users: Results<User>?
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        users = realm?.objects(User.self)
        
        Observable.combineLatest(loginField.rx.text, passwordField.rx.text)
            .subscribe {
                let isButtonsEnable = !($0?.isEmpty ?? true || $1?.isEmpty ?? true) ? true : false
                self.loginButton.isEnabled = isButtonsEnable
                self.registerButton.isEnabled = isButtonsEnable
            }
            .disposed(by: disposeBag)
        
    }
    @IBAction func didTapLoginButton(_ sender: Any) {
        guard let login = loginField.text,
              let password = passwordField.text else { return }
        let passwordHash = password.MD5()
        let user = users?.first(where: { $0.login == login && $0.passwordHash == passwordHash})
        if let user = user {
            userId = user.id.uuidString
            coordinator?.didFinish(with: userId)
            coordinator = nil
            realm = nil
            users = nil
        } else {
            showAlert("Ошибка!", "Неправильное имя пользователя или пароль", withCancelButton: false, nil)
        }
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        guard let login = loginField.text else { return }
        
        coordinator?.didFinish(with: (login, realm))

    }
}
