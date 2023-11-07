//
//  ClubPostTableViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/13.
//

import UIKit

class ClubPostTableViewCell: UITableViewCell {
    
    static let identifier = "ClubPostTableViewCell"
    
    private let titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = true
        titleLabel.sizeToFit()
        titleLabel.numberOfLines = 0
        titleLabel.text = "动画/音乐｜这个角色是机动战士高达里的吗（已经百度搜索了）动画/音乐｜这个角色是机动战士高达里的吗（已经百度搜索了）"

        return titleLabel
    }()
    
    private let profileImageView:UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.image = UIImage(named: "profile")
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 20
        return profileImageView
    }()
    
    private let nickNameLabel:UILabel = {
        let nickNameLabel = UILabel()
        nickNameLabel.textColor = .secondaryLabel
        nickNameLabel.text = "Furad"
        nickNameLabel.font = UIFont.systemFont(ofSize: 15)
        return nickNameLabel
    }()
    
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nickNameLabel)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(post:ClubPost) {
        titleLabel.text = post.title
        DispatchQueue.main.async {
            guard let _ = post.poster else {
                return
            }
            DatabaseManager.shared.getUser(user: post.poster!){ [weak self] user in
                self?.nickNameLabel.text = user?.nickname
                self?.profileImageView.sd_setImage(with: user?.profilePhoto, placeholderImage: UIImage(named: "placeholderImage"))
            }
        }
      //  self.nickNameLabel.text = post.nickName
      //  self.profileImageView.sd_setImage(with: post.headPic, placeholderImage: UIImage(named: "placeholderImage"))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.top.equalToSuperview().offset(10)
            make.bottom.lessThanOrEqualTo(profileImageView.snp.top).offset(-10).priority(.high)
          
        }
        
        profileImageView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(40)
            make.width.equalTo(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
            make.height.equalTo(40)
        }
        
        nickNameLabel.snp.makeConstraints{ make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.top.equalTo(profileImageView.snp.top).offset(5)
            make.bottom.equalTo(profileImageView).offset(-5)
        }
        
       
    }
    
   
}
