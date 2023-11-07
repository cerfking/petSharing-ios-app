//
//  NewConversationViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/19.
//

import UIKit
import JGProgressHUD
import LeanCloud

class NewConversationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    public var completion:((LCUser) -> (Void))?
    
    private let spinner = JGProgressHUD()
    
    private let searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "查找用户..."
        return searchBar
    }()
    
    private let tableView:UITableView = {
        let table = UITableView()
        //table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let noResultsLabel:UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchBar.delegate = self
        //navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .done, target: self, action: #selector(didTapCancelButton))
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        //searchBar.becomeFirstResponder()

       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func didTapCancelButton(){
        dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "complezing"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUser = LCUser(objectId: "61c86ee2e0fa941b53731694")
        
        dismiss(animated: true){ [weak self] in
            self?.completion?(targetUser)
        }
    }
    

}

extension NewConversationViewController:UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
