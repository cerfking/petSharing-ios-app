//
//  TableViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/11.
//

import UIKit
import LeanCloud

class CommentTableViewController: UITableViewController {
    
    var post:LCObject
    
    lazy var postComments = [PostComment]()
    
    init(post:LCObject){
        self.post = post
        super.init(nibName: nil, bundle: nil)
      
        DatabaseManager.shared.getPostComments(post: post) { [self] comments in
            print("调用")
            if comments != nil {
                postComments = comments!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.register(PostCommentTableViewCell.self, forCellReuseIdentifier: PostCommentTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
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
        return postComments.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell:PostCommentTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostCommentTableViewCell.identifier, for: indexPath) as! PostCommentTableViewCell
    
        cell.configure(comment: (postComments[indexPath.row]))
        cell.parent = self
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
       return UITableView.automaticDimension
            
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }

}
