 //
//  ViewController.swift
//  Instagram
//
//  Created by 陆华敬 on 2021/9/17.
//
import LeanCloud
import UIKit
import SnapKit
import Kingfisher

class HomeViewController: UIViewController {
 
    var isStatusBarHidden = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return isStatusBarHidden
        }
    }
    
     var tableView:UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGroupedBackground
        //tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(SLTableViewCell.self, forCellReuseIdentifier: "cellId")
        
        
        return tableView
        
    }()
    
    var presenter : SLPresenter = {
        let presenter = SLPresenter()
        return presenter
    }()
    var dataArray = NSMutableArray()
    var layoutArray = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Release to update")
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        
        navigationItem.title = "Home"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"), style: .done, target: self, action: #selector(didTapNewPostButton))
        navigationItem.rightBarButtonItem?.tintColor = .systemOrange
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "ClearCache", style: UIBarButtonItem.Style.done, target: self, action: #selector(clearCache))
        
        //中间者 处理数据和事件
        presenter.getData { [weak self] (dataArray, layoutArray) in

            self?.dataArray = dataArray
            self?.layoutArray = layoutArray

            self?.tableView.reloadData()
        }
        presenter.fullTextBlock = {[weak self] (indexPath) in
            self?.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
        }
        //限制内存高速缓存大小为50MB
        ImageCache.default.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        //限制内存缓存最多可容纳150张图像
        ImageCache.default.memoryStorage.config.countLimit = 150
        
        view.addSubview(tableView)
        
        // Do any additional setup after loading the view.
        
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = CGRect(x: 0, y: -5, width: view.width, height: view.height + 5)
    }
    

    @objc func clearCache() {
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            print("图片清除缓存完毕")
        }
    }
    
    @objc func refresh() {
        presenter.getData { [weak self] (dataArray, layoutArray) in
            self?.dataArray = dataArray
            self?.layoutArray = layoutArray
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        presenter.fullTextBlock = {[weak self] (indexPath) in
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
        }
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            print("结束刷新")
        }
    }
    
    @objc func didTapNewPostButton(){
        let vc = NewPostViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.title = "New Post"
        navigationController?.pushViewController(vc, animated: true )
        
       }
    
}
 extension HomeViewController:UITableViewDelegate,UITableViewDataSource{
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
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
        if indexPath.section > layoutArray.count - 1 { return 0 }
        let layout : SLLayout = layoutArray[indexPath.section] as! SLLayout
        return layout.cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }

    
  
    
 }
 
 

