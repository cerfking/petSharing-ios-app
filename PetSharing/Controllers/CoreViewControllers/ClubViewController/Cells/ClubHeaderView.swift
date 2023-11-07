//
//  ClubHeaderView.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/2/7.
//

import UIKit

protocol ClubHeaderViewDelegate:AnyObject {

}

class ClubHeaderView: UITableViewHeaderFooterView {
    weak var delegate:ClubHeaderViewDelegate?
    static let identifier = "ClubHeaderView"
    
    
    private let clubImageView:UIImageView = {
        let clubImageView = UIImageView()
       // clubImageView.image = UIImage(named: "TennisClubHeader")
        clubImageView.layer.masksToBounds = true
        clubImageView.contentMode = .scaleAspectFill
//        clubImageView.layer.borderWidth = 1
//        clubImageView.layer.borderColor = UIColor.systemBackground.cgColor
        return clubImageView
    }()
    
    private let clubNameLabel:UILabel = {
        let clubNameLabel = UILabel()
        clubNameLabel.font = UIFont.systemFont(ofSize: 25,weight: UIFont.Weight.init(rawValue: 10))
        clubNameLabel.textColor = .white
        clubNameLabel.numberOfLines = 1
        
        return clubNameLabel
    }()
    
    private let numberLabel:UILabel = {
        let numberLabel = UILabel()
        numberLabel.font = numberLabel.font.withSize(18)
        numberLabel.textColor = .white
        numberLabel.text = "讨论0"
        return numberLabel
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(clubImageView)
        addSubview(clubNameLabel)
        addSubview(numberLabel)
        
    }
    public func configure(with post:String,postNumber:Int){
        clubImageView.image = UIImage(named: post)
        clubNameLabel.text = post
        numberLabel.text = "Post \(postNumber)"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = UIColor.init(red: 29/255, green: 120/255, blue: 128/255, alpha: 1)
        let clubImageSize = width/4.5
        
        clubImageView.frame = CGRect(x: 8, y: 12, width: clubImageSize, height: clubImageSize).integral
        clubImageView.layer.cornerRadius = clubImageSize/6.0
        clubNameLabel.frame = CGRect(x: 11 + clubImageView.right , y: 7 , width: 220, height: 50).integral
        numberLabel.frame = CGRect(x: clubNameLabel.left + 1, y: 60 , width: 60, height: 40)
    
        
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }

   

}
