//
//  LoginViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/22.
//

import UIKit
import Lottie
import LeanCloud
import TransitionButton

class LoginViewController: UIViewController {
    private let usernameEmailField:UITextField = {
        let usernameEmailField = UITextField()
        usernameEmailField.placeholder = " Email"
        usernameEmailField.returnKeyType = .next
        usernameEmailField.leftViewMode = .always
        usernameEmailField.setLeftView(image: UIImage(systemName: "person.fill")!, tintColor: nil)
        usernameEmailField.autocapitalizationType = .none //关闭自动大写
        usernameEmailField.autocorrectionType = .no //关闭自动纠错
        usernameEmailField.layer.masksToBounds = true
        usernameEmailField.layer.cornerRadius = 8.0
        usernameEmailField.backgroundColor = .secondarySystemBackground
        usernameEmailField.layer.borderWidth = 1.0
        usernameEmailField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return usernameEmailField
    }()
    
    private let passwordField:UITextField = {
        let passwordField = UITextField()
        passwordField.isSecureTextEntry = true
        passwordField.placeholder = " Password"
        passwordField.returnKeyType = .continue
        passwordField.leftViewMode = .always
        passwordField.setLeftView(image: UIImage(systemName: "lock.fill")!, tintColor: nil)
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.layer.masksToBounds = true
        passwordField.layer.cornerRadius = 8.0
        passwordField.backgroundColor = .secondarySystemBackground
        passwordField.layer.borderWidth = 1.0
        passwordField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return passwordField
    }()
    
    
    private let button:TransitionButton = {
        let button = TransitionButton()
        button.setTitle("Log In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8.0
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapLoginButton), for: UIControl.Event.touchUpInside)
        button.spinnerColor = .white
        return button
    }()
    
    
    private let loginWithMobileNumberButton:UIButton = {
        let loginWithMobileNumberButton = UIButton()
        loginWithMobileNumberButton.setTitle("Phone", for: .normal)
        loginWithMobileNumberButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        loginWithMobileNumberButton.setTitleColor(.black, for: .normal)
        loginWithMobileNumberButton.setTitleColor(.gray, for: .highlighted)
        loginWithMobileNumberButton.addTarget(self, action: #selector(didTapLoginWithMobileNumberButton), for: .touchUpInside)
        return loginWithMobileNumberButton
    }()
    
    private let findPasswordButton:UIButton = {
        let findPasswordButton = UIButton()
        findPasswordButton.setTitle("Forgot Password", for: .normal)
        findPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        findPasswordButton.setTitleColor(.black, for: UIControl.State.normal)
        findPasswordButton.setTitleColor(.gray, for: .highlighted)
        findPasswordButton.addTarget(self, action: #selector(didTapFindPasswordButton), for: .touchUpInside)
        return findPasswordButton
    }()
    
    private let newUserRegisterButton:UIButton = {
        let newUserRegisterButton = UIButton()
        newUserRegisterButton.setTitle("Register", for: .normal)
        newUserRegisterButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        newUserRegisterButton.setTitleColor(.black, for: .normal)
        newUserRegisterButton.setTitleColor(.gray, for: .highlighted)
        newUserRegisterButton.addTarget(self, action: #selector(didTapNewUserRegisterButton), for: UIControl.Event.touchUpInside)
        return newUserRegisterButton
    }()
    
    private let headerView:UIImageView = {
        let headerView = UIImageView()
        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFit
        headerView.image = UIImage(named: "petSharing")
        return headerView
    }()
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(
            x: 0,
            y: 60,
            width: view.width-10,
            height: view.height/3.0
        )
        usernameEmailField.frame = CGRect(
            x: 25,
            y: 360.0  ,
            width: view.width-50,
            height: 52.0
        )
        passwordField.frame = CGRect(
            x: 25,
            y: 430,
            width: view.width - 50,
            height: 52.0
        )
        button.frame = CGRect(
            x: 25,
            y: 500,
            width: view.width - 50,
            height: 52.0)
        findPasswordButton.frame = CGRect(
            x: 20,
            y: 750,
            width: (view.width-20)/3,
            height: 50)
//        findPasswordButton.frame = CGRect(
//            x: 10+(view.width-20)/3,
//            y: 750,
//            width: (view.width-20)/3,
//            height: 50)
        newUserRegisterButton.frame = CGRect(
            x: 10+(view.width-20)/3*2,
            y: 750,
            width: (view.width-20)/3,
            height: 50)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        usernameEmailField.delegate = self
        passwordField.delegate = self
        view.addSubview(usernameEmailField)
        view.addSubview(passwordField)
        view.addSubview(headerView)
        //view.addSubview(loginWithMobileNumberButton)
        view.addSubview(findPasswordButton)
        view.addSubview(newUserRegisterButton)
        view.addSubview(button)
    }
    @objc func didTapNewUserRegisterButton(){
//        let alertController = UIAlertController(title: nil, message: "Choose a registration method", preferredStyle: .actionSheet)
//        let alertAction1 = UIAlertAction(title: "Register with Email", style: .default){[weak self] (action) in
//            let vc = UINavigationController(rootViewController: UsernameRegistrationViewController())
//            vc.navigationItem.largeTitleDisplayMode = .never
//            self?.present(vc, animated: true, completion: nil)
//            
//        }
//        let alertAction2 = UIAlertAction(title: "Register with phone number", style: .default){[weak self] (action) in
//            let vc = UINavigationController(rootViewController: NumberRegisterViewController())
//            self?.present(vc, animated: true, completion: nil)
//            
//        }
//        let alertAction3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(alertAction1)
//        alertController.addAction(alertAction2)
//        alertController.addAction(alertAction3)
//        present(alertController, animated: true, completion: nil)
        let vc = UINavigationController(rootViewController:UsernameRegistrationViewController())
        vc.navigationItem.largeTitleDisplayMode = .never
        self.present(vc, animated: true, completion: nil)
    }

    @objc func didTapLoginWithMobileNumberButton(){
        let vc = UINavigationController(rootViewController: NumberLoginViewController())
        present(vc, animated: true, completion: nil)
    }
    @objc func didTapFindPasswordButton(){
        let vc = UINavigationController(rootViewController: FindPasswordViewController())
        present(vc, animated: true, completion: nil)
    }
    @objc func didTapLoginButton(){
        usernameEmailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let usernameEmail = usernameEmailField.text,!usernameEmail.isEmpty,
              let password = passwordField.text,!password.isEmpty else {
            return
        }
        button.startAnimation()

        AuthManager.shared.loginWithUsername(username: usernameEmail, password: password){ [weak self]
            success in
            DispatchQueue.main.async {
                if success{
                    //登陆成功
                    self?.button.stopAnimation(animationStyle: .normal, revertAfterDelay: 1)
                    do {
                        client = try IMClient(user: LCApplication.default.currentUser!)
                        client?.open { (result) in
                            client?.delegate = Delegator.delegator
                        }
                    } catch {
                        print(error)
                    }
                    let tabBarVC = UITabBarController()
                    //tabBarVC.tabBar.isTranslucent = false
            
                    let vc1 = UINavigationController(rootViewController: HomeViewController())
                    vc1.title = "Home"
                    vc1.tabBarItem.image = UIImage(systemName: "house")
                    let vc2 = UINavigationController(rootViewController: ClubViewController())
                    vc2.title = "Club"
                    vc2.tabBarItem.image = UIImage(systemName: "flag")
                    let vc3 = UINavigationController(rootViewController: TransactionViewController())
                    vc3.title = "Adapt"
                    vc3.tabBarItem.image = UIImage(systemName: "bag")
                    let vc4 = UINavigationController(rootViewController: ConversationsViewController())
                    vc4.title = "Message"
                    vc4.tabBarItem.image = UIImage(systemName: "envelope")
                    let vc5 = UINavigationController(rootViewController: MeViewController())
                    vc5.title = "Me"
                    vc5.tabBarItem.image = UIImage(systemName: "person")
                    
                    
                    tabBarVC.setViewControllers([vc1,vc2,vc3,vc4,vc5], animated: false)
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self?.present(tabBarVC, animated: true)
                    
                    //self?.dismiss(animated: true, completion: nil)
        
                }
                else{
                    //登陆失败
                    self?.button.stopAnimation(animationStyle: .shake, revertAfterDelay: 0)
                    let failAlert = UIAlertController(title: "Fail to log in", message: "Incorrect password!", preferredStyle: .alert)
                    failAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self?.present(failAlert, animated: true, completion: nil)
                    
                }
            }
        }
        
        
    }
    
    
    
}

extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameEmailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            passwordField.resignFirstResponder()
        }
        return true
    }
    
}
