//
//  ExtraFuncCollectionViewCell.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/20.
//

struct ExtraFuncModel {
    let title:String
    let imageName:String
    let handler:(()->Void)
}

import UIKit
import SnapKit

class ExtraFuncCollectionViewCell: UICollectionViewCell {
    static let identifier = "ExtraFuncCollectionViewCell"
    
    private let iconView:UIImageView = {
        let iconView = UIImageView()
        iconView.image = UIImage(named: "ditu")
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Map"
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(iconView)
        contentView.addSubview(nameLabel)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        iconView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.width.height.equalTo(30)
            
        }
        nameLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(iconView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
    }
    
    public func configure(model:ExtraFuncModel){
        iconView.image = UIImage(named: model.imageName)
        nameLabel.text = model.title
    }
}
