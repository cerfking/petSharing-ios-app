//
//  SecondhandItemsCollectionViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/24.
//

import UIKit

class SecondhandItemsCollectionViewCell: UICollectionViewCell {
    static let identifier = "SecondhandItemsCollectionViewCell"
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8.0
        return imageView
    }()
    private let itemInfoLabel:PaddingLabel = {
        let itemInfoLabel = PaddingLabel()
        
        itemInfoLabel.font = UIFont.systemFont(ofSize: 15,weight: UIFont.Weight.init(rawValue: 10))
        itemInfoLabel.textColor = .systemRed
        itemInfoLabel.paddingLeft = 5
        return itemInfoLabel
    }()
    private let priceLabel:PaddingLabel = {
        let priceLabel = PaddingLabel()
     //   priceLabel.text = "¥460"
        priceLabel.font = UIFont.systemFont(ofSize: 18,weight: UIFont.Weight.init(rawValue: 13))
        priceLabel.textColor = .systemRed
        priceLabel.paddingLeft = 5
        priceLabel.paddingBottom = 3
        return priceLabel
    }()
    private let sellerProfile:UIImageView = {
        let sellerProfile = UIImageView()
      //  sellerProfile.image = UIImage(named: "profile")
        sellerProfile.layer.cornerRadius = 15
        sellerProfile.layer.masksToBounds = true
        return sellerProfile
    }()
    
    private let sellerNameLabel:PaddingLabel = {
        let sellerNameLabel = PaddingLabel()
     
        sellerNameLabel.paddingLeft = 5
        sellerNameLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.init(8))
        return sellerNameLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(itemInfoLabel)
       //contentView.addSubview(priceLabel)
        contentView.addSubview(sellerProfile)
        contentView.addSubview(sellerNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(commodity:Commodity) {
        imageView.sd_setImage(with: URL(string: (commodity.imagesURL![0])))
        itemInfoLabel.text = commodity.detail
        priceLabel.text = "$\(commodity.price!)"
        DispatchQueue.main.async {
            guard let _ = commodity.seller else {
                return
            }
            DatabaseManager.shared.getUser(user: commodity.seller!){ [weak self] user in
                self?.sellerProfile.sd_setImage(with: user?.profilePhoto,placeholderImage: UIImage(named: "placeholderImage"))
                self?.sellerNameLabel.text = user?.nickname
            }
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: contentView.frame.minX, y: contentView.frame.minY, width: contentView.width, height: contentView.height - 90)
        itemInfoLabel.frame = CGRect(x: 0, y: contentView.frame.minY + contentView.height - 90, width: contentView.width, height: 30)
        priceLabel.frame = CGRect(x: 0, y: contentView.frame.minY + contentView.height - 60, width: contentView.width, height: 30)
        sellerProfile.frame = CGRect(x: 0, y: contentView.frame.minY + contentView.height - 30, width: contentView.width/6, height: 30)
        sellerNameLabel.frame = CGRect(x: sellerProfile.right, y: contentView.frame.minY + contentView.height - 30, width: 5 * (contentView.width/6), height: 30)
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
   
}
