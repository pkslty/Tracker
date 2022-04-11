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
    var users: Results<User>?

    override func viewDidLoad() {
        super.viewDidLoad()
        users = realm?.objects(User.self)
        
        let observerable = Observable.combineLatest(loginField.rx.text, passwordField.rx.text)
            .subscribe {
                let isButtonsEnable = !($0?.isEmpty ?? true || $1?.isEmpty ?? true) ? true : false
                self.loginButton.isEnabled = isButtonsEnable
                self.registerButton.isEnabled = isButtonsEnable
            }
        
    }
    @IBAction func didTapLoginButton(_ sender: Any) {
        guard !isFieldsEpty() else { return }
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
        guard !isFieldsEpty() else { return }
        guard let login = loginField.text,
              let password = passwordField.text else { return }
        let user = users?.first(where: { $0.login == login })
        if let _ = user {
            showAlert("Ошибка!", "gользователь с таким имененм уже существует", withCancelButton: false, nil)
            return
        } else {
            let newUser = User()
            newUser.login = login
            newUser.passwordHash = password.MD5()
            newUser.name = login
            newUser.id = UUID()
            do {
                try realm?.write {
                    realm?.add(newUser)
                }
            }
            catch {
                showAlert("Ошибка!", "Что-то пошло не так. Не могу сохранить полльзователя в базу данных", withCancelButton: false, nil)
            }
            showAlert("Поздравляю!", "Пользователь успешно зарегистрирован", withCancelButton: false, nil)
            loginField.text = ""
            passwordField.text = ""
        }
    }
    
    private func isFieldsEpty() -> Bool {
        if loginField.text?.isEmpty ?? true || passwordField.text?.isEmpty ?? true {
            showAlert("Ошибка!", "Поля Имя пользователя и Пароль не могут быть пустыми", withCancelButton: false, nil)
            return true
        }
        return false
    }
}
