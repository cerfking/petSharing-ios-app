//
//  UserFollowTableViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/2/6.
//


import UIKit
import LeanCloud
import SnapKit
//protocol FollowTableViewCellDelegate :AnyObject{
//    func didTapFollowUnfollowButton(model:FollowState,user:User)
//}


class FollowTableViewCell: UITableViewCell {
    static let identifier = "FollowTableViewCell"
    //weak var delegate:FollowTableViewCellDelegate?
    private var model:FollowState?
    private var user:User?
    private let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    private let bioLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let followButton:UIButton = {
        let followButton = UIButton()
        followButton.backgroundColor = .link
        return followButton
    }()
    override init(style:UITableViewCell.CellStyle,reuseIdentifier:String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(nameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(followButton)
        followButton.addTarget(self, action: #selector(didTapFollowUnFollowButton), for: .touchUpInside)
        //selectionStyle = .none
        
    }
    
    
    @objc func didTapFollowUnFollowButton(){
        
        switch model {
        case .following:
            //perform firebase upsate to unfollow
            print("取消关注")
            print(user?.nickname as Any)
            RelationshipManager.shared.unfollow(target: LCUser(objectId: (user?.objectId)!))
            DispatchQueue.main.async { [self] in
                followButton.setTitle("Follow", for: .normal)
                followButton.setTitleColor(.systemOrange, for: .normal)
                followButton.tintColor = .systemOrange
                followButton.backgroundColor = .systemBackground
                followButton.layer.borderWidth = 1
                followButton.layer.borderColor = UIColor.systemOrange.cgColor
                model = .not_following
            }
        break
        case .not_following:
            print("关注")//perform firebase update to follow
            print(user?.nickname as Any)
            RelationshipManager.shared.follow(target: LCUser(objectId: (user?.objectId)!))
            DispatchQueue.main.async { [self] in
                followButton.setTitle("Unfollow", for: .normal)
                followButton.setTitleColor(.label, for: .normal)
                followButton.backgroundColor = .secondarySystemBackground
                followButton.layer.borderWidth = 1
                followButton.layer.borderColor = UIColor.label.cgColor
                model = .following
            }
        break

        case .none:
            return
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nameLabel.text = nil
        bioLabel.text = nil
        followButton.setTitle(nil, for: .normal)
        followButton.layer.borderWidth = 0
        followButton.backgroundColor = nil
    }
    public func configure(with model:FollowState,user:User){
        self.model = model
        self.user = user
        nameLabel.text = user.nickname
        bioLabel.text = user.bio
        profileImageView.sd_setImage(with: URL(string:user.profilePictureURL!))
        if user.objectId == LCApplication.default.currentUser?.objectId?.stringValue {
            followButton.isHidden = true
        }
        else {
            switch model {
            case .following:
                //取消关注按钮
                followButton.setTitle("Unfollow", for: .normal)
                followButton.setTitleColor(.label, for: .normal)
                followButton.backgroundColor = .secondarySystemBackground
                followButton.layer.borderWidth = 1
                followButton.layer.borderColor = UIColor.label.cgColor
                
            case .not_following:
                //关注按钮
                followButton.setTitle("Follow", for: .normal)
                followButton.setTitleColor(.systemOrange, for: .normal)
                followButton.tintColor = .systemOrange
                followButton.backgroundColor = .systemBackground
                followButton.layer.borderWidth = 1
                followButton.layer.borderColor = UIColor.systemOrange.cgColor
            }
            
        }
      
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth = contentView.width > 500 ? 220.0 : contentView.width/4
        let labelHeight:CGFloat = 30
     
        profileImageView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(contentView.height - 20)
        }
        nameLabel.snp.makeConstraints{ make in
            make.left.equalTo(profileImageView.snp.right).offset(5)
            make.top.equalTo(profileImageView.snp.top).offset(5)
            make.height.equalTo(labelHeight)
        }
        bioLabel.snp.makeConstraints{ make in
            make.left.equalTo(nameLabel)
            make.width.equalTo(160)
            make.bottom.equalTo(profileImageView.snp.bottom).offset(-5)
            make.height.equalTo(labelHeight)
        }
        followButton.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(buttonWidth)
            make.top.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(-30)
        }
        followButton.layer.cornerRadius = followButton.height / 2
        profileImageView.layer.cornerRadius = profileImageView.height/2.0
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    }
