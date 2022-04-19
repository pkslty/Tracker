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
    @IBOutlet weak var useAvatarSwitch: UISwitch!
    
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
            newUser.useAvatarForTracking = useAvatarSwitch.isOn
            let data = userImage.image?.pngData()
            
            let documentDirectory = FileManager
                .default
                .urls(
                    for: .documentDirectory,
                    in: .userDomainMask)
                .first
            let filePath = documentDirectory!.appendingPathComponent("\(newUser.id.uuidString)").path
            
            
            FileManager.default
                .createFile(atPath: filePath, contents: data, attributes: nil)
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
                self.userId = newUser.id.uuidString
                self.coordinator?.didFinish(with: username)
            }
        }
    }
    
    private func configureUserImage() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapUserImage))
        userImage.isUserInteractionEnabled = true
        userImage.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTapUserImage() {
        showPickerDialog()
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc private func showPickerDialog() {

        let alert = UIAlertController(title: "Выбор изображения", message: "Снять на камеру или выбрать из альбома?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Камера", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Альбом", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {

        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true) { [weak self] in

            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            self?.userImage.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
