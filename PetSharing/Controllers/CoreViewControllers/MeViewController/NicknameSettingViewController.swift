//
//  NicknameSettingViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/18.
//

import UIKit


class NicknameSettingViewController: UIViewController {
    private let completeButton:UIBarButtonItem = {
        let completeButton = UIBarButtonItem()
        completeButton.title = "完成"
        completeButton.action = #selector(didTapCompleteButton)
        return completeButton
        
    }()
    
    private let nickNameField:UITextField = {
        let nickNameField = UITextField()
        nickNameField.backgroundColor = .secondarySystemBackground
        nickNameField.textAlignment = .center
        return nickNameField
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(nickNameField)
        navigationItem.rightBarButtonItem = completeButton
        completeButton.target = self
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        nickNameField.frame = CGRect(x: 10, y: 120, width: view.width - 20, height: 40)
    }
    
    @objc func didTapCompleteButton(){
        StorageManager.shared.updateNickname(nickname: nickNameField.text)
        navigationController?.popViewController(animated: true)
    }
    

}
