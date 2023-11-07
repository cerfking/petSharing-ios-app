//
//  NicknameSettingViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/18.
//

import UIKit
import LeanCloud

class SignatureViewController: UIViewController,UITextFieldDelegate {
    private let completeButton:UIBarButtonItem = {
        let completeButton = UIBarButtonItem()
        completeButton.title = "完成"
        completeButton.action = #selector(didTapCompleteButton)
        return completeButton
        
    }()
    
    private let signatureField:UITextField = {
        let signatureField = UITextField()
        signatureField.backgroundColor = .secondarySystemBackground
        signatureField.textAlignment = .left
        signatureField.layer.cornerRadius = 10.0
        return signatureField
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(signatureField)
        navigationItem.rightBarButtonItem = completeButton
        completeButton.target = self
        DatabaseManager.shared.getUser(user:LCApplication.default.currentUser!){[weak self] user in
            let bio = user?.bio
            self?.signatureField.text = bio
            
        }
        
      
        

        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewDidLayoutSubviews() {
        signatureField.frame = CGRect(x: 10, y: 100, width: view.width - 20, height: 120)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        StorageManager.shared.updateBio(bio: signatureField.text)
    }
    
   
    
    @objc func didTapCompleteButton(){
        StorageManager.shared.updateBio(bio: signatureField.text)
        
        navigationController?.popViewController(animated: true)
    }
    

}
