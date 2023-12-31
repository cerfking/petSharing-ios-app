//
//  NumberRegisterViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/23.
//

import UIKit
import Lottie
import LeanCloud


class NumberRegisterViewController: UIViewController {
    private let phoneNumberField:UITextField! = {
        let phoneNumberField = UITextField()
        phoneNumberField.placeholder = " Phone number"
        phoneNumberField.leftViewMode = .always
        phoneNumberField.setLeftView(image: UIImage(systemName: "phone.fill")!, tintColor: nil)
        phoneNumberField.keyboardType = .numberPad
        phoneNumberField.layer.masksToBounds = true
        phoneNumberField.layer.cornerRadius = 8.0
        phoneNumberField.backgroundColor = .secondarySystemBackground
        phoneNumberField.layer.borderWidth = 1.0
        phoneNumberField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return phoneNumberField
    }()
    
    private let nextStepButton:UIButton = {
        let nextStepButton = UIButton()
        nextStepButton.setTitle("Next", for: .normal)
        nextStepButton.layer.masksToBounds = true
        nextStepButton.layer.cornerRadius = 8.0
        nextStepButton.backgroundColor = .systemGray
        nextStepButton.setTitleColor(.white, for: .normal)
        return nextStepButton
    }()
    
    private let animationView:LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named("38435-register")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        return animationView
    }()
    
   // public var completion:((String?) -> Void)?
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        animationView.frame = CGRect(x: 6, y: 50, width: view.width, height: 220)
     
        phoneNumberField.frame = CGRect(x: 25,y: 270.0,width: view.width-50,height: 52.0)
        
        nextStepButton.frame = CGRect(x: 25,y: 340,width: view.width - 50,height: 52.0)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Register"
        view.backgroundColor = .systemBackground
        view.addSubview(phoneNumberField)
        view.addSubview(nextStepButton)
        view.addSubview(animationView)
        animationView.play()
        phoneNumberField.delegate = self
        nextStepButton.addTarget(self, action: #selector(didTapNextStepButton), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapNextStepButton(){
        guard let _ = phoneNumberField.text else {
            //测试用，需更改为错误提示界面
            print("请输入手机号")
            return
        }
//        guard phoneNumberField.text!.count == 11 else {
//            //测试用，需更改为错误提示界面
//            print("请输入正确的11位手机号")
//            return
//        }
        _ = LCSMSClient.requestShortMessage(mobilePhoneNumber: phoneNumberField.text!){ [weak self] (result) in
            switch result {
            case .success:
                let vc = UINavigationController(rootViewController: EnterVerifyCodeToLoginViewController(mobilePhoneNumber: (self?.phoneNumberField.text)!)) //测试
                self?.present(vc, animated: true, completion: nil) //测试
                 print("发送成功")
                 break
            case .failure(error: let error):
                 print(error)
            }
         }
    }
  

}
extension NumberRegisterViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        if updateText.count == 11 {
            nextStepButton.backgroundColor = .systemBlue
        }
        else {
            nextStepButton.backgroundColor = .systemGray
        }
        return updateText.count <= 12
    }
}
