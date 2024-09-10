//
//  RegisterViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 11.05.2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import CoreData

class RegisterViewController: UIViewController, UIScrollViewDelegate {
    var users = [User]()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Welcome"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let instructionsLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Create an account"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let fullNameField: UITextField = {
        let field = UITextField()
        
        field.placeholder = "Full name"
        field.font = .systemFont(ofSize: 20)
        field.textColor = .tertiaryLabel
        field.backgroundColor = .secondarySystemBackground
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    let fullNameNotValidLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Enter a valid full name."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let emailField: UITextField = {
        let field = UITextField()
        
        field.placeholder = "Email"
        field.font = .systemFont(ofSize: 20)
        field.textColor = .tertiaryLabel
        field.backgroundColor = .secondarySystemBackground
        field.borderStyle = .roundedRect
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    let emailNotValidLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Enter a valid email."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let passwordField: UITextField = {
        let field = UITextField()
        
        field.placeholder = "Password"
        field.font = .systemFont(ofSize: 20)
        field.textColor = .tertiaryLabel
        field.backgroundColor = .secondarySystemBackground
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    let passwordNotValidLabel: UILabel = {
        let label = UILabel()
        
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let confirmPasswordField: UITextField = {
        let field = UITextField()
        
        field.placeholder = "Confirm password"
        field.font = .systemFont(ofSize: 20)
        field.textColor = .tertiaryLabel
        field.backgroundColor = .secondarySystemBackground
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let backToLoginButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("< Back to login", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var isFullNameValid: Bool = false
    var isEmailValid: Bool = false
    var isPasswordValid: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        view.backgroundColor = .tertiarySystemBackground
        
        fullNameField.addTarget(self, action: #selector(fullNameFieldEditingDidEnd), for: .editingDidEnd)
        emailField.addTarget(self, action: #selector(emailFieldEditingDidEnd), for: .editingDidEnd)
        passwordField.addTarget(self, action: #selector(passwordFieldEditingDidEnd), for: .editingDidEnd)
        confirmPasswordField.addTarget(self, action: #selector(passwordFieldEditingDidEnd), for: .editingDidEnd)
        
        backToLoginButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(createUser), for: .touchUpInside)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(goToLogin))
        swipeLeft.direction = .right
        view.addGestureRecognizer(swipeLeft)
        
        fullNameNotValidLabel.numberOfLines = 0
        fullNameNotValidLabel.lineBreakMode = .byWordWrapping
        emailNotValidLabel.numberOfLines = 0
        emailNotValidLabel.lineBreakMode = .byWordWrapping
        passwordNotValidLabel.numberOfLines = 0
        passwordNotValidLabel.lineBreakMode = .byWordWrapping
        
        fullNameNotValidLabel.isHidden = true
        emailNotValidLabel.isHidden = true
        passwordNotValidLabel.isHidden = true
        
        view.addSubview(welcomeLabel)
        view.addSubview(instructionsLabel)
        view.addSubview(fullNameField)
        view.addSubview(fullNameNotValidLabel)
        view.addSubview(emailField)
        view.addSubview(emailNotValidLabel)
        view.addSubview(passwordField)
        view.addSubview(confirmPasswordField)
        view.addSubview(passwordNotValidLabel)
        view.addSubview(registerButton)
        view.addSubview(backToLoginButton)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            instructionsLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            fullNameField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 70),
            fullNameField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            fullNameField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            fullNameField.heightAnchor.constraint(equalToConstant: 45),
            fullNameNotValidLabel.topAnchor.constraint(equalTo: fullNameField.bottomAnchor, constant: 2),
            fullNameNotValidLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 35),
            fullNameNotValidLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
            emailField.topAnchor.constraint(equalTo: fullNameNotValidLabel.bottomAnchor, constant: 5),
            emailField.leadingAnchor.constraint(equalTo: fullNameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: fullNameField.trailingAnchor),
            emailField.heightAnchor.constraint(equalTo: fullNameField.heightAnchor),
            emailNotValidLabel.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 2),
            emailNotValidLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 35),
            emailNotValidLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
            passwordField.topAnchor.constraint(equalTo: emailNotValidLabel.bottomAnchor, constant: 5),
            passwordField.leadingAnchor.constraint(equalTo: fullNameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: fullNameField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalTo: fullNameField.heightAnchor),
            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 25),
            confirmPasswordField.leadingAnchor.constraint(equalTo: fullNameField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: fullNameField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalTo: fullNameField.heightAnchor),
            passwordNotValidLabel.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 2),
            passwordNotValidLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 35),
            passwordNotValidLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -35),
            registerButton.topAnchor.constraint(equalTo: passwordNotValidLabel.bottomAnchor, constant: 80),
            registerButton.leadingAnchor.constraint(equalTo: fullNameField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: fullNameField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalTo: fullNameField.heightAnchor),
            backToLoginButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            backToLoginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backToLoginButton.heightAnchor.constraint(equalTo: fullNameField.heightAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @objc func fullNameFieldEditingDidEnd() {
        if !isFullNameValid(fullNameField.text!) {
            fullNameNotValidLabel.isHidden = false
            isFullNameValid = false
        } else {
            fullNameNotValidLabel.isHidden = true
            isFullNameValid = true
        }
    }
    
    @objc func emailFieldEditingDidEnd() {
        if !isEmailValid(emailField.text!) {
            emailNotValidLabel.isHidden = false
            isEmailValid = false
        } else {
            emailNotValidLabel.isHidden = true
            isEmailValid = true
        }
    }
    
    @objc func passwordFieldEditingDidEnd() {
        if !isPasswordValid(passwordField.text!) {
            passwordNotValidLabel.text = "Password should contain at least 8 characters, a digit, a lowercase letter, an uppercase letter and a special character (^#$@!%*?&)."
            passwordNotValidLabel.isHidden = false
            isPasswordValid = false
        } else if passwordField.text! != confirmPasswordField.text! {
            passwordNotValidLabel.text = "Passwords don't match."
            passwordNotValidLabel.isHidden = false
            isPasswordValid = false
        } else {
            passwordNotValidLabel.isHidden = true
            isPasswordValid = true
        }
    }
    
    @objc func goToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createUser(sender: UIButton!) {
        view.endEditing(true)
        
        if isFullNameValid && isEmailValid && isPasswordValid {
            Auth.auth().fetchSignInMethods(forEmail: emailField.text!) { [self] signInMethods, error in
                if let error = error {
                    print(error)
                }
                
                if let signInMethods = signInMethods, !signInMethods.isEmpty {
                    // Email already exists
                    let alert = UIAlertController(title: "Error creating an account", message: "User with given email address already exists.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    present(alert, animated: true)
                } else {
                    // Email doesn't exist
                    Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!)
                    Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!)
                    
                    let user = DataManager.shared.user(fullName: fullNameField.text!, email: emailField.text!)
                    users.append(user)
                    DataManager.shared.save()
                    
                    var currentUser = Auth.auth().currentUser
                    while currentUser == nil {
                        currentUser = Auth.auth().currentUser
                    }
                    
                    navigationController?.pushViewController(MainViewController(), animated: true)
                }
            }
        }
    }
    
    func isFullNameValid(_ fullName: String) -> Bool {
        let fullNameRegex = "^[a-zA-Z\\p{L}]+([ '-][a-zA-Z\\p{L}]+)*$"
        let fullNamePredicate = NSPredicate(format: "SELF MATCHES %@", fullNameRegex)
        
        return fullNamePredicate.evaluate(with: fullName)
    }
    
    func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[^#$@$!%*?&])[A-Za-z\\d^#$@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        return passwordPredicate.evaluate(with: password)
    }
}
