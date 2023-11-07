//
//  NewPostViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/2/13.
//

import UIKit
import SnapKit
import Photos
import PhotosUI
import SKPhotoBrowser
import LeanCloud
import Lottie
import CoreLocation

class NewPostViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, PHPickerViewControllerDelegate,UITextViewDelegate {
    
    private var images = [UIImage]()
    private var SKImages = [SKPhoto]()

    private let postTextView:UITextView = {
        let postTextView = UITextView()
        postTextView.font = UIFont.systemFont(ofSize: 18)
      
     
        return postTextView
    }()
    
    private let bottomToolBar:UIToolbar = {
        let bottomToolBar = UIToolbar(frame: CGRect(x: 0, y: 764, width: UIScreen.main.bounds.width, height: 60))
        let pictureButton = UIButton()
        pictureButton.frame.size = CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
        pictureButton.setImage(UIImage(systemName: "photo"), for: .normal)
        pictureButton.tintColor = .gray
        pictureButton.addTarget(self, action: #selector(didTapPictureButton), for: .touchUpInside)
        let button1 = UIBarButtonItem(customView: pictureButton)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let locationButton = UIButton()
        locationButton.frame.size = CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
        locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        locationButton.tintColor = .gray
        locationButton.addTarget(self, action: #selector(didTapLocationButton), for: .touchUpInside)
        let button2 = UIBarButtonItem(customView: locationButton)
        
        bottomToolBar.setItems([button1,spaceButton,button2], animated: true)
        
        bottomToolBar.backgroundColor = .secondarySystemBackground
        return bottomToolBar
    }()
    
    //显示选择的图片
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 34) / 3
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
      
        
        
        return collectionView
    }()
    
    //显示已经输入的字符个数
    private let charNumberLabel:UILabel = {
        let charNumberLabel = UILabel()
       
        charNumberLabel.numberOfLines = 0
        charNumberLabel.text = "0/140"
        charNumberLabel.textAlignment = .center
        return charNumberLabel
    }()
    
//    private let sendButton:UIButton = {
//        let sendButton = UIButton()
//        sendButton.frame.size = CGSize(width: 80, height: 25)
//        sendButton.setTitle("发送", for: .normal)
//        sendButton.backgroundColor = .systemOrange
//        sendButton.layer.cornerRadius = 17
//        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
//        return sendButton
//    }()
    
    private let animationContainer:UIView = {
        let animationContainer = UIView()
        
        animationContainer.isHidden = true
        animationContainer.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        animationContainer.isOpaque = false

        return animationContainer
    }()
    
    private let successAnimationView:LottieAnimationView = {
        let successAnimationView = LottieAnimationView()
        successAnimationView.animation = LottieAnimation.named("782-check-mark-success")
        successAnimationView.loopMode = .playOnce
        successAnimationView.contentMode = .scaleAspectFit
        successAnimationView.translatesAutoresizingMaskIntoConstraints = false
        return successAnimationView
    }()
    
    private let successLabel:UILabel = {
        let successLabel = UILabel()
        successLabel.text = "success"
        successLabel.textAlignment = .center
        successLabel.textColor = .white
        return successLabel
    }()
    
    private let locationNameLabel:UILabel = {
        let locationNameLabel = UILabel()
        locationNameLabel.numberOfLines = 1
      
        return locationNameLabel
    }()
    
    private let locationIcon:UIImageView = {
        let locationIcon = UIImageView()
        locationIcon.image = UIImage(named: "dingwei")
        locationIcon.contentMode = .scaleAspectFit
        return locationIcon
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let sendButton = UIButton()
        sendButton.frame.size = CGSize(width: 80, height: 25)
        sendButton.setTitle("send", for: .normal)
        sendButton.backgroundColor = .systemOrange
        sendButton.layer.cornerRadius = 17
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        title = "New Post"
        view.addSubview(postTextView)
        view.addSubview(bottomToolBar)
        //view.addSubview(charNumberLabel)
        view.addSubview(animationContainer)
        animationContainer.addSubview(successAnimationView)
        animationContainer.addSubview(successLabel)
        postTextView.addSubview(collectionView)
        postTextView.addSubview(locationNameLabel) //地址名
        postTextView.addSubview(locationIcon) //定位图标
        collectionView.isHidden = true
        locationIcon.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        postTextView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let photoWidth = UIScreen.main.bounds.width - 15 * 2

        postTextView.snp.remakeConstraints{(make) in
            make.left.equalTo(view.snp.left).offset(5)
            make.right.equalTo(view.snp.right).offset(-5)
            make.bottom.equalTo(view.snp.bottom).offset(-60)
            make.top.equalTo(view.snp.top)

        }

        collectionView.snp.remakeConstraints{(make) in
            make.left.equalTo(view.snp.left).offset(15)
            make.right.equalTo(view.snp.right).offset(-15)
            make.bottom.equalTo(view.snp.bottom).offset(-120)
            make.height.equalTo(photoWidth)

        }
        
//        charNumberLabel.snp.remakeConstraints{(make) in
//            make.right.equalTo(postTextView.snp.right).offset(-10)
//            make.width.equalTo(60)
//            make.bottom.equalTo(collectionView.snp.top).offset(-40)
//            make.height.equalTo(20)
//        }
        
        locationIcon.snp.remakeConstraints{(make) in
            make.left.equalTo(postTextView.snp.left)
            make.width.equalTo(20)
            make.bottom.equalTo(collectionView.snp.top).offset(-39)
            make.height.equalTo(20)
        }
        
        locationNameLabel.snp.remakeConstraints{(make) in
            make.left.equalTo(locationIcon.snp.right)
        //    make.right.equalTo(charNumberLabel.snp.left)
            make.bottom.equalTo(collectionView.snp.top).offset(-39)
            make.height.equalTo(20)
        }
        
        animationContainer.frame.size = CGSize(width: 100, height: 80)
        animationContainer.center = view.center
        successAnimationView.snp.remakeConstraints{(make) in
            make.left.equalTo(animationContainer.snp.left).offset(20)
            make.right.equalTo(animationContainer.snp.right).offset(-20)
            make.top.equalTo(animationContainer.snp.top).offset(5)
            make.bottom.equalTo(animationContainer.snp.bottom).offset(-20)
        }
        successLabel.snp.remakeConstraints{(make) in
            make.left.equalTo(animationContainer.snp.left).offset(5)
            make.right.equalTo(animationContainer.snp.right).offset(-5)
            make.top.equalTo(successAnimationView.snp.bottom)
            make.bottom.equalTo(animationContainer.snp.bottom).offset(-3)
        }
        
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text).trimmingCharacters(in: .whitespacesAndNewlines)
//        let numberOfChars = newText.count
//        DispatchQueue.main.async {
//            self.charNumberLabel.text = "\(String(numberOfChars))/140"
//
//        }
//        return numberOfChars < 140    // 10 Limit Value
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count > 9 ? 9 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell else {
            fatalError()
        }
        cell.imageView.image = images[indexPath.row]
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        //let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        //let originImage = cell.imageView.image// some image for baseImage

        let browser = SKPhotoBrowser(photos: SKImages)
        
         browser.initializePageIndex(indexPath.row)
         present(browser, animated: true, completion: {})
     
    }
    
    
    //照片选择完成的回调
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
                }
                
                
            }
        }
        group.notify(queue: .main){
            self.collectionView.reloadData()
        }
        
    }
    
    
    
    @objc func didTapCancelButton(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapPictureButton(){
        print("点击了图片按钮")
        var config = PHPickerConfiguration(photoLibrary: .shared())
        //最多选择9张
        config.selectionLimit = 9
        //只能选择照片
        config.filter = PHPickerFilter.images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
        
    }
    @objc func didTapLocationButton(){
        LocationMagager.shared.getUserLocation{[weak self] location in
            DispatchQueue.main.async {
                LocationMagager.shared.resolveLocationName(with: location) {[weak self] locationName in
                    self?.locationNameLabel.text = locationName
                    self?.locationIcon.isHidden = false
                }
            }
        }
    }
    
    @objc func didTapSendButton(){
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let date = Date()
        let dateStr = formatter.string(from: date)
        let source = UIDevice().type.rawValue
        let poster = LCApplication.default.currentUser
        let location = locationNameLabel.text
     
       
        
        guard let text = postTextView.text,!text.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Nothing entered", message: "Please enter the content and resend", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
      
         
        StorageManager.shared.uploadPostImage(images: images){ [weak self] url in
        
            var newPost = Post()
            newPost.title = self?.postTextView.text //内容
            newPost.images = url //图片
            newPost.time = dateStr //日期
            newPost.source = source //来源
            newPost.poster = poster
            newPost.location = location
            
            StorageManager.shared.newPost(post: newPost){ _ in
                print("上传成功")
                self?.animationContainer.isHidden = false
                self?.successAnimationView.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self?.navigationController?.popViewController(animated: true)
                }
                //self.navigationController?.popViewController(animated: true)
            }
    }
            print("输入后点击了发送按钮")
        
        
    }
    //键盘将要弹出时调整底部UI的位置
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            DispatchQueue.main.async {
                print("开始输入")
                self.bottomToolBar.snp.remakeConstraints{(make) in
                    make.left.equalTo(self.view.snp.left)
                    make.right.equalTo(self.view.snp.right)
                    make.bottom.equalTo(self.view.snp.bottom).offset(keyboardHeight * -1)
                    make.height.equalTo(40)
                }
            }
            
        }
    }
    //键盘将要收起时调整底部UI的位置
    @objc func keyboardWillHide() {
    
            DispatchQueue.main.async {
                print("结束输入")
                self.bottomToolBar.snp.remakeConstraints{(make) in
                    make.left.equalTo(self.view.snp.left)
                    make.right.equalTo(self.view.snp.right)
                    make.bottom.equalTo(self.view.snp.bottom)
                    make.height.equalTo(60)
                }
            }
    }
  
}


class PhotoCell: UICollectionViewCell {
    let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8.0
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
}
