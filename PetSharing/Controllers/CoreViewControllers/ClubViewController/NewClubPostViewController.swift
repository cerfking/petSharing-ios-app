//
//  NewClubPostViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/14.
//

import UIKit
import SnapKit
import Photos
import PhotosUI
import SKPhotoBrowser
import LeanCloud

class NewClubPostViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, PHPickerViewControllerDelegate,UITextViewDelegate {
   
    
    private let clubName:String
    private var images = [UIImage]()
    private var SKImages = [SKPhoto]()

    
    
    init(clubName:String){
        self.clubName = clubName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let titleTextView:UITextView = {
        let titleTextView = UITextView()
        titleTextView.font = UIFont.systemFont(ofSize: 18)
        titleTextView.translatesAutoresizingMaskIntoConstraints = true
        titleTextView.sizeToFit()
        titleTextView.text = "Title"
        titleTextView.textColor = UIColor.lightGray
        titleTextView.isScrollEnabled = false
        titleTextView.isEditable = true
        return titleTextView
    }()
    
    private let seperateLine:UIView = {
        let seperateLine = UIView()
        seperateLine.backgroundColor = .systemGray
        return seperateLine
    }()
    
    
    private let postTextView:UITextView = {
        let postTextView = UITextView()
        postTextView.font = UIFont.systemFont(ofSize: 18)
        postTextView.translatesAutoresizingMaskIntoConstraints = true
        postTextView.sizeToFit()
        postTextView.text = "Enter your content here..."
        postTextView.textColor = UIColor.lightGray
        postTextView.isScrollEnabled = false
        postTextView.isEditable = true
        postTextView.isUserInteractionEnabled = true
        return postTextView
    }()
    
    private let pictureButton:UIButton = {
        let pictureButton = UIButton()
        pictureButton.setImage(UIImage(systemName: "photo"), for: .normal)
        pictureButton.tintColor = .label
        pictureButton.addTarget(self, action: #selector(didTapPictureButton), for: .touchUpInside)
        return pictureButton
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
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = .systemBackground
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
       // navigationController?.navigationBar.isTranslucent = false
        let sendButton = UIButton()
        sendButton.frame.size = CGSize(width: 80, height: 25)
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = .systemGreen
        sendButton.layer.cornerRadius = 17
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancelButton))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendButton)
        title = "New Post"
        view.addSubview(pictureButton)
        view.addSubview(scrollView)
        
        
        scrollView.addSubview(titleTextView)
        
        scrollView.addSubview(seperateLine)

        scrollView.addSubview(postTextView)
     
        scrollView.addSubview(collectionView)
       
        collectionView.isHidden = true
        collectionView.dataSource = self
        collectionView.delegate = self
        postTextView.delegate = self
        titleTextView.delegate = self
   
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
  
        scrollView.snp.makeConstraints{ make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(view).offset(94)
            make.bottom.equalTo(view).offset(-50)
        }
        
        pictureButton.snp.makeConstraints{ make in
            make.left.equalTo(view).offset(15)
            make.width.equalTo(60)
            make.top.equalTo(scrollView.snp.bottom)
            make.height.equalTo(40)
        }
      
        titleTextView.snp.makeConstraints{ make in
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            make.top.equalTo(scrollView).offset(5).priority(.high)
           
        }
        
        seperateLine.snp.makeConstraints{ make in
            make.left.equalTo(titleTextView)
            make.right.equalTo(titleTextView)
            make.top.equalTo(titleTextView.snp.bottom).priority(.high)
            make.height.equalTo(2)
        }
        

        postTextView.snp.remakeConstraints{(make) in
            make.left.equalTo(view).offset(15)
            make.right.equalTo(view).offset(-15)
            //make.top.equalTo(scrollView).priority(.high)
            make.top.equalTo(seperateLine.snp.bottom).priority(.high)
            

        }
        
        
        scrollView.contentSize = CGSize(width: view.width, height: titleTextView.height + postTextView.height + 100 + collectionView.height)
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return images.count > 9 ? 9 : images.count
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
        //let cell = collectionView.cellForItem(at: indexPath) as! PhotoCell
        //let originImage = cell.imageView.image// some image for baseImage

        let browser = SKPhotoBrowser(photos: SKImages)
         browser.initializePageIndex(indexPath.section)
         present(browser, animated: true, completion: {})
     
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = UIColor.lightGray
            if textView == postTextView {
                textView.text = "Enter your content here..."
            }
            else if textView == titleTextView {
                textView.text = "Title"
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
                   
                }
                
                
            }
        }
        group.notify(queue: .main){
            self.collectionView.reloadData()
            self.collectionView.snp.remakeConstraints{(make) in
                let photoWidth = UIScreen.main.bounds.width - 15 * 2
                make.left.equalTo(self.view).offset(15)
                make.right.equalTo(self.view).offset(-15)
                make.top.equalTo(self.postTextView.snp.bottom).offset(20).priority(.high)
                let result = ((self.images.count - 1)/3 + 1) * Int(photoWidth)/3
                make.height.equalTo(result)
               

            }
        }
        
    }
    
    
    
    @objc func didTapCancelButton(){
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapPictureButton(){
        print("点击了图片按钮")
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 0
        //只能选择照片
        config.filter = PHPickerFilter.images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    @objc func didTapSendButton(){
        guard let title = titleTextView.text,!title.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "No title entered", message: "Please enter a title and resend", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        guard let content = titleTextView.text,!content.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "No content entered", message: "Please enter the content and resend", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
      
         
        StorageManager.shared.uploadPostImage(images: images){ [weak self] url in
        
            var newClubPost = ClubPost()
            newClubPost.title = self?.titleTextView.text
            if url.count != 0 {
                newClubPost.images = url //图片
            }
            newClubPost.poster = LCApplication.default.currentUser
            newClubPost.club = self?.clubName
        
            StorageManager.shared.newClubPost(clubPost: newClubPost){ _ in
                print("上传成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
            print("输入后点击了发送按钮")
        }
    
    
  
}



    
    

