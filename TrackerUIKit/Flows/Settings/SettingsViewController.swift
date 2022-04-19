//
//  SettingsViewController.swift
//  TrackerUIKit
//
//  Created by Denis Kuzmin on 18.04.2022.
//

import UIKit
import RealmSwift

class SettingsViewController: UIViewController, Storyboarded {

    var coordinator: SettingsCoordinator?
    var realm: Realm?
    @UserDefault(key: "userId", defaultValue: nil) var userId: String?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var useAvatarSwitch: UISwitch!
    @IBOutlet weak var userImage: UIImageView!
    
    private var users: Results<User>?
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        let data = userImage.image?.pngData()
        
        let documentDirectory = FileManager
            .default
            .urls(
                for: .documentDirectory,
                in: .userDomainMask)
            .first
        
        if let user = user, let filePath = documentDirectory?.appendingPathComponent("\(user.id.uuidString)").path {
            FileManager.default
                .createFile(atPath: filePath, contents: data, attributes: nil)
        }
        
        do {
            if let password = passwordField.text {
                try realm?.write {
                    user?.useAvatarForTracking = useAvatarSwitch.isOn
                    if !password.isEmpty {
                        user?.passwordHash = password.MD5()
                    }
                }
            }
        }
        catch {
            showAlert("Ошибка!", "Что-то пошло не так. Не могу сохранить пользователя в базу данных", withCancelButton: false, nil)
        }
        self.dismiss(animated: true)
        coordinator?.didFinish()
    }
    
    private func configureView() {
        usernameField.isUserInteractionEnabled = false
        if let userId = userId, let realm = realm, let id = UUID(uuidString: userId) {
            users = realm.objects(User.self)
            user = users?.first(where: { $0.id == id })
            if let user = user {
                usernameField.text = user.login
                useAvatarSwitch.isOn = user.useAvatarForTracking
            }
            let documentDirectory = FileManager
                .default
                .urls(
                    for: .documentDirectory,
                    in: .userDomainMask)
                .first
            
            if let filePath = documentDirectory?.appendingPathComponent("\(userId)").path, let image = UIImage(contentsOfFile: filePath) {
                userImage.image = image
            }
        }
        configureUserImage()
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

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
