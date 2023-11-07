//
//  ClubCollectionViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/25.
//

import UIKit

class ClubCollectionViewCell: UICollectionViewCell {
    static let identifier = "ClubCollectionViewCell"
    
    private var model:ClubCollectionCellModel?
    
    

    private let clubImageView:UIImageView = {
        let clubImageView = UIImageView()
        clubImageView.contentMode = .scaleAspectFit
        return clubImageView
    }()
    private let clubNameLable:UILabel = {
        let clubNameLabel = UILabel()
        clubNameLabel.textAlignment = .center
        return clubNameLabel
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        clubImageView.frame = CGRect(x: 38, y: 25, width: 60, height: 60)
        clubNameLable.frame = CGRect(x: contentView.center.x - contentView.width / 2, y: 90, width: contentView.width, height: 30)

    }
    override func prepareForReuse() {
        super.prepareForReuse()
        clubImageView.image = nil
        clubNameLable.text = nil
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(clubImageView)
        contentView.addSubview(clubNameLable)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func configure(with model:ClubCollectionCellModel){
        self.model = model
        clubNameLable.text = model.clubName
        clubImageView.image = UIImage(named: model.imageName!)
        
    }
}
