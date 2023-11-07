//
//  AppDelegate.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/22.
//

import UIKit
import LeanCloud
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        do {
            var configuration = LCApplication.Configuration.default
               configuration.HTTPURLCache = URLCache(
                   // 内存缓存容量，100 MB
                   memoryCapacity: 200 * 1024 * 1024,
                   // 磁盘缓存容量，100 MB
                   diskCapacity: 200 * 1024 * 1024,
                   diskPath: nil)
            try LCApplication.default.set(
          
                //id:"FKFywkYYA5VnCWi6F6CuvI2f-gzGzoHsz",
                id:"8LXa2sJ1EtbU49jxGaZ3hBVX-MdYXbMMI",
                //key: "YCabDnARAr1YExwuslBWlE0L",
                key:"vAVwW1GOfU9CHXjiQkQBuE5J",
                serverURL: "https://8lxa2sj1.api.lncldglobal.com",
                configuration: configuration
            )
        } catch {
            print(error)
        }
        
        IQKeyboardManager.shared.enable = true
     
        
  
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }


}

