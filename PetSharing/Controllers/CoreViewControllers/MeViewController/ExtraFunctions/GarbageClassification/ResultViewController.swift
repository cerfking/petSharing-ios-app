//
//  ResultViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/21.
//

import UIKit
import SnapKit

class ResultViewController: UIViewController {
    
    private let image:UIImage
    
    private let result:String
    
    private let recyclable:String = "适宜回收可循环利用的生活废弃物。投放可回收物时，应尽量保持清洁干燥，避免污染；立体包装应清空内容物，清洁后压扁投放；易破损或有裹尖镜边角的应包后投放。"
    
    private let kitchen:String = "即易腐垃圾，易腐的生物质生活废弃物。湿垃圾应从产生时就与其他品种垃圾分开收集。投放前尽量沥干水分，有外包装的应去除外包装投放。"
    
    private let hazardous:String = "分类投放有害垃圾时，应注意轻放。己破碎的及废弃药品应连带包装或包裹后投放，压力罐容器应排空内容物后投放。"
    
    private let other:String = "其他垃圾（上海称干垃圾）包括除上述几类垃圾之外的砖瓦陶瓷、渣土、卫生间废纸、纸巾等难以回收的废弃物及尘土、食品袋（盒）。采取卫生填埋可有效减少对地下水、地表水、土壤及空气的污染"
    
    init(image:UIImage,result:String) {
        self.image = image
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private let resultLabel:UILabel = {
        let resultLabel = UILabel()
        resultLabel.textAlignment = .center
        resultLabel.sizeToFit()
        resultLabel.font = .systemFont(ofSize: 25, weight: .bold)
        return resultLabel
    }()
    
    private let detailTextView:UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.isEditable = false
        textView.textColor = .tertiaryLabel
        textView.sizeToFit()
        textView.font = .systemFont(ofSize: 18)
        textView.textAlignment = .left
        return textView
    }()
    
    private let indicatorView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(resultLabel)
        view.addSubview(detailTextView)
        view.addSubview(indicatorView)
        imageView.image = image
        resultLabel.text = result
        switch result {
        case "可回收物":
            detailTextView.text = recyclable
            break
        case "厨余垃圾":
            detailTextView.text = kitchen
            break
        case "有害垃圾":
            detailTextView.text = hazardous
            break
        case "其他垃圾":
            detailTextView.text = other
            break
        default:
            detailTextView.text = nil
        }
        indicatorView.image = UIImage(named: result)
    }
    
    override func viewDidLayoutSubviews() {
        imageView.snp.makeConstraints{ make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(250)
        }
        
        resultLabel.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.height.equalTo(30)
        }
        
        detailTextView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(resultLabel.snp.bottom).offset(10)
    
        }
        
        indicatorView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    

}
