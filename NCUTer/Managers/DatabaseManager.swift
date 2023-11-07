//
//  DatabaseManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/26.
//

import Foundation
import LeanCloud

class DatabaseManager{
    static let shared = DatabaseManager()
    
    private init(){}
    
    public func getUser(user:LCUser,completion:@escaping (User?) -> Void){
        let objectId = user.objectId?.value
        let query = LCQuery(className: "_User")
        
        let _ = query.get(objectId!,cachePolicy: .onlyNetwork) { (result) in
            switch result {
            case .success(object: let user):
                let username = user.get("username")?.stringValue
                let gender = user.get("gender")?.stringValue
                let bio = user.get("bio")?.stringValue
                let nickName = user.get("nickname")?.stringValue
                let birthday = user.get("birthday")?.stringValue
                let profilePhoto = URL(string:(user.get("profilePictureURL")?.stringValue)!)
                let user = User(objectId:objectId,username: username!, bio: bio!, birthday:birthday!, profilePhoto: profilePhoto!, gender: gender!, counts: nil,nickname: nickName!)
                completion(user)
               
            case .failure(error: let error):
                print("调用太多")
                print(error)
                //------------------
                let _ = query.get(objectId!,cachePolicy: .onlyNetwork) { (result) in
                    switch result {
                    case .success(object: let user):
                        let username = user.get("username")?.stringValue
                        let gender = user.get("gender")?.stringValue
                        let bio = user.get("bio")?.stringValue
                        let nickName = user.get("nickname")?.stringValue
                        let birthday = user.get("birthday")?.stringValue
                        let profilePhoto = URL(string:(user.get("profilePictureURL")?.stringValue)!)
                        let user = User(username: username!, bio: bio!, birthday:birthday!, profilePhoto: profilePhoto!, gender: gender!, counts: nil,nickname: nickName!)
                        completion(user)
                       
                    case .failure(error: let error):
                        print(error)
                    }
                }
                //------------------
            }
        }
    }
    
    public func getCertainUserPosts(user:LCUser,completion:@escaping ([Post]?) -> Void){
        let query = LCQuery(className: "Post")
        query.whereKey("poster", .equalTo(user))
        query.whereKey("type", .equalTo("HomePost"))
        _ = query.find(cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(objects: let posts):
                var model = [Post]()
                for post in posts{
                    var n = Post()
                    n.postId = post.get("objectId")?.stringValue
                    n.images = post.get("images")?.arrayValue as! [String]
                    n.source = post.get("source")?.stringValue
                    n.time = post.get("time")?.stringValue
                    n.title = post.get("title")?.stringValue
                    n.location = post.get("location")?.stringValue
                    n.poster = post.get("poster") as? LCUser
                    model.append(n)
                }
                let posts = model
                
                completion(posts)
               
                
                break
            case .failure(error: let error):
                print(error)
                //---------------
                _ = query.find(cachePolicy: .onlyNetwork) { result in
                   switch result {
                   case .success(objects: let posts):
                       var model = [Post]()
                       for post in posts{
                           var n = Post()
                           n.postId = post.get("objectId")?.stringValue
                           n.images = post.get("images")?.arrayValue as! [String]
                           n.source = post.get("source")?.stringValue
                           n.time = post.get("time")?.stringValue
                           n.title = post.get("title")?.stringValue
                           n.location = post.get("location")?.stringValue
                           n.poster = post.get("poster") as? LCUser
                           model.append(n)
                          
                           
                       }
                       let posts = model
                       completion(posts)
                       break
                   case .failure(error: let error):
                       print(error)
                   }
               }
                //---------------
            
            }
        }
    }
    public func getPosts(completion:@escaping ([Post]?) -> Void){
        let query = LCQuery(className: "Post")
        query.whereKey("createdAt", .descending)
        query.whereKey("type", .equalTo("HomePost"))
        query.limit = 10
        _ = query.find(cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(objects: let posts):
                var model = [Post]()
                for post in posts{
                    var n = Post()
                    n.postId = post.get("objectId")?.stringValue
                    n.images = post.get("images")?.arrayValue as! [String]
                    n.source = post.get("source")?.stringValue
                    n.time = post.get("time")?.stringValue
                    n.title = post.get("title")?.stringValue
                    n.location = post.get("location")?.stringValue
                    n.poster = post.get("poster") as? LCUser
                    model.append(n)
                }
                let posts = model
                completion(posts)
                break
            case .failure(error: let error):
                print(error)
                //------------------
                _ = query.find(cachePolicy: .onlyNetwork) { result in
                    switch result {
                    case .success(objects: let posts):
                        var model = [Post]()
                        for post in posts{
                            var n = Post()
                            n.postId = post.get("objectId")?.stringValue
                            n.images = post.get("images")?.arrayValue as! [String]
                            n.source = post.get("source")?.stringValue
                            n.time = post.get("time")?.stringValue
                            n.title = post.get("title")?.stringValue
                            n.location = post.get("location")?.stringValue
                            n.poster = post.get("poster") as? LCUser
                            model.append(n)
                        }
                        let posts = model
                        completion(posts)
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                }
                //------------------
            }
        }
    }
    public func getCertainPost(post:LCObject,completion:@escaping (Post?) -> Void){
        let query = LCQuery(className: "Post")
        let _ = query.get(post.objectId!,cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(object: let post):
                var n = Post()
                n.postId = post.get("objectId")?.stringValue
                n.images = post.get("images")?.arrayValue as! [String]
                n.source = post.get("source")?.stringValue
                n.time = post.get("time")?.stringValue
                n.title = post.get("title")?.stringValue
                n.location = post.get("location")?.stringValue
                n.poster = post.get("poster") as? LCUser
                completion(n)
                break
            case .failure(error: let error):
                print(error)
                //------------------
                let _ = query.get(post.objectId!,cachePolicy: .onlyNetwork) { result in
                    switch result {
                    case .success(object: let post):
                        var n = Post()
                        n.postId = post.get("objectId")?.stringValue
                        n.images = post.get("images")?.arrayValue as! [String]
                        n.source = post.get("source")?.stringValue
                        n.time = post.get("time")?.stringValue
                        n.title = post.get("title")?.stringValue
                        n.location = post.get("location")?.stringValue
                        n.poster = post.get("poster") as? LCUser
                        completion(n)
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                }
                //------------------
            }
        }
    }
    
    public func getPostComments(post:LCObject,completion:@escaping ([PostComment]?) -> Void){
        let query = LCQuery(className: "PostComment")
        query.whereKey("post", .equalTo(post))
         _ = query.find(cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(objects: let comments):
                var model = [PostComment]()
                for comment in comments {
                    var n = PostComment()
                    let user = comment.get("from") as! LCUser
                    n.commenter = user
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM-dd HH:MM"
                    n.createdAt = formatter.string(from: (comment.get("updatedAt")?.dateValue)!)
                    n.commentText = comment.get("comment")?.stringValue
                    model.append(n)
                }
                    let comments = model
                    completion(comments)
                break
            case .failure(error: let error):
                print(error)
                //----------------
                _ = query.find(cachePolicy: .onlyNetwork) { result in
                   switch result {
                   case .success(objects: let comments):
                       var model = [PostComment]()
                 
                       for comment in comments {
                           var n = PostComment()
                           let user = comment.get("from") as! LCUser
                           n.commenter = user
            
                           let formatter = DateFormatter()
                           formatter.dateFormat = "MM-dd HH:MM"
                           n.createdAt = formatter.string(from: (comment.get("updatedAt")?.dateValue)!)
                           n.commentText = comment.get("comment")?.stringValue
                           model.append(n)
                       }
                        let comments = model
                        completion(comments)
                       break
                   case .failure(error: let error):
                       print(error)
                   }
               }
                //----------------
            
            }
        }
    }
    
    
    public func getPostLikes(post:LCObject,completion:@escaping ([LCUser]?) -> Void){
        let query = LCQuery(className: "PostLike")
        query.whereKey("post", .equalTo(post))
         _ = query.find(cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(objects: let likes):
                var model = [LCUser]()
                for like in likes {
                    let user = like.get("liker") as! LCUser
                    model.append(user)
               }
                    completion(model)
                break
            case .failure(error: let error):
                print(error)
                //-----------------
                _ = query.find(cachePolicy: .onlyNetwork) { result in
                   switch result {
                   case .success(objects: let likes):
                       var model = [LCUser]()
                       for like in likes {
                           let user = like.get("liker") as! LCUser
                        model.append(user)
                           
                      }
                        completion(model)
                       break
                   case .failure(error: let error):
                       print(error)
                   }
               }
                //-----------------
            }
        }
    }
    
    public func getClubPosts(club:String,completion:@escaping ([ClubPost]?) -> Void){
        //let query = LCQuery(className: "ClubPost")
        let query = LCQuery(className: "Post")
        query.whereKey("createdAt", .descending)
        query.whereKey("type", .equalTo("ClubPost"))
        query.whereKey("club", .equalTo(club))
        _ = query.find(cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(objects: let posts):
                var clubPost = [ClubPost]()
              
                for post in posts {
                    var n = ClubPost()
                    n.clubPostId = post.get("objectId")?.stringValue
                    n.poster = post.get("poster") as? LCUser
                    n.content = post.get("content")?.stringValue
                    n.images = post.get("images")?.arrayValue as? [String]
                    n.title = post.get("title")?.stringValue
                    n.club = post.get("club")?.stringValue
                    clubPost.append(n)
                }

                completion(clubPost)
                break
            case .failure(error: let error):
                print(error)
                //-------------------
                _ = query.find(cachePolicy: .onlyNetwork) { result in
                    switch result {
                    case .success(objects: let posts):
                        var clubPost = [ClubPost]()
                        for post in posts {
                            var n = ClubPost()
                            n.clubPostId = post.get("objectId")?.stringValue
                            n.poster = post.get("from") as? LCUser
                            n.content = post.get("content")?.stringValue
                            n.images = post.get("images")?.arrayValue as? [String]
                            n.title = post.get("title")?.stringValue
                            n.club = post.get("club")?.stringValue
                            clubPost.append(n)
                        }
                        completion(clubPost)
                        break
                    case .failure(error: let error):
                        print(error)
                    }
                
                }
                //-------------------
            }
        
        }
    }
    
    public func getCommodities(completion:@escaping ([Commodity]?) -> Void){
        let query = LCQuery(className: "Commodity")
        query.whereKey("createdAt", .descending)
        _ = query.find(cachePolicy: .onlyNetwork) { result in
            switch result {
            case .success(objects: let results):
                var commodities = [Commodity]()
                for result in results {
                    var n = Commodity()
                    n.commodityId = result.get("objectId")?.stringValue
                    n.detail = result.get("detail")?.stringValue
                    n.imagesURL = result.get("imagesURL")?.arrayValue as? [String]
                    n.modelURL = result.get("modelURL")?.stringValue
                    n.price = result.get("price")?.stringValue
                    n.seller = result.get("seller") as? LCUser
                    
                    commodities.append(n)
                }

                completion(commodities)
                break
            case .failure(error: let error):
                print(error)
            
            }
        
        }
    }
    
}
