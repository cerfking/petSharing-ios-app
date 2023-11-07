//
//  StorageManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/24.
//

import Foundation
import LeanCloud

class StorageManager{
    static let shared = StorageManager()
    
    private init(){}
    
    public func uploadUserProfilePicture(image:UIImage?){
        let data = image?.pngData()
        let file = LCFile(payload: .data(data: data!))
        _ = file.save { result in
            switch result {
            case .success:
                do {
                    if let value = file.url?.value {
                        NotificationCenter.default.post(name: NSNotification.Name("changeProfilePicture"), object: value)
                    let objectId = LCApplication.default.currentUser?.objectId?.value
                    let profilePictureURL = LCObject(className: "_User",objectId: objectId!)
                    try profilePictureURL.set("profilePictureURL", value: value)
                        profilePictureURL.save { (result) in
                        switch result {
                        case .success:
                            break
                        case .failure(error: let error):
                            print(error)
                        }
                    }
                        print("文件保存完成。URL: \(value)")
                    }
                }catch {
                    print(error)
                }
    //关联
                    do {
                        if let _ = file.objectId?.value {
                                let objectId = LCApplication.default.currentUser?.objectId?.value
                                let profilePicture = LCObject(className: "_User",objectId: objectId!)
                                try profilePicture.set("profilePicture", value: file)
                                profilePicture.save { (result) in
                                    switch result {
                                    case .success:
                                        print("用户头像上传完成")
                                        break
                                    case .failure(error: let error):
                                        print(error)
                                    }
                                }
                            }
                        
                    } catch {
                        print(error)
                    }
                
            case .failure(error: let error):
                // 保存失败，可能是文件无法被读取，或者上传过程中出现问题
                print(error)
            }
        }
        
        
    }
    
    public func downloadUrlForProfilePicture(completion:@escaping (URL?) -> Void){
        let objectId = LCApplication.default.currentUser?.objectId?.value
        let query = LCQuery(className: "_User")
        let _ = query.get(objectId!,cachePolicy: .onlyNetwork) { (result) in
            switch result {
            case .success(object: let user):
                let profilePictureURL = URL(string: (user.get("profilePictureURL")?.stringValue)!)
                completion(profilePictureURL)
    
            case .failure(error: let error):
                //--------------------
                print(error)
                let _ = query.get(objectId!,cachePolicy: .onlyNetwork) { (result) in
                    switch result {
                    case .success(object: let user):
                        let profilePictureURL = URL(string: (user.get("profilePictureURL")?.stringValue)!)
                        completion(profilePictureURL)
            
                    case .failure(error: let error):
                        print(error)
                        return
                    }
                }
                //----------------------
                return
            }
        }
        
    }
    
    public func updateGender(gender:String?){
        do {
            let objectId = LCApplication.default.currentUser?.objectId?.value
            let reference = LCObject(className: "_User",objectId: objectId!)
            try reference.set("gender", value: gender)
            reference.save { (result) in
                switch result {
                case .success:
                    //NotificationCenter.default.post(name: NSNotification.Name("updateGender"), object: gender)
                    
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
                }
        catch {
            print(error)
                }
            }
    public func updateBio(bio:String?){
        do {
            let objectId = LCApplication.default.currentUser?.objectId?.value
            let reference = LCObject(className: "_User",objectId: objectId!)
            try reference.set("bio", value: bio)
            reference.save { (result) in
                switch result {
                case .success:
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
                }
        catch {
            print(error)
                }
            }
    public func updateNickname(nickname:String?){
        do {
            let objectId = LCApplication.default.currentUser?.objectId?.value
            let reference = LCObject(className: "_User",objectId: objectId!)
            try reference.set("nickname", value: nickname)
            reference.save { (result) in
                switch result {
                case .success:
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
                }
        catch {
            print(error)
                }
    }
    public func updateBirthday(birthday:String?){
        do {
            let objectId = LCApplication.default.currentUser?.objectId?.value
            let reference = LCObject(className: "_User",objectId: objectId!)
            try reference.set("birthday", value: birthday)
            reference.save { (result) in
                switch result {
                case .success:
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
                }
        catch {
            print(error)
                }
    }
    
    public func uploadPostImage(images:[UIImage],completion:@escaping ([String]) -> Void){
        var postPictureUrls = [String]()
        let group = DispatchGroup()
        for image in images{
            group.enter()
            let data = image.pngData()
            let file = LCFile(payload: .data(data: data!))
            _ = file.save { result in
                defer {
                    group.leave()
                }
                switch result {
                case .success:
                    do {
                        if let value = file.url?.value {
                            
                            postPictureUrls.append(value)
                            
                        }
                    }
                case .failure(error: let error):
                    print(error)
                }
            }
        }
        group.notify(queue: .main){
           completion(postPictureUrls)
        }
        
           
            
            
    }
    public func newPost(post:Post,completion: (Bool) -> Void){
        let title = post.title
        let images = post.images
        let source = post.source
        let time = post.time
        let poster = post.poster
        let location = post.location
        do {
            // 构建对象
            let post = LCObject(className: "Post")
            // 为属性赋值
            try post.set("type", value: "HomePost")
            try post.set("title", value: title)
            try post.set("images", value: images)
            try post.set("source", value: source)
            try post.set("time", value: time)
            try post.set("poster", value: poster)
            try post.set("location", value: location)

            // 将对象保存到云端
            _ = post.save { result in
                switch result {
                case .success:
                    // 成功保存之后，执行其他逻辑
                    break
                case .failure(error: let error):
                    // 异常处理
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        completion(true)
    }
    
    public func likePost(post:LCObject){
        do {
            // 构建对象
            let like = LCObject(className: "PostLike")
            // 为属性赋值
            try like.set("liker", value: LCApplication.default.currentUser)
            try like.set("post", value: post)

            // 将对象保存到云端
            _ = like.save { result in
                switch result {
                case .success:
                    // 成功保存之后，执行其他逻辑
                    break
                case .failure(error: let error):
                    // 异常处理
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    public func CancelLikePost(post:LCObject){
        do {
            let likerQuery = LCQuery(className: "PostLike")
            likerQuery.whereKey("liker", .equalTo(LCApplication.default.currentUser!))
            let postQuery = LCQuery(className: "PostLike")
            postQuery.whereKey("post", .equalTo(post))
            
            let query = try likerQuery.and(postQuery)
            _ = query.find(cachePolicy: .onlyNetwork) { result in
                switch result {
                case .success(objects: let likes):
                    for like in likes {
                        _ = like.delete()
                    }
                    break
                case .failure(error: let error):
                    print(error)
                    //-----------------------
                    _ = query.find(cachePolicy: .onlyNetwork) { result in
                        switch result {
                        case .success(objects: let likes):
                            for like in likes {
                                _ = like.delete()
                            }
                            break
                        case .failure(error: let error):
                            print(error)
                        }
                    }
                    //-----------------------
                }
            }
 
        } catch {
            print(error)
        }
    }
    
    public func CommentPost(comment:String,post:LCObject){
        do {
            let postComment = LCObject(className: "PostComment")
            // 为属性赋值
            try postComment.set("from", value: LCApplication.default.currentUser)
            try postComment.set("post", value: post)
            try postComment.set("comment", value: comment)

            _ = postComment.save { result in
                switch result {
                case .success:
                    break
                case .failure(error: let error):
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    public func newClubPost(clubPost:ClubPost,completion: (Bool) -> Void){
        do {
            // 构建对象
            let post = LCObject(className: "Post")
            // 为属性赋值
            try post.set("type", value: "ClubPost")
            try post.set("title", value: clubPost.title)
            try post.set("images", value: clubPost.images)
            try post.set("poster", value: clubPost.poster)
            try post.set("club", value: clubPost.club)
         
            // 将对象保存到云端
            _ = post.save { result in
                switch result {
                case .success:
                    // 成功保存之后，执行其他逻辑
                    break
                case .failure(error: let error):
                    // 异常处理
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        completion(true)
    }
    
    public func newCommodity(commodity:Commodity,completion: (Bool) -> Void){
        do {
            // 构建对象
            let object = LCObject(className: "Commodity")
            // 为属性赋值
            try object.set("detail", value: commodity.detail)
            try object.set("imagesURL", value: commodity.imagesURL)
            try object.set("modelURL", value: commodity.modelURL)
            try object.set("price", value: commodity.price)
            try object.set("seller", value: commodity.seller)
         
            // 将对象保存到云端
            _ = object.save { result in
                switch result {
                case .success:
                    // 成功保存之后，执行其他逻辑
                    break
                case .failure(error: let error):
                    // 异常处理
                    print(error)
                }
            }
        } catch {
            print(error)
        }
        completion(true)
    }
    
}
    
        

