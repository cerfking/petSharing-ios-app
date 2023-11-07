//
//  MeViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/13.
//

import UIKit
import LeanCloud
import SnapKit
import SafariServices


class MeViewController: UIViewController {
    
    private let profilePhotoImageView:UIImageView = {
        let profilePhotoImageView = UIImageView()
        profilePhotoImageView.layer.masksToBounds = true
       
        return profilePhotoImageView
    }()
    private let postsButton:UIButton = {
        let postsButton = UIButton()
        postsButton.setTitle("Post", for: .normal)
        postsButton.setTitleColor(.label, for: .normal)
        postsButton.backgroundColor = .secondarySystemBackground
        postsButton.titleEdgeInsets = UIEdgeInsets(top: 40, left: 10, bottom: 17, right: 10)
        //number label
        let postsNumberLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 89.3, height: 35))
        postsNumberLabel.text = "19"
        postsNumberLabel.font = UIFont(name: "Helvetica-Bold", size: 25)
        postsNumberLabel.textAlignment = .center
        postsNumberLabel.backgroundColor = .secondarySystemBackground
        postsButton.addSubview(postsNumberLabel)
        DispatchQueue.main.async {
            DatabaseManager.shared.getCertainUserPosts(user: LCApplication.default.currentUser!){ posts in
                postsNumberLabel.text = posts?.count.stringValue
            }
        }
        return postsButton
    }()
    private let followingButton:UIButton = {
        let followingButton = UIButton()
        followingButton.setTitle("Following", for: .normal)
        followingButton.titleEdgeInsets = UIEdgeInsets(top: 40, left: 10, bottom: 17, right: 10)
        followingButton.setTitleColor(.label, for: .normal)
        //关注数目
        let followingNumberLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 89.3, height: 35))
        followingNumberLabel.font = UIFont(name: "Helvetica-Bold", size: 25)
        followingNumberLabel.textAlignment = .center
        followingNumberLabel.backgroundColor = .secondarySystemBackground
        followingButton.addSubview(followingNumberLabel)
        DispatchQueue.main.async {
            RelationshipManager.shared.getFollowees(user:LCApplication.default.currentUser!){ followees in
                followingNumberLabel.text = followees?.count.stringValue
            }
        }
        followingButton.backgroundColor = .secondarySystemBackground
        return followingButton
    }()
    private let followersButton:UIButton = {
        let followersButton = UIButton()
        followersButton.setTitle("Followers", for: .normal)
        followersButton.setTitleColor(.label, for: .normal)
        followersButton.backgroundColor = .secondarySystemBackground
        followersButton.titleEdgeInsets = UIEdgeInsets(top: 40, left: 10, bottom: 17, right: 10)
        //粉丝数目
        let followersNumberLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 89.3, height: 35))
        followersNumberLabel.font = UIFont(name: "Helvetica-Bold", size: 25)
        followersNumberLabel.textAlignment = .center
        followersNumberLabel.backgroundColor = .secondarySystemBackground
        followersButton.addSubview(followersNumberLabel)
        DispatchQueue.main.async {
            RelationshipManager.shared.getFollowers(user:LCApplication.default.currentUser!){ followers in
                followersNumberLabel.text = followers?.count.stringValue
            }
        }
        return followersButton
    }()
    private let nameLabel:UILabel = {
        let nameLabel = UILabel()
        nameLabel.text = "RunningCoconut"
        nameLabel.font = nameLabel.font.withSize(25)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        return nameLabel
    }()
    private let bioLabel:UILabel = {
        let bioLabel = UILabel()
        bioLabel.text = "This used to be our playground"
        bioLabel.font = bioLabel.font.withSize(15)
        bioLabel.textColor = .label
        bioLabel.numberOfLines = 1
        return bioLabel
    }()
    
    private let extraFuncColletionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let size = (UIScreen.main.bounds.width - 20)/4
        layout.itemSize = CGSize(width: size, height: size)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.layer.masksToBounds = true
        collectionView.layer.cornerRadius = 5.0
        collectionView.register(ExtraFuncCollectionViewCell.self, forCellWithReuseIdentifier: ExtraFuncCollectionViewCell.identifier)
        return collectionView
    }()
    private var cellModel = [ExtraFuncModel]()
  
    private func addSubviews(){
        view.addSubview(profilePhotoImageView)
        view.addSubview(postsButton)
        view.addSubview(followingButton)
        view.addSubview(followersButton)
        view.addSubview(nameLabel)
        view.addSubview(bioLabel)
        view.addSubview(extraFuncColletionView)
    }
    private func addButtonActions(){
        postsButton.addTarget(self, action: #selector(didTapPostsButton), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
        followersButton.addTarget(self, action: #selector(didTapFollowersButton), for: .touchUpInside)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePhoto))
        profilePhotoImageView.isUserInteractionEnabled = true
        profilePhotoImageView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    private func configureModel(){
        cellModel.append(ExtraFuncModel(title: "Map", imageName: "ditu"){[weak self] in
            let vc = CampusMapViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            
        })
        cellModel.append(ExtraFuncModel(title: "Classifier", imageName: "垃圾分类"){ [weak self] in
            let vc = GarbageClassificationViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        cellModel.append(ExtraFuncModel(title: "Website", imageName: "学校官网"){ [weak self] in
            guard let url = URL(string: "http://www.ncut.edu.cn") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            self?.present(vc, animated: true)
        })
        cellModel.append(ExtraFuncModel(title: "Wallet", imageName: "钱包"){[weak self] in
            let vc = NewWalletViewController()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
            print("以太坊钱包")
            
        })
        
    }
    
    @objc func didTapProfilePhoto() {
        let vc = CertainUserViewController(user: LCApplication.default.currentUser!)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapPostsButton() {
        let vc = CertainUserViewController(user: LCApplication.default.currentUser!)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapFollowersButton() {
        var follower = [User]()
        var states = [FollowState]()
        let group = DispatchGroup()
     
        RelationshipManager.shared.getFollowers(user: LCApplication.default.currentUser!){[weak self] followers in
            follower = followers!
            for a in follower{
                group.enter()
                RelationshipManager.shared.checkFollowState(user: a){ state in
                    states.append(state!)
                    group.leave()
                }
            }
            group.notify(queue: .main){
                let vc = FollowListViewController(users: follower, states: states)
                vc.title = "粉丝"
                vc.hidesBottomBarWhenPushed = true
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
                                
            }
                
        }
    }
    
    @objc func didTapFollowingButton() {
        var following = [User]()
        var states = [FollowState]()
        let group = DispatchGroup()
     
        RelationshipManager.shared.getFollowees(user: LCApplication.default.currentUser!){[weak self] followees in
     
            following = followees!
            for followee in following{
                group.enter()
                RelationshipManager.shared.checkFollowState(user: followee){ state in
                    states.append(state!)
                    group.leave()
                }
             
            }
            group.notify(queue: .main){
                let vc = FollowListViewController(users: following, states: states)
                vc.hidesBottomBarWhenPushed = true
                vc.title = "关注"
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
                                
            }
                
        }
        
    }
    
    @objc func didTapSettingButton(){
        let vc = SettingViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.title = "设置"
        navigationController?.pushViewController(vc, animated: true )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        addButtonActions()
        configureModel()
        view.backgroundColor = .secondarySystemBackground
        title = "Me"
        //将半透明设置为false后布局将从navigationbar底部开始，不会遮挡内容
        //navigationController?.navigationBar.isTranslucent = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettingButton))
        
        extraFuncColletionView.delegate = self
        extraFuncColletionView.dataSource = self
        
        DatabaseManager.shared.getUser(user:LCApplication.default.currentUser!){[weak self] user in
            self?.nameLabel.text = user?.nickname
            self?.bioLabel.text = user?.bio
            self?.profilePhotoImageView.sd_setImage(with: user?.profilePhoto)
  
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        
        
        let profilePhotoSize = view.width/4
        profilePhotoImageView.layer.cornerRadius = profilePhotoSize/2.0
        profilePhotoImageView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(profilePhotoSize)
            make.top.equalTo(navigationController!.navigationBar.snp.bottom)
            make.height.equalTo(profilePhotoSize)
        }
        let buttonHeight = profilePhotoSize - 25
        postsButton.frame = CGRect(x: 1 , y: profilePhotoImageView.bottom + 12, width: (view.width-2)/3, height: buttonHeight)
        followingButton.frame = CGRect(x: postsButton.right , y: profilePhotoImageView.bottom + 12, width: (view.width-2)/3, height: buttonHeight)
        followersButton.frame = CGRect(x: followingButton.right , y: profilePhotoImageView.bottom + 12, width: (view.width-2)/3, height: buttonHeight)
        nameLabel.frame = CGRect(x: 8 + profilePhotoImageView.right , y: profilePhotoImageView.top , width: view.width-10, height: 50).integral
        let bioLabelSize = bioLabel.sizeThatFits(view.frame.size)
        bioLabel.snp.makeConstraints{ make in
            make.left.equalTo(profilePhotoImageView.snp.right).offset(8)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.width.equalTo(view.width - 10)
            make.height.equalTo(bioLabelSize.height)
        }
//        bioLabel.frame = CGRect(x: 8 + profilePhotoImageView.right , y: nameLabel.bottom, width: view.width-10, height: bioLabelSize.height).integral
//
        extraFuncColletionView.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(postsButton.snp.bottom)
            make.height.equalTo((UIScreen.main.bounds.width - 20)/2)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isTranslucent = true
    }
}

extension MeViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row <= 3 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExtraFuncCollectionViewCell.identifier, for: indexPath) as! ExtraFuncCollectionViewCell
            cell.configure(model:cellModel[indexPath.row])
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExtraFuncCollectionViewCell.identifier, for: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < 4 {
            cellModel[indexPath.row].handler()
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
}
