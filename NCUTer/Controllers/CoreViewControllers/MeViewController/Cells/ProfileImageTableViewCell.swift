//
//  ProfileImageTableViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/13.
//

import UIKit
import LeanCloud

class ProfileImageTableViewCell: UITableViewCell {
    static let identifier = "ProfileImageTableViewCell"
    private var profileURL:URL?
    private let profileImageView:UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.backgroundColor = .none
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.masksToBounds = true
        return profileImageView
    }()
    private let label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "头像"
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        contentView.addSubview(label)
        selectionStyle = .gray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = contentView.width/8
        profileImageView.frame = CGRect(x: 270, y: 11, width: contentView.width/4, height: contentView.width/4)

        label.frame = CGRect(x: 20, y: 40, width: 80, height: 40)
    }
    
    public func configure(with profileURL:URL){
        self.profileURL = profileURL
        profileImageView.sd_setImage(with: profileURL, completed: nil)
    }

}
