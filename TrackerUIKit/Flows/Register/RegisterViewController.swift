//
//  RegisterViewController.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 14.04.2022.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController, Storyboarded {

    var coordinator: RegisterCoordinator?
    var realm: Realm?
    @UserDefault(key: "userId", defaultValue: nil) var userId: String?
    var username: String?
    var users: Results<User>?
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        users = realm?.objects(User.self)
        userNameField.text = username
        self.navigationController?.navigationBar.isHidden = false
        
        configureUserImage()
        
        Observable.combineLatest(userNameField.rx.text, passwordField.rx.text)
            .subscribe {
                let isButtonsEnable = !($0?.isEmpty ?? true || $1?.isEmpty ?? true) ? true : false
                self.registerButton.isEnabled = isButtonsEnable
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func didTapRegisterButton(_ sender: Any) {
        guard let username = userNameField.text,
              let password = passwordField.text else { return }
        
        
        let user = users?.first(where: { $0.login == username })
        if let _ = user {
            showAlert("Ошибка!", "пользователь с таким именем уже существует", withCancelButton: false, nil)
            return
        } else {
            let newUser = User()
            newUser.login = username
            newUser.passwordHash = password.MD5()
            newUser.name = username
            newUser.id = UUID()
            newUser.userImageData = userImage.image?.pngData()
            do {
                try realm?.write {
                    realm?.add(newUser)
                }
            }
            catch {
                showAlert("Ошибка!", "Что-то пошло не так. Не могу сохранить полльзователя в базу данных", withCancelButton: false, nil)
            }
            showAlert("Поздравляю!", "Пользователь успешно зарегистрирован", withCancelButton: false) { [weak self] _ in
                guard let self = self else { return }
                self.userNameField.text = ""
                self.passwordField.text = ""
                self.dismiss(animated: true)
                self.coordinator?.didFinish(with: username)
            }
        }
    }
    
    private func configureUserImage() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUserImage))
        userImage.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTapUserImage() {
        let data = userImage.image?.pngData()
        print(data)
    }
}
