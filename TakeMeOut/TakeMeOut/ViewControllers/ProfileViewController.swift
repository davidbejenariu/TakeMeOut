//
//  ProfileViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 14.05.2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class ProfileViewController: UIViewController {
    weak var owner: SearchViewController?
    
    let closeButton: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "xmark.circle.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemGray])
        config.applying(UIImage.SymbolConfiguration(font: .systemFont(ofSize: 30)))
        imageView.preferredSymbolConfiguration = config
        
        return imageView
    }()
    
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(systemName: "person.circle.fill")
        let config = UIImage.SymbolConfiguration(paletteColors: [.label])
        config.applying(UIImage.SymbolConfiguration(weight: .bold))
        imageView.preferredSymbolConfiguration = config
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let logoutButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    // MARK: make panel not dismissible
    override func viewDidLoad() {
        super.viewDidLoad()

        owner?.owner?.panel.surfaceView.grabberHandle.removeFromSuperview()
        
        view.backgroundColor = .tertiarySystemBackground
        view.addSubview(closeButton)
        view.addSubview(logoutButton)
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        
        if Auth.auth().currentUser != nil {
            let currentUser = DataManager.shared.getUser(email: (Auth.auth().currentUser?.email)!)
            
            if currentUser != nil {
                nameLabel.text = currentUser?.fullName
                nameLabel.numberOfLines = 0
                nameLabel.lineBreakMode = .byWordWrapping
                
                emailLabel.text = currentUser?.email
                emailLabel.numberOfLines = 0
                emailLabel.lineBreakMode = .byWordWrapping
                
                if currentUser?.profileImage != nil {
                    profileImage.image = UIImage(data: (currentUser?.profileImage)!)
                }
            }
        }
        
        let profilePictureTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(changeProfilePicture)
        )
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(profilePictureTapGesture)
        
        let closeButtonTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(goToMainView)
        )
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(closeButtonTapGesture)
        
        logoutButton.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 85),
            nameLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75),
            nameLabel.heightAnchor.constraint(equalToConstant: (nameLabel.text?.height(withConstrainedWidth: nameLabel.frame.width, font: nameLabel.font))!),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75),
            emailLabel.heightAnchor.constraint(equalToConstant: (emailLabel.text?.height(withConstrainedWidth: emailLabel.frame.width, font: emailLabel.font))!),
            logoutButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 20),
            logoutButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            logoutButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        profileImage.frame = CGRect(x: view.safeAreaLayoutGuide.layoutFrame.origin.x + 20, y: view.safeAreaLayoutGuide.layoutFrame.origin.y + 20, width: 50, height: 50)
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
    }
    
    @objc func changeProfilePicture() {
        presentPhotoPicker()
    }
    
    @objc func goToMainView(sender: UIButton!) {
        owner?.favouritesVC.loadFavourites()
        owner?.owner?.panel.removePanelFromParent(animated: false)
        owner?.owner?.setSearchPanel()
        owner?.owner?.panel.layout = PanelPortraitLayout()
        owner?.owner?.panel.move(to: .half, animated: true)
    }
    
    @objc func logoutUser(sender: UIButton!) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
        
        let loginViewController = LoginViewController()
        navigationController?.pushViewController(loginViewController, animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImage.image = editedImage
            owner?.owner?.profileImage.image = editedImage
            
            if Auth.auth().currentUser != nil {
                let currentUser = DataManager.shared.getUser(email: (Auth.auth().currentUser?.email)!)
                
                if currentUser != nil {
                    let jpegImageData = editedImage.jpegData(compressionQuality: 1.0)
                    DataManager.shared.updateProfileImage(profileImage: jpegImageData!, user: currentUser!)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
