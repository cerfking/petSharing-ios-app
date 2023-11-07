//
//  CommodityPicCollectionViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/17.
//

import UIKit

class CommodityPicCollectionViewCell: UICollectionViewCell {
    static let identifier = "CommodityPicCollectionViewCell"
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8.0
        imageView.image = UIImage(named: "image3")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(picURL:URL) {
        imageView.sd_setImage(with: picURL)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
