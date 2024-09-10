//
//  LoginViewController.swift
//  TakeMeOut
//
//  Created by David Bejenariu on 11.05.2023.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class LoginViewController: UIViewController {
    var users = [User]()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Welcome"
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let instructionsLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Sign in using your account"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
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
    
    let signInButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("Sign in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemMint
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    var googleSignInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        
        button.colorScheme = .dark
        button.style = .wide
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let registerLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Don't have an account?"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let registerButton: UIButton = {
        let button = UIButton()
        
        let attributedText = NSAttributedString(string: "Sign up", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)])
        button.setAttributedTitle(attributedText, for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
        view.backgroundColor = .tertiarySystemBackground
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        signInButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(goToRegister), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
        
        view.addSubview(welcomeLabel)
        view.addSubview(instructionsLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(registerLabel)
        view.addSubview(registerButton)
        view.addSubview(googleSignInButton)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 110),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            instructionsLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10),
            instructionsLabel.centerXAnchor.constraint(equalTo: welcomeLabel.centerXAnchor),
            emailField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 70),
            emailField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            emailField.heightAnchor.constraint(equalToConstant: 45),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            passwordField.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            signInButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 80),
            signInButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            signInButton.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            registerLabel.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 50),
            registerLabel.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            registerLabel.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            registerButton.topAnchor.constraint(equalTo: registerLabel.topAnchor),
            registerButton.leadingAnchor.constraint(equalTo: registerLabel.trailingAnchor, constant: 3),
            registerButton.heightAnchor.constraint(equalTo: emailField.heightAnchor),
            googleSignInButton.topAnchor.constraint(equalTo: registerLabel.bottomAnchor, constant: 10),
            googleSignInButton.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            googleSignInButton.trailingAnchor.constraint(equalTo: emailField.trailingAnchor)
        ])
    }
    
    @objc func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { [self] result, error in
                // At this point, our user is signed in
                let user = DataManager.shared.getUser(email: (result?.user.email)!)
                
                if user == nil {
                    let userData = DataManager.shared.user(fullName: (result?.user.displayName)!, email: (result?.user.email)!)
                    self.users.append(userData)
                    DataManager.shared.save()
                }
                
                var currentUser = Auth.auth().currentUser
                while currentUser == nil {
                    currentUser = Auth.auth().currentUser
                }
                
                navigationController?.pushViewController(MainViewController(), animated: true)
            }
        }
    }
    
    @objc func goToRegister(sender: UIButton!) {
        let registerViewController = RegisterViewController()
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @objc func loginUser(sender: UIButton!) {
        view.endEditing(true)
        
        Auth.auth().fetchSignInMethods(forEmail: emailField.text!) { [self] signInMethods, error in
            if error != nil {
                let alert = UIAlertController(title: "Error signing in", message: "Invalid email and password combination.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                present(alert, animated: true)
                return
            }
            
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { [self] authResult, error in
                if error != nil {
                    let alert = UIAlertController(title: "Error signing in", message: "Invalid email and password combination.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    present(alert, animated: true)
                    return
                }
                
                // Login successful
                var currentUser = Auth.auth().currentUser
                
                while currentUser == nil {
                    currentUser = Auth.auth().currentUser
                }
                
                navigationController?.pushViewController(MainViewController(), animated: true)
            }
        }
    }
}
