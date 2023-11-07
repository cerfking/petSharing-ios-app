//
//  CertainPostViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/7.
//

import UIKit
import LeanCloud
import SnapKit
import Kingfisher

class CertainPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var presenter : SLPresenter = {
        let presenter = SLPresenter()
        return presenter
    }()
    var dataArray = NSMutableArray()
    var layoutArray = NSMutableArray()
    
    var post:LCObject
    var commentsList:CommentTableViewController?
    var likesList:LikeTableViewController?
    
    
    init(post:LCObject){
        self.post = post
        self.commentsList = CommentTableViewController(post: post)
        self.likesList = LikeTableViewController(post: post)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    var tableView:UITableView = {
        let tableView = UITableView()
        tableView.register(SLTableViewCell.self, forCellReuseIdentifier: "cellId")
        //tableView.register(PostCommentTableViewCell.self, forCellReuseIdentifier: PostCommentTableViewCell.identifier)
        return tableView
    }()
    
    private let commentButton:UIButton = {
        let commentButton = UIButton()
        commentButton.setTitle("Comments", for: .normal)
        commentButton.setTitleColor(.label, for: .normal)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        
        return commentButton
    }()
    
    private let likeButton:UIButton = {
        let likeButton = UIButton()
        likeButton.setTitle("Likes", for: .normal)
        likeButton.setTitleColor(.label, for: .normal)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
       
        return likeButton
    }()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.backgroundColor = .systemBackground
        scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        return scrollView
    }()
    
    
    let group = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
        //具体的发布内容
        scrollView.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        //评论列表
        scrollView.addSubview(commentsList!.view)
        addChild(commentsList!)
        commentsList!.didMove(toParent: self)
        //评论按钮，显示评论数
        scrollView.addSubview(commentButton)
        

        commentButton.removeTarget(self, action: #selector(didTapCommentButton), for: .allEvents)
        //点赞按钮，显示点赞数
        scrollView.addSubview(likeButton)

        group.enter()
      
          
        presenter.getCertainPost(post: post) { [weak self] (dataArray, layoutArray) in
            self?.dataArray = dataArray
            self?.layoutArray = layoutArray
            self?.tableView.reloadData()
            self?.group.leave()
        }
        
        presenter.fullTextBlock = { [weak self] (indexPath) in
            self?.tableView.reloadData()
            
        }
        
        
       
        
        //限制内存高速缓存大小为50MB
        ImageCache.default.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        //限制内存缓存最多可容纳150张图像
        ImageCache.default.memoryStorage.config.countLimit = 150
   
    }
    
    @objc func didTapLikeButton(){
        scrollView.willRemoveSubview(commentsList!.view)
        scrollView.addSubview(likesList!.view)
        addChild(likesList!)
        likesList!.didMove(toParent: self)
    }
    
    @objc func didTapCommentButton(){
        scrollView.willRemoveSubview(likesList!.view)
        scrollView.addSubview(commentsList!.view)
    }
    
   
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        group.notify(queue: .main){
            let layout : SLLayout = self.layoutArray[0] as! SLLayout
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: layout.cellHeight)
            //self.commentButton.frame = CGRect(x: 0, y: 0, width: 80, height: 90)
            self.commentsList!.view.frame = CGRect(x: 0, y: self.tableView.height + 40, width: self.view.width, height: self.view.height - self.tableView.height - 40)
            self.likesList!.view.frame = self.commentsList!.view.frame
            //self.scrollView.contentSize = CGSize(width: self.view.width, height: self.view.height + self.tableView.height)
            
           
        }
   
    }
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell:SLTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SLTableViewCell
            cell.parent = self
        
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
            cell.cellIndexPath = indexPath
            cell.configureCell(model: model, layout: layout)
            
            }
            return cell
    }
    
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let layout : SLLayout = layoutArray[indexPath.section] as! SLLayout
        group.notify(queue: .main){
            let layout : SLLayout = self.layoutArray[0] as! SLLayout
            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.width, height: layout.cellHeight)
            self.commentButton.frame = CGRect(x: 10, y: layout.cellHeight, width: 90, height: 40)
            self.likeButton.frame = CGRect(x: 90, y: layout.cellHeight, width: 80, height: 40)
            self.commentsList!.view.frame = CGRect(x: 0, y: self.tableView.height + 40, width: self.view.width, height: self.view.height  - 130)
            self.likesList!.view.frame = self.commentsList!.view.frame
            self.scrollView.contentSize = CGSize(width: self.view.width, height:  self.tableView.height + 40 + (self.commentsList?.view.height)! - 35)
            
        }
       
        return layout.cellHeight
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            return 44
    
    }

}


