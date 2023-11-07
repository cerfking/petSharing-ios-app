//
//  FollowListViewController.swift
//  Instagram
//
//  Created by 陆华敬 on 2021/9/17.
//

import UIKit
import LeanCloud

class FollowListViewController: UIViewController {
    //private let data:[UserRelationship]
    private let users:[User]
    
    private let states:[FollowState]

    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(FollowTableViewCell.self, forCellReuseIdentifier: FollowTableViewCell.identifier)
        return tableView
    }()
    init(users:[User],states:[FollowState]){
        self.users = users
        self.states = states
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        view.backgroundColor = .systemBackground

        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    

    
}
extension FollowListViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowTableViewCell.identifier,for: indexPath) as! FollowTableViewCell

        cell.configure(with: states[indexPath.row],user: users[indexPath.row])
       // cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = LCUser(objectId:users[indexPath.row].objectId as! LCStringConvertible)
        let destinationVC = CertainUserViewController(user:user)
        destinationVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

