//
//  CertainCommodityViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/17.
//

import UIKit
import Alamofire
import ARKit
import QuickLook
import RealityKit
import SnapKit
import CHTCollectionViewWaterfallLayout
import SKPhotoBrowser
import LeanCloud

class CertainCommodityViewController: UIViewController,QLPreviewControllerDataSource,CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDelegate,UICollectionViewDataSource {
   
    private var commodity:Commodity
    
    private var modelURL:URL?
    
    private var SKImages = [SKPhoto]()
    
    private var heights = [CGFloat]()
    
    init(commodity:Commodity) {
        self.commodity = commodity
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let profileImageView:UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.image = UIImage(named: "profile")
        return profileImageView
    }()
    
    private let nicknameLabel:UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let priceLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .systemRed
        return label
    }()
    
    private let detailTextView:UITextView = {
        let detailTextView = UITextView()
        detailTextView.isScrollEnabled = false
        detailTextView.isEditable = false
        detailTextView.sizeToFit()
        detailTextView.translatesAutoresizingMaskIntoConstraints = true
        return detailTextView
    }()
    
    private let collectionView:UICollectionView = {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = 1
        let collectionView = UICollectionView(frame: .init(), collectionViewLayout: layout)
        collectionView.register(CommodityPicCollectionViewCell.self, forCellWithReuseIdentifier: CommodityPicCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let previewModelButton:UIButton = {
        let button = UIButton()
        button.setTitle(" Preview", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setImage(UIImage(systemName: "arkit"), for: .normal)
        button.backgroundColor = .systemBackground
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(didTapPreviewModelButton), for: .touchUpInside)
        return button
    }()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = .systemBackground
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        return scrollView
    }()
    
    private let chatButton:UIButton = {
        let button = UIButton()
        button.setTitle("Chat", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.titleEdgeInsets = UIEdgeInsets(top: 20, left: -25, bottom: -5, right: 0)   //正缩负扩
        button.setImage(UIImage(systemName: "bubble.left.and.bubble.right"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 20, right: 2)
        button.tintColor = .secondaryLabel
        button.addTarget(self, action: #selector(didTapChatButton), for: .touchUpInside)
        return button
    }()
    
    private let purchaseButton:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle("Purchase", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemOrange
        button.layer.cornerRadius = 20
        return button
    }()
    
    @objc func didTapChatButton(){
        if commodity.seller != LCApplication.default.currentUser {
            let vc = ChatViewController(user: commodity.seller!,conversation: nil)
            vc.title = nicknameLabel.text
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
        else {
            print("不能与自己聊天")
        }
    }
    
    @objc func didTapPreviewModelButton(){
        
        CacheManager.shared.clearAllModelFilesFromDirectory()
        guard let _ = commodity.modelURL else {
            print("Not availabel")
            let alert = UIAlertController(title: nil, message: "Not availabel", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        

        AF.download(commodity.modelURL!, to: destination).responseURL{ [weak self] response in
            self?.modelURL = response.fileURL
            let previewController = QLPreviewController()
            previewController.dataSource = self
            self?.present(previewController, animated: true, completion: nil)
        }
        
        
        
    }
    
    private func setupUI(){
        guard let _ = commodity.seller else {
            return
        }
        DatabaseManager.shared.getUser(user: commodity.seller!){ [weak self] user in
            self?.profileImageView.sd_setImage(with: user?.profilePhoto)
            self?.nicknameLabel.text = user?.nickname
        }
        detailTextView.text = commodity.detail
        //设置行间距
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : style]
        detailTextView.attributedText = NSAttributedString(string: detailTextView.text, attributes: attributes)
        detailTextView.font = .systemFont(ofSize: 15)
        
        priceLabel.text = "$\(commodity.price!)"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        //navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .systemBackground
        scrollView.addSubview(previewModelButton)
        view.addSubview(scrollView)
        scrollView.addSubview(profileImageView)
        scrollView.addSubview(nicknameLabel)
        scrollView.addSubview(priceLabel)
        scrollView.addSubview(detailTextView)
        scrollView.addSubview(collectionView)
        view.addSubview(chatButton)
        view.addSubview(purchaseButton)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupUI()
        


        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.snp.makeConstraints{ make in
            make.left.right.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-90)
        }
        
        profileImageView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(15)
            make.width.height.equalTo(40)
            make.top.equalToSuperview().offset(10)
        }
        
        nicknameLabel.snp.makeConstraints{ make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.top.equalTo(profileImageView).offset(10)
        }
        
        priceLabel.snp.makeConstraints{ make in
            make.left.equalTo(profileImageView)
            make.top.equalTo(profileImageView.snp.bottom).offset(50)
        }
        
        detailTextView.snp.makeConstraints{ make in
            make.left.equalTo(profileImageView)
            make.right.equalTo(view).offset(-15)
            make.top.equalTo(priceLabel.snp.bottom).offset(20).priority(.high)
        }
        
        collectionView.snp.makeConstraints{ make in
            make.top.equalTo(detailTextView.snp.bottom).offset(30).priority(.high)
            make.height.equalTo(300 * commodity.imagesURL!.count)
            make.left.equalTo(profileImageView)
            make.right.equalTo(detailTextView)
        }
        
        previewModelButton.snp.makeConstraints{ make in
            make.right.equalTo(detailTextView).offset(-15)
            //make.width.equalTo(100)
            make.top.equalTo(priceLabel)
            make.bottom.equalTo(priceLabel)
        }
        
        chatButton.snp.makeConstraints {make in
            make.left.equalToSuperview().offset(25)
            make.top.equalTo(scrollView.snp.bottom).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(60)
        }
        purchaseButton.snp.makeConstraints{ make in
            make.left.equalTo(chatButton.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(chatButton).offset(10)
            make.height.equalTo(40)
        }
        
        scrollView.contentSize = CGSize(width: view.width, height: 110 + collectionView.height + detailTextView.height + priceLabel.height + profileImageView.height)
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let _ = modelURL else {
            fatalError()
        }
        let previewItem = ARQuickLookPreviewItem(fileAt: modelURL!)
        previewItem.canonicalWebPageURL = URL(string: "https://developer.apple.com/augmented-reality/quick-look/models/vintagerobot2k/")
        previewItem.allowsContentScaling = false
        return previewItem
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return commodity.imagesURL!.count
        //return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommodityPicCollectionViewCell.identifier, for: indexPath) as? CommodityPicCollectionViewCell else {
            fatalError()
        }
        let url = URL(string: commodity.imagesURL![indexPath.row])
        SKImages.append(SKPhoto.photoWithImageURL(commodity.imagesURL![indexPath.row]))
        cell.configure(picURL: url!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.width - 30, height: 300)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let browser = SKPhotoBrowser(photos: SKImages)
        browser.initializePageIndex(indexPath.row)
        present(browser, animated: true)
    }
    
}
