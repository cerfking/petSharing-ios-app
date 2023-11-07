//
//  FindPasswordViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/23.
//

import UIKit
import Lottie

class FindPasswordViewController: UIViewController {
    private let accountField:UITextField = {
        let accountField = UITextField()
        accountField.placeholder = "手机号/邮箱"
        accountField.leftViewMode = .always
        accountField.setLeftView(image: UIImage(systemName: "person.fill")!,tintColor: nil)
        accountField.autocapitalizationType = .none
        accountField.autocorrectionType = .no
        accountField.layer.masksToBounds = true
        accountField.layer.cornerRadius = 8.0
        accountField.backgroundColor = .secondarySystemBackground
        accountField.layer.borderWidth = 1.0
        accountField.layer.borderColor = UIColor.secondaryLabel.cgColor
        return accountField
    }()
    
    private let nextStepButton:UIButton = {
        let nextStepButton = UIButton()
        nextStepButton.setTitle("下一步", for: .normal)
        nextStepButton.layer.masksToBounds = true
        nextStepButton.layer.cornerRadius = 8.0
        nextStepButton.backgroundColor = .systemGray
        nextStepButton.setTitleColor(.white, for: .normal)
        return nextStepButton
    }()
    
    private let animationView:LottieAnimationView = {
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named("5451-search-file")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        return animationView
    }()
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        animationView.frame = CGRect(x: 6, y: 60, width: view.width, height: 220)
     
        accountField.frame = CGRect(
            x: 25,
            y: 280.0  ,
            width: view.width-50,
            height: 52.0
        )
        nextStepButton.frame = CGRect(
            x: 25,
            y: 350,
            width: view.width - 50,
            height: 52.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "找回密码"
        view.backgroundColor = .systemBackground
        view.addSubview(accountField)
        view.addSubview(nextStepButton)
        view.addSubview(animationView)
        animationView.play()
        accountField.delegate = self
        nextStepButton.addTarget(self, action: #selector(didTapNextStepButtonFalse), for: .touchUpInside)

        // Do any additional setup after loading the view.
    }
    @objc func didTapNextStepButtonFalse(){
        print("请输入正确账号")
    }
    @objc func didTapNextStepButtonTrue(){
        print("正确")
    }
}

extension FindPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        if updateText.count >= 1 {
            nextStepButton.backgroundColor = .systemBlue
            nextStepButton.removeTarget(self, action: #selector(didTapNextStepButtonFalse), for: .touchUpInside)
            nextStepButton.addTarget(self, action: #selector(didTapNextStepButtonTrue), for: .touchUpInside)
        }
        else {
            nextStepButton.backgroundColor = .systemGray
            
            
        }
     
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

