//
//  NewWalletViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/28.
//

import UIKit

class NewWalletViewController: UIViewController {
    
    private let label:UILabel = {
        let label = UILabel()
        label.text = "请输入私钥"
        return label
    }()
    
    private let KeyTextField:UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .tertiarySystemGroupedBackground
        textField.placeholder = " 私钥"
        textField.isSecureTextEntry = true
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8.0
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "导入钱包"
        view.backgroundColor = .systemBackground
        view.addSubview(label)
        view.addSubview(KeyTextField)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        label.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(132)
        }
        
        KeyTextField.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(label.snp.bottom).offset(5)
            make.height.equalTo(52)
            
        }
    }
    
}
