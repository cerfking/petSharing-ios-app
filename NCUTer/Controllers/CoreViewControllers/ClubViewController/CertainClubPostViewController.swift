//
//  CertainClubPostViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/15.
//

import UIKit
import SnapKit
import SDWebImage
import LeanCloud
import SKPhotoBrowser

class CertainClubPostViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    private var clubPost:ClubPost
    
    private var commentsList:CommentTableViewController?
    
    init(clubPost:ClubPost){
        self.clubPost = clubPost
        self.commentsList = CommentTableViewController(post: LCObject(objectId: clubPost.clubPostId!))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imagesURL = [String]()
    
    private var SKImages = [SKPhoto]()
    
    private let profileImageView:UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.image = UIImage(named: "profile")
        return profileImageView
    }()
    
    private let nickNameLabel:UILabel = {
        let nickNameLabel = UILabel()
        return nickNameLabel
    }()
    
    private let postLabel:UILabel = {
        let postLabel = UILabel()
        postLabel.text = "Posted by"
        postLabel.font = .systemFont(ofSize: 13)
        postLabel.textColor = .systemGray
        return postLabel
    }()
    
    private let timeLabel:UILabel = {
        let timeLabel = UILabel()
        timeLabel.text = "2022-03-12"
        timeLabel.textColor = .systemGray
        return timeLabel
    }()
    
    private let titleTextView:UITextView = {
        let titleTextView = UITextView()
        titleTextView.isScrollEnabled = false
        titleTextView.isEditable = false
        titleTextView.translatesAutoresizingMaskIntoConstraints = true
        titleTextView.sizeToFit()
        titleTextView.font = .systemFont(ofSize: 25, weight: .bold)
        return titleTextView
    }()
    
    private let contentTextView:UITextView = {
        let contentTextView = UITextView()
        contentTextView.isScrollEnabled = false
        contentTextView.isEditable = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = true
        contentTextView.sizeToFit()
        //设置行间距
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        contentTextView.attributedText = NSAttributedString(string: contentTextView.text, attributes: attributes)
        contentTextView.font = .systemFont(ofSize: 16)
        contentTextView.isHidden = true
        return contentTextView
    }()
    //显示照片
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 10 * 2 - 2 * 2) / 3
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .systemBackground
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let commentLabel:UILabel = {
        let commentLabel = UILabel()
        commentLabel.text = "Comments"
        commentLabel.font = .systemFont(ofSize: 15)
        commentLabel.textColor = .systemGray
        return commentLabel
    }()
    
    //评论按钮
    private let commentButton:UIButton = {
        let commentButton = UIButton()
        commentButton.layer.masksToBounds = true
        commentButton.layer.cornerRadius = 30
        let image = UIImage(named: "newClubPost")
        commentButton.setImage(image, for: .normal)
        commentButton.imageView?.contentMode = .scaleAspectFill
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        return commentButton
    }()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    @objc func didTapCommentButton(){
        let vc = CommentPostViewController(post: LCObject(objectId: clubPost.clubPostId!))
        vc.title = "Comment"
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Comment", style: .plain, target: self, action: #selector(didTapCommentButton))
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(nickNameLabel)
        scrollView.addSubview(postLabel)
        scrollView.addSubview(timeLabel)
        scrollView.addSubview(titleTextView)
        scrollView.addSubview(contentTextView)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(commentLabel)
        //评论列表
        scrollView.addSubview(commentsList!.view)
        addChild(self.commentsList!)
        commentsList!.didMove(toParent: self)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        scrollView.frame = view.bounds
        
        titleTextView.text = clubPost.title
        
        if clubPost.content != nil {
            contentTextView.isHidden = false
            contentTextView.text = self.clubPost.content
        }
        
        if clubPost.images != nil {
            collectionView.isHidden = false
            imagesURL = clubPost.images!
            for image in clubPost.images! {
                SKImages.append(SKPhoto.photoWithImageURL(image))
            }
        }
        
        guard let _ = clubPost.poster else {
            print("出错")
            return
        }
        
        DatabaseManager.shared.getUser(user: clubPost.poster!){ [weak self] user in
            self?.nickNameLabel.text = user?.nickname
            self?.profileImageView.sd_setImage(with: user?.profilePhoto, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
        
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //scrollView.frame = view.bounds
        profileImageView.snp.makeConstraints{ make in
            make.left.equalTo(view).offset(10)
            make.width.equalTo(40)
            make.top.equalTo(scrollView).offset(10)
            make.height.equalTo(40)
        }
        nickNameLabel.snp.makeConstraints{ make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.top.equalTo(profileImageView)
            make.height.equalTo(20)
        }
        postLabel.snp.makeConstraints{ make in
            make.left.equalTo(nickNameLabel)
            make.top.equalTo(nickNameLabel.snp.bottom)
            make.height.equalTo(20)
        }
        timeLabel.snp.makeConstraints{ make in
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(profileImageView)
            make.height.equalTo(20)
        }
        titleTextView.snp.makeConstraints{ make in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(profileImageView.snp.bottom).offset(20).priority(.high)
        }
        contentTextView.snp.makeConstraints{ make in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(titleTextView.snp.bottom).offset(40).priority(.high)
        }
        
        collectionView.snp.remakeConstraints{(make) in
            make.left.equalTo(view).offset(10)
            make.right.equalTo(view).offset(-10)
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            let singleHeight = Int((UIScreen.main.bounds.width - 10 * 2) / 3)
            let height = ((imagesURL.count - 1)/3 + 1) * singleHeight
            make.height.equalTo(height)

        }
        
        commentLabel.snp.makeConstraints{ make in
            make.left.equalTo(collectionView).offset(10)
            make.top.equalTo(collectionView.snp.bottom).offset(23)
            make.height.equalTo(20)
        }
        
        commentsList?.view.snp.makeConstraints{ make in
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.top.equalTo(collectionView.snp.bottom).offset(40)
            make.height.equalTo(view.height - (170 + titleTextView.height + contentTextView.height + collectionView.height)).priority(.high)
           
        }
        
        
        scrollView.contentSize = CGSize(width: view.width, height: titleTextView.height + contentTextView.height + 500 + collectionView.height + commentsList!.view.height)
        
    
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        return imagesURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PhotoCell else {
            fatalError()
        }
        cell.imageView.sd_setImage(with: URL(string:imagesURL[indexPath.row]),placeholderImage: UIImage(named: "placeholderImage"))
        
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true, completion: {})
    }
    
}


    
    

