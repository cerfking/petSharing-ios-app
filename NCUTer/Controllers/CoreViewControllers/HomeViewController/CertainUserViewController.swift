//
//  CertainUserViewController.swift
//  NCUTer
//  Created by 陆华敬 on 2022/2/19.
//

import UIKit
import LeanCloud
import Kingfisher

class CertainUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    var presenter : SLPresenter = {
        let presenter = SLPresenter()
        return presenter
    }()
    var dataArray = NSMutableArray()
    var layoutArray = NSMutableArray()
    var user:LCUser
    //包含用户信息在内
    var certainUser:User?
    //关注状态
    var followState:FollowState?
    
    var pushedBy:UIViewController?
    
    init(user:LCUser){
        self.user = user
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    var tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CertainUserHeader.self, forHeaderFooterViewReuseIdentifier: CertainUserHeader.identifier)
        tableView.register(SLTableViewCell.self, forCellReuseIdentifier: "cellId")
        
        return tableView
        
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
    
    private let followUnfollowButton:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle("+Follow", for: .normal)
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.backgroundColor = .tertiaryLabel
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(didTapFollowUnfollowButton), for: .touchUpInside)
        return button
    }()
    
    @objc func didTapChatButton(){
        let vc = ChatViewController(user: user,conversation: nil)
        vc.title = certainUser?.nickname
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapFollowUnfollowButton(){
        switch followState {
        case .following:
            RelationshipManager.shared.unfollow(target: user)
            followState = .not_following
            followUnfollowButton.setTitle("+Follow", for: .normal)
            break
        case .not_following:
            RelationshipManager.shared.follow(target: user)
            followState = .following
            followUnfollowButton.setTitle("Unfollow", for: .normal)
            break
        default:
            break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(chatButton)
        view.addSubview(followUnfollowButton)
        tableView.delegate = self
        tableView.dataSource = self
        
        if user == LCApplication.default.currentUser {

            chatButton.isHidden = true
            followUnfollowButton.isHidden = true
            //tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            tableView.frame = view.bounds
        }
        else {

            tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 90)
            chatButton.isHidden = false
            followUnfollowButton.isHidden = false
        }

        presenter.getCertainUserData(user: user) { [weak self] (dataArray, layoutArray) in

            self?.dataArray = dataArray
            self?.layoutArray = layoutArray

            self?.tableView.reloadData()
        }
        presenter.fullTextBlock = {[weak self] (indexPath) in
            self?.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }
        
        DatabaseManager.shared.getUser(user: user){[weak self] user in
            guard let _ = user else {
                return
            }
            self?.certainUser = user
            //检查当前用户是否关注此用户
            RelationshipManager.shared.checkFollowState(user: user!){ state in
                switch state {
                case .following:
                    self?.followUnfollowButton.setTitle("Unfollow", for: .normal)
                    self?.followState = .following
                    break
                case .not_following:
                    self?.followUnfollowButton.setTitle("+Follow", for: .normal)
                    self?.followState = .not_following
                    break
                default:
                    break
                }
            }
        }
        
//        let index = (navigationController?.viewControllers.count)! - 2
//        pushedBy = navigationController?.viewControllers[index]
        
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        if let _ = pushedBy as? FollowListViewController{
//            tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height - 90)
//        }
//        else {
//            tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
//        }
        

        chatButton.snp.makeConstraints {make in
            make.left.equalToSuperview().offset(25)
            make.top.equalTo(tableView.snp.bottom).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(60)
        }
        followUnfollowButton.snp.makeConstraints{ make in
            make.left.equalTo(chatButton.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(chatButton).offset(10)
            make.height.equalTo(40)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SLTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SLTableViewCell
        if dataArray.count != 0 {
            
            guard let model:Post = dataArray[indexPath.section] as? Post else {
                print("错误")
                return UITableViewCell()
            }
            var layout:SLLayout?
            if indexPath.section <= layoutArray.count - 1 {
                layout = layoutArray[indexPath.section] as? SLLayout
            }
            cell.delegate = presenter
            cell.parent = self
            cell.cellIndexPath = indexPath
            cell.configureCell(model: model, layout: layout)
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let certainUserHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: CertainUserHeader.identifier) as! CertainUserHeader
            certainUserHeader.delegate = self
            if certainUser != nil{
                certainUserHeader.configure(user:certainUser!,postNumber: dataArray.count)
            }
            return certainUserHeader
        }
        else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section > layoutArray.count - 1 { return 0 }
        let layout : SLLayout = layoutArray[indexPath.section] as! SLLayout
        return layout.cellHeight
    }
    
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 240
        }
        else {
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
           return UIView()
       }
    
    //当tableview的style为grouped时，需同时设置viewForHeader和viewForFooter后,heightForHeader和heightForFooter的设置才会生效
       
}

extension CertainUserViewController:CertainUserHeaderDelegate{
    func certainUserHeaderDidTapFollowingNumberButton() {
        //var following = [User]()
        var states = [FollowState]()
        let group = DispatchGroup()
     
        RelationshipManager.shared.getFollowees(user: user){[weak self] followees in
            
            guard let _ = followees else {
                return
            }
     
            for followee in followees!{
                group.enter()
                RelationshipManager.shared.checkFollowState(user: followee){ state in
                    states.append(state!)
                    group.leave()
                }
             
            }
            group.notify(queue: .main){
                let vc = FollowListViewController(users: followees!, states: states)
                vc.title = "关注"
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func certainUserHeaderDidTapFollowerNumberButton() {
       // var followers = [User]()
        var states = [FollowState]()
        let group = DispatchGroup()
     
        RelationshipManager.shared.getFollowers(user: user){[weak self] followers in
            
            guard let _ = followers else {
                return
            }
            for follower in followers!{
                group.enter()
                RelationshipManager.shared.checkFollowState(user: follower){ state in
                    states.append(state!)
                    group.leave()
                }
            }
            group.notify(queue: .main){
                let vc = FollowListViewController(users: followers!, states: states)
                vc.title = "粉丝"
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

