//
//  CertainUserHeader.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/2/18.
//

import UIKit
import SnapKit
import LeanCloud
import SDWebImage

protocol CertainUserHeaderDelegate:AnyObject{
    func certainUserHeaderDidTapFollowingNumberButton()
    func certainUserHeaderDidTapFollowerNumberButton()
}

class CertainUserHeader: UITableViewHeaderFooterView {
    public var delegate:CertainUserHeaderDelegate?
    static let identifier = "CertainUserHeader"
    private let backgroundImageView:UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.image = UIImage(named: "usc_trojan_tommy_trojan_statue")
        backgroundImageView.alpha = 0.6
        return backgroundImageView
    }()
    
    private let headImage: UIImageView = {
        let headimage = UIImageView()
        headimage.clipsToBounds = true
        headimage.layer.masksToBounds = true
        headimage.contentMode = .scaleAspectFit
        headimage.layer.cornerRadius = 35
        //headimage.image = UIImage(named: "profile")
        return headimage
    }()
    
    private let nickLabel: UILabel = {
        let nickLabel = UILabel()
        nickLabel.textColor = .label;
        nickLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        nickLabel.textColor = .label
        return nickLabel
    }()
    
    private let followerNumberButton:UIButton = {
        let followerNumberButton = UIButton()
        
        followerNumberButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        //followerNumberButton.setTitle("粉丝0", for: .normal)
        followerNumberButton.setTitleColor(.label, for: .normal)
        followerNumberButton.addTarget(self, action: #selector(didTapFollwerNumberButton), for: .touchUpInside)
        return followerNumberButton
    }()
    
    private let followingNumberButton:UIButton = {
        let followingNumberButton = UIButton()
   
        followingNumberButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        //followingNumberButton.setTitle("关注0", for: .normal)
        followingNumberButton.setTitleColor(.label, for: .normal)
        followingNumberButton.addTarget(self, action: #selector(didTapFollowingNumberButton), for: .touchUpInside)
        return followingNumberButton
    }()
    
    private let postNumberLabel:UILabel = {
        let postNumberLabel = UILabel()
        postNumberLabel.numberOfLines = 1
       // postNumberLabel.text = "全部发布0"
        postNumberLabel.textColor = .systemGray
        postNumberLabel.font = UIFont.systemFont(ofSize: 15)
        return postNumberLabel
    }()
    
    private let followUnfollowButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .link
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(headImage)
        contentView.addSubview(nickLabel)
        contentView.addSubview(followerNumberButton)
        contentView.addSubview(followingNumberButton)
        contentView.addSubview(postNumberLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(user:User,postNumber:Int){
        let lcuser = LCUser(objectId: user.objectId as! LCStringConvertible)
        DispatchQueue.main.async {
            self.headImage.sd_setImage(with: user.profilePhoto, completed: nil)
            self.nickLabel.text = user.nickname
        }
        //获取粉丝数目
        RelationshipManager.shared.getFollowers(user:lcuser){[weak self] followers in
            guard let _ = followers else {
                return
            }
            self?.followerNumberButton.setTitle("Followers \(followers!.count)", for: .normal)
        }
        //获取关注数目
        RelationshipManager.shared.getFollowees(user:lcuser){[weak self] followings in
            guard let _ = followings else {
                return
            }
            self?.followingNumberButton.setTitle("Following \(followings!.count)", for: .normal)
        }
        postNumberLabel.text = "Posts(\(String(postNumber)))"
        //self.followerNumberButton.setTitle("粉丝\(followerNumber)", for: .normal)
       // self.followingNumberButton.setTitle("关注\(followingNumber)", for: .normal)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView.snp.makeConstraints{(make) in
            make.left.equalTo(contentView.snp.left)
            make.right.equalTo(contentView.snp.right)
            make.top.equalTo(contentView.snp.top)
            make.height.equalTo(160)
        }
        headImage.snp.makeConstraints { (make) in
            make.left.equalTo(contentView.snp.left).offset(15)
            make.top.equalTo(contentView.snp.bottom).offset(-100)
            make.height.width.equalTo(70)
        }
        nickLabel.snp.makeConstraints { (make) in
            make.left.equalTo(headImage.snp.right).offset(8)
            make.top.equalTo(headImage.snp.top).offset(20)
            make.height.equalTo(20)
            make.right.lessThanOrEqualTo(contentView).offset(-80)
        }
        followerNumberButton.snp.makeConstraints{(make) in
            make.left.equalTo(nickLabel.snp.left)
            make.width.equalTo(80)
            make.height.equalTo(20)
            make.top.equalTo(nickLabel.snp.bottom).offset(10)
        }
        followingNumberButton.snp.makeConstraints{(make) in
            make.left.equalTo(followerNumberButton.snp.right).offset(10)
            make.width.equalTo(80)
            make.height.equalTo(20)
            make.top.equalTo(nickLabel.snp.bottom).offset(10)
        }
        postNumberLabel.snp.makeConstraints{(make) in
            make.left.equalTo(contentView.snp.left).offset(15)
            make.right.equalTo(contentView.snp.right)
            make.top.equalTo(headImage.snp.bottom).offset(-2)
            make.height.equalTo(40)
        }
    }
    
    @objc func didTapFollowingNumberButton(){
        delegate?.certainUserHeaderDidTapFollowingNumberButton()
    }
    
    @objc func didTapFollwerNumberButton(){
        delegate?.certainUserHeaderDidTapFollowerNumberButton()
    }
    


}
