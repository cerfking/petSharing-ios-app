//
//  UsernameRegistrationViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/22.
//

import UIKit
import Lottie

class UsernameRegistrationViewController: UIViewController {
    
    private let usernameField:UITextField = {
        let usernameField = UITextField()
        usernameField.placeholder = "Email"
        usernameField.returnKeyType = .next
        usernameField.leftViewMode = .always
        usernameField.setLeftView(image: UIImage(systemName: "person.fill")!, tintColor: nil)
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        usernameField.layer.masksToBounds = true
        usernameField.layer.cornerRadius = 8.0
        usernameField.backgroundColor = .secondarySystemBackground
        usernameField.layer.borderWidth = 1.0
        usernameField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return usernameField
    }()
    
    private let passwordField:UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.setLeftView(image: UIImage(systemName: "lock.fill")!,tintColor: nil)
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 8.0
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let registerButton:UIButton = {
        let registerButton = UIButton()
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.masksToBounds = true
        registerButton.layer.cornerRadius = 8.0
        registerButton.backgroundColor = .systemBlue
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return registerButton
    }()
    
    private let animationView:LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named("38435-register")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        return animationView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        usernameField.frame = CGRect(x: 20, y: view.safeAreaInsets.top+210, width: view.width-40, height: 52)
        passwordField.frame = CGRect(x: 20, y: usernameField.top + 70, width: view.width-40, height: 52)
        registerButton.frame = CGRect(x: 20, y: passwordField.top + 70, width: view.width-40, height: 52)
        animationView.frame = CGRect(x: 6, y: 50, width: view.width, height: 220)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Register"
        view.addSubview(usernameField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        view.addSubview(animationView)
        animationView.play()
        usernameField.delegate = self
        passwordField.delegate = self
        view.backgroundColor = .systemBackground

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapRegisterButton(){
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let username = usernameField.text,!username.isEmpty,
              let password = passwordField.text,!password.isEmpty
        else{
            return
        }
        if username.contains("@"),username.contains("."){
            AuthManager.shared.registerNewUserWithUsername(username: username, password: password){ [weak self]
                registered in
                DispatchQueue.main.async {
                    if registered{
                        let successAlert = UIAlertController(title: nil, message: "Successfully resistered", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.present(successAlert, animated: true, completion: nil)
                    }
                    else{
                        let failAlert = UIAlertController(title: "Fail to register", message: "Existed account", preferredStyle: .alert)
                        failAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self?.present(failAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        else{
            let failAlert = UIAlertController(title: "Fail to register", message: "Please type in correct email address", preferredStyle: .alert)
            failAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(failAlert, animated: true, completion: nil)
        }
              
    }
    
}

extension UsernameRegistrationViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField{
            passwordField.becomeFirstResponder()
        }
        else{
            didTapRegisterButton()
        
        }
        return true
    }
    
}
