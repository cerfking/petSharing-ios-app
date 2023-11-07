//
//  SettingViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/12.
//

import UIKit
import SafariServices
import Kingfisher

struct SettingCellModel {
    let title:String
    let handler:(()->Void)
}
class SettingViewController: UIViewController {
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    private var data = [[SettingCellModel]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        configureModels()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    private func configureModels(){
        data.append([
            SettingCellModel(title: "个人资料设置"){[weak self] in
                let vc = EditProfileViewController()
                vc.title = "个人资料设置"
                self?.navigationController?.pushViewController(vc, animated: true )
            },
            SettingCellModel(title: "账户安全"){[weak self] in
                self?.didTapAccountSecurity()
            }
        ])
        data.append([
            SettingCellModel(title: "服务政策"){[weak self] in
                guard let url = URL(string: "http://www.cerf.top") else {
                    return
                }
                let vc = SFSafariViewController(url: url)
                self?.present(vc, animated: true)
                
            }
        ])
        data.append([
                SettingCellModel(title: "清除缓存"){
                ImageCache.default.clearMemoryCache()
                ImageCache.default.clearDiskCache {
                    print("图片清除缓存完毕")
                }
            }
        ])
        data.append([
            SettingCellModel(title: "退出登录"){[weak self] in
                self?.didTapLogOut()
            }
        ])
    }
   
    private func didTapAccountSecurity(){
        
    }
    
    private  func clearAllFilesFromDirectory() {
        
        let fileManager = FileManager.default
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
        let documentsPath = documentsUrl.path

        do {
            if let documentPathValue = documentsPath{

                let path = documentPathValue.replacingOccurrences(of: "file://", with: "")
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(path)")
                print("all files in cache: \(fileNames)")

                for fileName in fileNames {

                    let tempPath = String(format: "%@/%@", path, fileName)

                    //Check for specific file which you want to delete. For me .usdz files
                    if tempPath.contains(".usdz") {
                        try fileManager.removeItem(atPath: tempPath)
                    }
                }
            }

        } catch {
            print("Could not clear document directory \(error)")
        }
    }
    private func didTapLogOut(){
        let actionSheet = UIAlertController(title: nil, message: "退出后不会删除任何历史数据，下次登录依然可以使用本账号。", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "退出登录", style: .destructive, handler: {[weak self] _ in
            AuthManager.shared.logOut()
                DispatchQueue.main.async {
                    
                        let loginVC = LoginViewController()
                        loginVC.modalPresentationStyle = .fullScreen
                        self?.present(loginVC, animated: true,completion: {
                            self?.navigationController?.popToRootViewController(animated: false)
                            self?.tabBarController?.selectedIndex = 0
                            
                        })
                }
     
        }))
        
        actionSheet.popoverPresentationController?.sourceView = tableView
        actionSheet.popoverPresentationController?.sourceRect = tableView.bounds
        present(actionSheet, animated: true)
    }
}

extension SettingViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = data[indexPath.section][indexPath.row]
        model.handler()
    }
    
    
}
