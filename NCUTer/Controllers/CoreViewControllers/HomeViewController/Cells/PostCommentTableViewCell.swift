//
//  PostCommentTableViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/7.
//

import UIKit
import SnapKit
import LeanCloud

class PostCommentTableViewCell: UITableViewCell {
    
    weak var parent:UIViewController?
    
    private var commenter:LCUser?

    static let identifier = "PostCommentTableViewCell"
    
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
        nickNameLabel.text = ""
        nickNameLabel.font = UIFont.systemFont(ofSize: 16)
        return nickNameLabel
    }()
    
    private let timeLabel:UILabel = {
        let timeLabel = UILabel()
        timeLabel.text = "03-07"
        timeLabel.textColor = UIColor.gray;
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        return timeLabel
    }()
    
    private let commentTextView:UITextView = {
        let commentTextView = UITextView()
        commentTextView.translatesAutoresizingMaskIntoConstraints = true
        commentTextView.sizeToFit()
        commentTextView.isScrollEnabled = false
        return commentTextView
    }()
    
    public func configure(comment:PostComment){
        commenter = comment.commenter
        timeLabel.text = comment.createdAt
        commentTextView.text = comment.commentText
        DatabaseManager.shared.getUser(user: comment.commenter!){ [weak self] commenter in
            self?.profileImageView.sd_setImage(with: commenter?.profilePhoto)
            self?.nickNameLabel.text = commenter?.nickname
        }
    }
    
    
    @objc func imageTapped()
    {
        let destinationVC = CertainUserViewController(user:commenter!)
        destinationVC.hidesBottomBarWhenPushed = true
        if let _ = parent?.parent as? CertainPostViewController{
            parent?.navigationController?.pushViewController(destinationVC,animated:true)
        }
        else {
            return
        }
        
    }
  
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(commentTextView)
        contentView.addSubview(timeLabel)
        
        
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
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right).offset(5)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(5)
            make.height.equalTo(10)
            make.right.lessThanOrEqualTo(contentView).offset(-80)
        }
        commentTextView.snp.makeConstraints { (make) in
            make.left.equalTo(profileImageView.snp.right)
            make.right.equalTo(contentView).offset(-15)
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualToSuperview()
        }
 
    }
    

   

}
