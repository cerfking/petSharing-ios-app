//
//  PostLikeTableViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/12.
//

import UIKit
import LeanCloud
class PostLikeTableViewCell: UITableViewCell {

    weak var parent:UIViewController?
    
    private var liker:LCUser?

    static let identifier = "PostLikeTableViewCell"
    
    lazy var profileImageView:UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "profile")
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 25
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        return profileImageView
    }()
    
    private let nickNameLabel:UILabel = {
        let nickNameLabel = UILabel()
        nickNameLabel.text = "刘忠儒"
        nickNameLabel.font = UIFont.systemFont(ofSize: 16)
        return nickNameLabel
    }()
    
    
    
    public func configure(liker:LCUser){
        self.liker = liker
        DatabaseManager.shared.getUser(user: liker){ [weak self]user in
            self?.profileImageView.sd_setImage(with: user?.profilePhoto)
            self?.nickNameLabel.text = user?.nickname
           // self.liker = user
        }
     
    }
    
    
    @objc func imageTapped(){
        let destinationVC = CertainUserViewController(user:liker!)
        destinationVC.hidesBottomBarWhenPushed = true
        if let _ = parent?.parent as? CertainPostViewController{
            parent?.navigationController?.pushViewController(destinationVC,animated:true)
        }
        
    }
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nickNameLabel)
        
        selectionStyle = .default
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        profileImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(15)
            make.height.width.equalTo(50)
        }
        nickNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(5)
            make.top.equalTo(profileImageView.snp.top).offset(5)
            //make.height.equalTo(20)
            make.right.lessThanOrEqualTo(contentView).offset(-80)
        }
        
 
    }
    

}
