//
//  CertainClubViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/2/7.
//

import UIKit
import SnapKit

class CertainClubViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ClubHeaderViewDelegate {
    
    private let clubName:String
    
    lazy var clubPosts = [ClubPost]()
    
    var clubPostNumber:Int = 0
    
    init(clubName:String){
        self.clubName = clubName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let button:UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        let image = UIImage(named: "newClubPost")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ClubHeaderView.self, forHeaderFooterViewReuseIdentifier: ClubHeaderView.identifier)
        tableView.register(ClubPostTableViewCell.self, forCellReuseIdentifier: ClubPostTableViewCell.identifier)
        
        
        return tableView
        
    }()
    
    @objc func didTapButton(){
        let vc = NewClubPostViewController(clubName: clubName)
        
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = clubName
        view.addSubview(tableView)
        view.addSubview(button)
        tableView.delegate = self
        tableView.dataSource = self
        DispatchQueue.main.async {
            DatabaseManager.shared.getClubPosts(club: self.clubName){ [weak self] posts in
                guard let _ = posts else {
                    return
                }
                self?.clubPosts = posts!
                self?.clubPostNumber = posts!.count
                self?.tableView.reloadData()
               
            }
        }
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        button.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(60)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(60)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubPosts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ClubPostTableViewCell = tableView.dequeueReusableCell(withIdentifier: ClubPostTableViewCell.identifier, for: indexPath) as! ClubPostTableViewCell
        cell.configure(post: clubPosts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = CertainClubPostViewController(clubPost: clubPosts[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let clubHeaderView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ClubHeaderView.identifier) as! ClubHeaderView
        clubHeaderView.configure(with: clubName,postNumber:clubPostNumber)
        clubHeaderView.delegate = self
        return clubHeaderView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
}
