//
//  ConversationTableViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/20.
//

import UIKit
import LeanCloud
import SDWebImage
import SnapKit

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView:UIImageView = {
        let imageView = UIImageView()
      
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.image = UIImage(named: "profile2")
        return imageView
    }()
    
    private let userNameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .regular)
        return label
    }()
    
    private let userMessageLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let timeLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        contentView.addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(60)
        }
        
        userNameLabel.snp.makeConstraints{ make in
            make.left.equalTo(userImageView.snp.right).offset(10)
            make.top.equalTo(userImageView).offset(5)
        }
        
        userMessageLabel.snp.makeConstraints{ make in
            make.left.equalTo(userNameLabel)
            make.right.equalToSuperview().offset(-30)
            make.top.equalTo(userNameLabel.snp.bottom).offset(3)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        timeLabel.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(userNameLabel)
        }
        

    }
    
    public func configure(conversation:IMConversation){
        guard let _ = conversation.lastMessage?.content?.string else {
            return
        }
        if let categorizedMessage = conversation.lastMessage as? IMCategorizedMessage {
            let formatter = DateFormatter()
            formatter.locale = Locale.init(identifier: "zh_CN")
            formatter.dateFormat = "MM-dd"
            let date = formatter.string(from: categorizedMessage.sentDate!)
            timeLabel.text = date
            switch categorizedMessage {
            case let textMessage as IMTextMessage:
                let result = convertStringToDictionary(text:(textMessage.content?.string)!)
                userMessageLabel.text = (result?["_lctext"])! as? String
            case _ as IMImageMessage:
                userMessageLabel.text = "[图片]"
            case _ as IMAudioMessage:
                userMessageLabel.text = "[Audio]"
            default:
                break
            }
        }
        let objectId:String?
        if LCApplication.default.currentUser?.objectId?.stringValue == conversation.members![0] {
            objectId = conversation.members![1]
        }
        else {
            objectId = conversation.members![0]
        }
        DatabaseManager.shared.getUser(user: LCUser(objectId: objectId!)){ [weak self] user in
            
            self?.userImageView.sd_setImage(with: user?.profilePhoto)
            self?.userNameLabel.text = user?.nickname
        }
    }
    
    
   
}
