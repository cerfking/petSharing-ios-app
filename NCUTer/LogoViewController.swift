//
//  LogoViewController.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/23.
//

import UIKit
import LeanCloud

class LogoViewController: UIViewController {
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageView.image = UIImage(named: "petco-logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private func animate(){
        UIView.animate(withDuration: 1, animations: {
            let size = self.view.width * 3
            let diffX = size - self.view.width
            let diffY = self.view.height - size
            self.imageView.frame = CGRect(x: -(diffX/2), y: diffY/2, width: size, height: size)

        })
        UIView.animate(withDuration: 1.2, animations: {
            self.imageView.alpha = 0
        },completion: { done in
            if done {
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {

                    if LCApplication.default.currentUser == nil{
                        let loginVC = LoginViewController()
                        loginVC.modalPresentationStyle = .fullScreen
                        loginVC.modalTransitionStyle = .crossDissolve
                        self.present(loginVC, animated: true, completion: nil)
                    }
                    else{
                        
                        do {
                            client = try IMClient(user: LCApplication.default.currentUser!)
                            client?.open { (result) in
                                client?.delegate = Delegator.delegator
                            }
                        } catch {
                            print(error)
                        }
                        let tabBarVC = UITabBarController()
                        tabBarVC.tabBar.isTranslucent = true
                
                        let vc1 = UINavigationController(rootViewController: HomeViewController())
                        vc1.title = "Home"
                        vc1.tabBarItem.image = UIImage(systemName: "house")
                        let vc2 = UINavigationController(rootViewController: ClubViewController())
                        vc2.title = "Club"
                        vc2.tabBarItem.image = UIImage(systemName: "flag")
                        let vc3 = UINavigationController(rootViewController: TransactionViewController())
                        vc3.title = "Item"
                        vc3.tabBarItem.image = UIImage(systemName: "bag")
                        let vc4 = UINavigationController(rootViewController: ConversationsViewController())
                        vc4.title = "Message"
                        vc4.tabBarItem.image = UIImage(systemName: "envelope")
                        let vc5 = UINavigationController(rootViewController: MeViewController())
                        vc5.title = "Me"
                        vc5.tabBarItem.image = UIImage(systemName: "person")
                        
                        
                        tabBarVC.setViewControllers([vc1,vc2,vc3,vc4,vc5], animated: false)
                        tabBarVC.modalPresentationStyle = .fullScreen
                        self.present(tabBarVC, animated: true)
                        
                    }
                    

                    
    
                })
                
            }
            
        })

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageView.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
            self.animate()
        })
    }
 
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        imageView.center = view.center
//        DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
//            self.animate()
//        })
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
    }

}
