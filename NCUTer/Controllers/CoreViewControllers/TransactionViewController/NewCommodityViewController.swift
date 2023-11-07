//
//  NewCommodityViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/18.
//

import UIKit
import SnapKit
import SKPhotoBrowser
import Photos
import PhotosUI
import MobileCoreServices
import UniformTypeIdentifiers
import LeanCloud
import SafariServices

class NewCommodityViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource, PHPickerViewControllerDelegate, UIDocumentPickerDelegate {
    
    private var images = [UIImage]()
    private var SKImages = [SKPhoto]()
    private var modelURL:String?
   
    private let detailTextView:UITextView = {
        let detailTextView = UITextView()
        detailTextView.isEditable = true
        detailTextView.isScrollEnabled = true
        detailTextView.font = UIFont.systemFont(ofSize: 18)
        detailTextView.text = "买家都关心品牌型号、入手渠道、转手原因..."
        detailTextView.textColor = UIColor.lightGray
        detailTextView.backgroundColor = .systemBackground
        return detailTextView
    }()
    
    private let addPhotosButton:UIButton = {
        let addPhotosButton = UIButton()
        addPhotosButton.layer.masksToBounds = true
        addPhotosButton.layer.cornerRadius = 8.0
        addPhotosButton.setTitle("+添加图片", for: .normal)
        addPhotosButton.setTitleColor(.label, for: .normal)
        addPhotosButton.titleLabel?.center = addPhotosButton.center
        addPhotosButton.backgroundColor = .secondarySystemBackground
        addPhotosButton.addTarget(self, action: #selector(didTapAddPicButton), for: .touchUpInside)
        return addPhotosButton
    }()
    
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 40) / 3
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let priceImageView:UIImageView = {
        let priceImageView = UIImageView()
        priceImageView.image = UIImage(systemName: "yensign.circle.fill")
        priceImageView.tintColor = .label
        return priceImageView
    }()
    
    private let priceLabel:UILabel = {
        let priceLabel = UILabel()
        priceLabel.textColor = .label
        priceLabel.text = "价格"
        priceLabel.font = .systemFont(ofSize: 15)
        return priceLabel
    }()
    
    private let priceTextField:UITextField = {
        let priceTextField = UITextField()
        priceTextField.attributedPlaceholder = NSAttributedString(string: "  0.00",attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemRed])
        priceTextField.textAlignment = .right
        priceTextField.textColor = .systemRed
        priceTextField.keyboardType = .numberPad
        priceTextField.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "¥"
        label.textColor = .systemRed
        label.sizeToFit()
        priceTextField.rightView = label
        priceTextField.rightViewMode = .always
        return priceTextField
    }()
    
    private let addModelImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "folder.circle.fill")
        imageView.tintColor = .label
        return imageView
    }()
    
    private let addModelButton:UIButton = {
        let button = UIButton()
        button.setTitle("上传模型(可选)", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.label, for: .normal)
        button.addTarget(self, action: #selector(didTapSelectFilesButton), for: .touchUpInside)
        return button
    }()
    
    private let infoButton:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.addTarget(self, action: #selector(didTapInfoButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发布", style: .done, target: self, action: #selector(didTapPostButton))
        view.backgroundColor = .systemBackground
        view.addSubview(detailTextView)
        view.addSubview(addPhotosButton)
        view.addSubview(collectionView)
        view.addSubview(priceImageView)
        view.addSubview(priceLabel)
        view.addSubview(priceTextField)
        view.addSubview(addModelImageView)
        view.addSubview(addModelButton)
        view.addSubview(infoButton)
        detailTextView.delegate = self
        priceTextField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        detailTextView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(200)
        }
        addPhotosButton.snp.makeConstraints{ make in
            make.left.equalTo(detailTextView)
            make.top.equalTo(detailTextView.snp.bottom).offset(20)
            make.width.height.equalTo((view.width - 40) / 3)
        }
        
        priceImageView.snp.makeConstraints{ make in
            make.left.equalTo(detailTextView)
            make.top.equalTo(addPhotosButton.snp.bottom).offset(20).priority(.high)
            make.width.height.equalTo(30)
        }
        priceLabel.snp.makeConstraints{ make in
            make.left.equalTo(priceImageView.snp.right).offset(5)
            make.width.equalTo(40)
            make.top.equalTo(priceImageView).offset(5)
        }
        priceTextField.snp.makeConstraints{ make in
            make.left.equalTo(priceLabel.snp.right).offset(5)
            make.right.equalTo(detailTextView).offset(-5)
            make.top.bottom.equalTo(priceImageView)
        }
        addModelImageView.snp.makeConstraints{ make in
            make.left.equalTo(priceImageView)
            make.top.equalTo(priceImageView.snp.bottom).offset(10)
            make.width.height.equalTo(30)
        }
        addModelButton.snp.makeConstraints{ make in
            make.left.equalTo(addModelImageView.snp.right).offset(5)
            make.top.equalTo(addModelImageView).offset(1)
        }
        infoButton.snp.makeConstraints{ make in
            make.right.equalTo(priceTextField)
            make.top.equalTo(addModelButton)
            make.height.equalTo(priceTextField)
        }
    }
    
    @objc func didTapPostButton(){
        guard let content = detailTextView.text,!content.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "未输入商品详情", message: "请输入商品详情后重新发送", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
      
         
        StorageManager.shared.uploadPostImage(images: images){ [weak self] url in
        
            var newCommodity = Commodity()
            newCommodity.detail = self?.detailTextView.text
            newCommodity.price = self?.priceTextField.text
            if url.count != 0 {
                newCommodity.imagesURL = url //图片
            }
            newCommodity.seller = LCApplication.default.currentUser
            newCommodity.modelURL = self?.modelURL
        
            StorageManager.shared.newCommodity(commodity: newCommodity){ _ in
                print("上传成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
            print("输入后点击了发送按钮")
    }
    
    
    @objc func didTapAddPicButton(){
        print("点击了图片按钮")
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        //只能选择照片
        config.filter = PHPickerFilter.images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func didTapSelectFilesButton() {
        let types = UTType.types(tag: "docx",
                                 tagClass: UTTagClass.filenameExtension,
                                 conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(
                forOpeningContentTypes: types)
        documentPickerController.delegate = self
        present(documentPickerController, animated: true, completion: nil)
    }
    
    @objc func didTapInfoButton(){
        guard let url = URL(string: "https://3dscannerapp.com") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    
    
    //MARK:-delegate function
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            textView.text = "买家都关心品牌型号、入手渠道、转手原因..."
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell else {
            fatalError()
        }
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let browser = SKPhotoBrowser(photos: SKImages)
         browser.initializePageIndex(indexPath.section)
         present(browser, animated: true)
     
    }
    
    //选择文件完成,上传文件
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        for url in urls {
            let file = LCFile(payload: .fileURL(fileURL: url))
            _ = file.save(progress: { (progress) in
                print(progress)
            }) {[weak self] (result) in
                switch result {
                case .success:
                    // 保存后的操作
                    guard let _ = file.url?.stringValue else {
                        return
                    }
                    self?.modelURL = file.url?.stringValue!
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
        }
    }
  
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        print("选择完成")
        dismiss(animated: true)
        let group = DispatchGroup()
        results.forEach{ result in
            group.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self){ [weak self] reading, error in
                defer {
                    group.leave()
                }
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                self?.images.append(image)
                self?.SKImages.append(SKPhoto.photoWithImage(image))
                DispatchQueue.main.async {
                    self?.collectionView.isHidden = false
                    self?.addPhotosButton.isHidden = true
                   
                }
                
                
            }
        }
        group.notify(queue: .main){ [self] in
            collectionView.reloadData()
            collectionView.snp.remakeConstraints{(make) in
                let photoWidth = UIScreen.main.bounds.width - 10 * 2
                make.left.right.equalTo(detailTextView)
                make.top.equalTo(detailTextView.snp.bottom).offset(20)
                let result = ((images.count - 1)/3 + 1) * Int(photoWidth)/3 + (images.count - 1)/3 * 10
                make.height.equalTo(result)
            }
            priceImageView.snp.remakeConstraints{ make in
                make.left.equalTo(detailTextView)
                make.top.equalTo(collectionView.snp.bottom).offset(20)
                make.width.height.equalTo(30)
            }

        }
        
    }
  
}
