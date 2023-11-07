//
//  EditTableViewCell.swift
//  Instagram
//
//  Created by 陆华敬 on 2021/10/9.
//

import UIKit
protocol EditTableViewCellDelegate:AnyObject {
    func editTableViewCell(_ cell:EditTableViewCell,didUpdateField updatedModel:EditProfileFormModel)
}

class EditTableViewCell: UITableViewCell,UITextFieldDelegate {
    static let identifier = "EditTableViewCell"
    private var model:EditProfileFormModel?
    public weak var delegate:EditTableViewCellDelegate?
    public let formLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        return label
        
        
    }()
    private let valueLabel:UILabel = {
        let valueLabel = UILabel()
        valueLabel.textColor = .label
        valueLabel.numberOfLines = 1
        return valueLabel
    }()
    private let field:UITextField = {
        let field = UITextField()
        field.returnKeyType = .done
        return field
        
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clipsToBounds = true
        contentView.addSubview(formLabel)
        //contentView.addSubview(field)
        contentView.addSubview(valueLabel)
        field.delegate = self
        selectionStyle = .none
    }
    
    
    
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        model?.value = textField.text
        guard let model = model else{
            return true
        }
        delegate?.editTableViewCell(self, didUpdateField: model)
        textField.resignFirstResponder()
        return true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //Assign frames
        formLabel.frame = CGRect(x: 20, y: 0, width: contentView.width/3, height: contentView.height)
        //field.frame = CGRect(x: formLabel.right+5, y: 0, width: contentView.width-10-formLabel.width, height: contentView.height)
        valueLabel.frame = CGRect(x: formLabel.right+5, y: 0, width: contentView.width-10-formLabel.width, height: contentView.height)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func configure(with model:EditProfileFormModel){
        self.model = model
        formLabel.text = model.label
        //field.placeholder = model.placeholder
        //field.text = model.value
        valueLabel.text = model.value
    }
    
    
  
}
