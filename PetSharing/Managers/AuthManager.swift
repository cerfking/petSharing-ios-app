//
//  AuthManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2021/12/23.
//

import LeanCloud

var client:IMClient?

public class AuthManager{
    static let shared = AuthManager()
    public func registerNewUserWithUsername(username:String,password:String,completion:@escaping (Bool) -> Void){
        let user = LCUser()
        user.username = username.lcString
        user.password = password.lcString
            
        _ = user.signUp {(result) in
            switch result {
            case .success:
                completion(true)
                break
            case .failure(error: let error):
                print(error)
                completion(false)
            }
        }
    }
    public func loginWithUsername(username:String,password:String,completion:@escaping (Bool) -> Void){
        _ = LCUser.logIn(username: username, password: password)
        {result in
            switch result {
            case .success(object: let user):
                do {
                    client = try IMClient(user: user)
                    client?.open { (result) in
                        // handle result
                        //cilentId就是user的objectId
                        client?.delegate = Delegator.delegator
                    }
                } catch {
                    print(error)
                }
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    public func loginWithCode(mobilePhoneNumber:String,verificationCode:String,completion:@escaping (Bool,LCError?) -> Void){
        _ = LCUser.logIn(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode) { result in
            switch result {
            case .success(object: let user):
                do {
                    client = try IMClient(user: user)
                    client?.open { (result) in
                        client?.delegate = Delegator.delegator
                    }
                } catch {
                    print(error)
                }
                completion(true,nil)
            case .failure(error: let error):
                completion(false,error)
                print(error)
            }
        }
    }
    
    public func registerWithCode(mobilePhoneNumber:String,verificationCode:String,completion:@escaping (Bool) -> Void){
        _ = LCUser.signUpOrLogIn(mobilePhoneNumber: mobilePhoneNumber, verificationCode: verificationCode) { result in
            switch result {
            case .success:
                completion(true)
            case .failure(error: let error):
                completion(false)
                print(error)
            }
        }
    }
    public func logOut(){
        LCUser.logOut()
        return
    }
}
