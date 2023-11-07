//
//  RelationshipManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/9.
//

import Foundation
import LeanCloud
import Alamofire

class RelationshipManager{
    static let shared = RelationshipManager()
    private init(){}
    //关注
    public func follow(target:LCObject){

        let target_id = (target.objectId?.stringValue)!
        
        let headers: HTTPHeaders = [
            "X-LC-Id": "FKFywkYYA5VnCWi6F6CuvI2f-gzGzoHsz",
            "X-LC-Key": "YCabDnARAr1YExwuslBWlE0L",
            "X-LC-Session":(LCApplication.default.currentUser?.sessionToken?.stringValue)!,
            "Content-Type":"application/json"
        ]
        
        AF.request("https://fkfywkyy.lc-cn-n1-shared.com/1.1/users/self/friendship/\(target_id)",method: .post,headers: headers).response { response in
            debugPrint(response)
        }
    }
    //取消关注
    public func unfollow(target:LCObject){
        let target_id = (target.objectId?.stringValue)!
        
        let headers: HTTPHeaders = [
            "X-LC-Id": "FKFywkYYA5VnCWi6F6CuvI2f-gzGzoHsz",
            "X-LC-Key": "YCabDnARAr1YExwuslBWlE0L",
            "X-LC-Session":(LCApplication.default.currentUser?.sessionToken?.stringValue)!,
            "Content-Type":"application/json"
        ]
        
        AF.request("https://fkfywkyy.lc-cn-n1-shared.com/1.1/users/self/friendship/\(target_id)",method: .delete,headers: headers).response { response in
            debugPrint(response)
        }
    }
    //获取某用户关注的用户
    public func getFollowees(user:LCUser,completion:@escaping ([User]?) -> Void){
        var followees = [User]()
        let user_id = user.objectId?.stringValue
        
        let headers: HTTPHeaders = [
            "X-LC-Id": "FKFywkYYA5VnCWi6F6CuvI2f-gzGzoHsz",
            "X-LC-Key": "YCabDnARAr1YExwuslBWlE0L",
            "X-LC-Session":(LCApplication.default.currentUser?.sessionToken?.stringValue)!,
            "Content-Type":"application/json"
        ]
        
        AF.request("https://fkfywkyy.lc-cn-n1-shared.com/1.1/users/\(user_id!)/followees?include=followee",method: .get,headers: headers).responseString { response in
            guard let value = response.value else { return }
      
            if let a: Follow = Follow.deserialize(from: value)
            {
                if a.results?.count != 0 {
                    if a.results != nil {
                        for result in a.results!{
                           followees.append(result.followee!)
                       }
                    }
//                    for result in a.results!{
//                        followees.append(result.followee!)
//                    }
                    
                }
               completion(followees)
                        
            }
            else{
                    print("解析失败")
                }
        }
    }
    //获取某用户的粉丝
    public func getFollowers(user:LCUser,completion:@escaping ([User]?) -> Void){
        var followers = [User]()
        
        let user_id = user.objectId?.stringValue
        
        let headers: HTTPHeaders = [
            "X-LC-Id": "FKFywkYYA5VnCWi6F6CuvI2f-gzGzoHsz",
            "X-LC-Key": "YCabDnARAr1YExwuslBWlE0L",
            "X-LC-Session":(LCApplication.default.currentUser?.sessionToken?.stringValue)!,
            "Content-Type":"application/json"
        ]
        
        AF.request("https://fkfywkyy.lc-cn-n1-shared.com/1.1/users/\(user_id!)/followers?include=follower",method: .get,headers: headers).responseString { response in
            guard let value = response.value else { return }
            if let p: Follow = Follow.deserialize(from: value)
            {
                if p.results?.count != 0 {
                    if p.results != nil{
                        for result in p.results!{
                            followers.append(result.follower!)
                        }

                    }
//                    for result in p.results!{
//                        followers.append(result.follower!)
//                    }
                    //completion(followers)
                }
                completion(followers)
            }
            else{
                    print("解析失败")
                }
        }
    }
    //检查当前用户是否关注某用户
    
    public func checkFollowState(user:User,completion:@escaping (FollowState?) -> Void){
        getFollowees(user:LCApplication.default.currentUser!){followees in
            guard let _ = followees,followees?.count != 0 else {
                completion(.not_following)
                return
            }
            for followee in followees! {
                if followee.objectId == user.objectId {
                    completion(.following)
                }
                else {
                    completion(.not_following)
                }
            }
        }
    }
    
    public func test(){
       
       
        
        AF.request("http://Lus-MacBook-Pro.local:8080/hello",method: .get).responseString { (response) in
            print(response)
        }
    }


}

