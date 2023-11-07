//
//  Models.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/1/23.
//

import Foundation
import LeanCloud
import HandyJSON


//struct User {
//    let username: String
//    let bio:String
//    let birthday:String
//    let profilePhoto :URL
//    let gender:String
//    let counts:UserCount?
//    let nickname:String
//}
struct User:HandyJSON {
    var objectId:String?
    var username:String?
    var bio:String?
    var birthday:String?
    var profilePhoto :URL?
    var profilePictureURL:String?
    var gender:String?
    var counts:UserCount?
    var nickname:String?
   
}

//好友关系的json解析
struct Follow:HandyJSON {
    var results:[SubFollow]?
}
struct SubFollow:HandyJSON {
    var followee:User?
    var follower:User?
}



struct UserCount {
    let followers:Int
    let following:Int
    let posts:Int
}

public struct Post{
    var postId:String?
    var time: String?
    var source: String?
    var title: String?
    var images: [String] = []
    var poster:LCUser?
    var location:String?
}

struct PostComment {
    var commenter:LCUser?
    //var headPic:URL?
    //var nickName:String?
    var createdAt:String?
    var commentText:String?
}

struct PostLike {
    var liker:LCUser?
    var post:LCObject?
   // var headPic:URL?
   // var nickName:String?
}

enum FollowState {
    case following
    case not_following
}
struct UserRelationship {
    let username:String
    let name:String
    let type:FollowState
}

struct ClubPost {
    var clubPostId:String?
    var poster:LCUser?
    var club:String?
    var title:String?
    var content:String?
    var images: [String]?
    
}
//二手商品
struct Commodity {
    var commodityId:String?
    var seller:LCUser?
    var detail:String?
    var imagesURL:[String]?
    var price:String?
    var modelURL:String?
    
}

