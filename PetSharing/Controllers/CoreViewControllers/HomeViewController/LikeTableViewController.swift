//
//  LikeTableViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/12.
//

import UIKit
import LeanCloud

class LikeTableViewController: UITableViewController {

    var post:LCObject
    
    lazy var postLikers = [LCUser]()
    
    init(post:LCObject){
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(PostLikeTableViewCell.self, forCellReuseIdentifier: PostLikeTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        DispatchQueue.main.async {
            DatabaseManager.shared.getPostLikes(post: self.post) { [weak self] likers in
                if likers != nil {
                    self?.postLikers = likers!
                }
                //self.tableView.reloadData()

            }
        
        
        }
    
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
   
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postLikers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell:PostLikeTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostLikeTableViewCell.identifier, for: indexPath) as! PostLikeTableViewCell
    
        cell.configure(liker: postLikers[indexPath.row])
        cell.parent = self
        
        
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return 80
            
    }
   


}
