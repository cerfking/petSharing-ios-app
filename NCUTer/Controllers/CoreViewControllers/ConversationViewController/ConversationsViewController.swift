//
//  ConversationsViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/14.
//

import UIKit
import JGProgressHUD
import LeanCloud

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [IMConversation]()

    private let conversationsTableView:UITableView = {
        let conversationsTableView = UITableView()
        conversationsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        conversationsTableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        conversationsTableView.isHidden = false
        return conversationsTableView
    }()
    
    private let noConversationsLabel:UILabel = {
        let label = UILabel()
        label.text = "No Message"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(conversationsTableView)
        conversationsTableView.delegate = self
        conversationsTableView.dataSource = self
        title = "Message"
        ConversationManager.shared.getAllConversations{[weak self] conversations in
            guard let _ = conversations else {
                print("Not found")
                return
            }
            
            self?.conversations = conversations!
            DispatchQueue.main.async {
                self?.conversationsTableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("newMessageReceived"), object: nil, queue: .main, using: {[weak self] _ in
            self?.conversationsTableView.reloadData()
        })
  
        // Do any additional setup after loading the view.
    }
    
    
    
    override func viewDidLayoutSubviews() {
        conversationsTableView.frame = view.bounds
    }
    
//    @objc func didTapNewConversationButton(){
//        let vc = NewConversationViewController()
//        vc.completion = { [weak self] result in
//            self?.createNewConversation(results: result)
//        }
//        let navVC = UINavigationController(rootViewController: vc)
//        self.present(navVC, animated: true)
//    }
//
//    private func createNewConversation(results:LCUser) {
//        var nickname:String?
//        DatabaseManager.shared.getUser(user: results){ user in
//            nickname = user?.nickname
//            let vc = ChatViewController(user: results,conversation: nil)
//            vc.title = nickname
//            vc.navigationItem.largeTitleDisplayMode = .never
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//
//    }
   
    

}

extension ConversationsViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 1
        return conversations.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let conversation = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(conversation: conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        
        let objectId:String
        if conversation.members![0] == LCApplication.default.currentUser?.objectId?.stringValue {
            objectId = conversation.members![1]
        }
        else {
            objectId = conversation.members![0]
        }
        DatabaseManager.shared.getUser(user: LCUser(objectId: objectId)){ [weak self] user in
            let vc = ChatViewController(user: LCUser(objectId: objectId),conversation: conversation)
            vc.title = user?.nickname
            vc.navigationItem.largeTitleDisplayMode = .never
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


