//
//  CommentPostViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/1.
//

import UIKit
import SnapKit
import LeanCloud

class CommentPostViewController: UIViewController,UITextViewDelegate {
    
    var post:LCObject
    
    init(post:LCObject) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let textView:UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 18)
        textView.backgroundColor = .systemBackground
        textView.text = "Enter your comment here..."
        textView.textColor = UIColor.lightGray
        return textView
    }()
    
    private let headImageView:UIImageView = {
        let headImageView = UIImageView()
        //headImageView.image = UIImage(named: "profile")
        headImageView.layer.masksToBounds = true
        headImageView.layer.cornerRadius = 30
        return headImageView
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.snp.remakeConstraints{(make) in
            make.left.equalTo(view.snp.left).offset(80)
            make.right.equalTo(view.snp.right).offset(-10)
            make.top.equalTo(view.snp.top).offset(80)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
        }
        headImageView.snp.makeConstraints{(make) in
            make.left.equalTo(view.snp.left).offset(10)
            make.right.equalTo(textView.snp.left).offset(-10)
            make.top.equalTo(textView.snp.top)
            make.height.equalTo(60)
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        view.addSubview(headImageView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reply", style: .done, target: self, action: #selector(didTapCommentButton))
        DatabaseManager.shared.getUser(user: LCApplication.default.currentUser!){[weak self] user in
            self?.headImageView.sd_setImage(with: user?.profilePhoto)
        }
        

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapCommentButton(){
        StorageManager.shared.CommentPost(comment: textView.text, post: post)
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:协议方法
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your comment here..."
            textView.textColor = UIColor.lightGray
        }
    }

}
