//
//  ConversationManager.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/19.
//

import Foundation
import LeanCloud

class ConversationManager {
    static let shared = ConversationManager()
    private init(){}
    //创建一个新的对话
    public func createNewConversation(targetUser:LCUser,completion:@escaping (IMConversation?) -> Void){
        do {
            guard let _ = ((targetUser.objectId?.stringValue)) else {
                print("创建对话失败")
                return
            }
            try client?.createConversation(clientIDs: [(targetUser.objectId?.stringValue)!],completion: { (result) in
                switch result {
                case .success(value: let conversation):
                    print(conversation)
                    completion(conversation)
                case .failure(error: let error):
                    print(error)
                    completion(nil)
                }
            })
        } catch {
            print(error)
        }
    }
    //获取所有的对话
    public func getAllConversations(completion:@escaping([IMConversation]?) -> Void) {
        do {
            let conversationQuery = client!.conversationQuery
            conversationQuery.options = [.containLastMessage]
            try conversationQuery.findConversations { (result) in
                switch result {
                case .success(value: let conversations):
                    print("查找成功")
                    completion(conversations)
                case .failure(error: let error):
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    //获取某个对话的所有消息
    public func getAllMessagesForConversation(conversation:IMConversation,completion:@escaping ([Message]?) -> Void){
        do {
            try conversation.queryMessage { (result) in
                switch result {
                case .success(value: let messages):
                    var model = [Message]()
                    let group = DispatchGroup()
                    for message in messages{
                        group.enter()
                        let messageId = message.ID
                        DatabaseManager.shared.getUser(user: LCUser(objectId: message.fromClientID!)){ user in
                            let sender = Sender(photoURL: (user?.profilePhoto)!, senderId: message.fromClientID!, displayName: (user?.nickname)!)
                            if let categorizedMessage = message as? IMCategorizedMessage {
                                switch categorizedMessage {
                                case let textMessage as IMTextMessage:
                                    let result = convertStringToDictionary(text:(textMessage.content?.string)!)
                                    let messageContent = result?["_lctext"]
                                    let n = Message( sender: sender,messageId: messageId!, sentDate: textMessage.sentDate!, kind: .text(messageContent as! String))
                                    model.append(n)
                                case let imageMessage as IMImageMessage:
                                    let media = Media(url: imageMessage.url, image: nil, placeholderImage: UIImage(named: "placeholderImage")!, size: CGSize(width: 200, height: 200))
                                    let n = Message( sender: sender,messageId: messageId!, sentDate: imageMessage.sentDate!, kind: .photo(media))
                                    model.append(n)
                                    print(imageMessage)
                                case let audioMessage as IMAudioMessage:
                                    let audio = Audio(url: audioMessage.url!, duration: Float(audioMessage.duration!), size: CGSize(width: 100, height: 30))
                                    let n = Message( sender: sender,messageId: messageId!, sentDate: audioMessage.sentDate!, kind: .audio(audio))
                                    model.append(n)
                                default:
                                    break
                                }
                            }
                            else {
                                print("收到未知类型消息")
                            }
                            group.leave()
                        }
                    }
                    group.notify(queue: .main){
                        let messages = model
                        completion(messages)
                    }
                case .failure(error: let error):
                    print(error)
                    completion(nil)
                }
            }
        } catch {
            print(error)
        }
    }
    //在对话中发送消息 public func sendMessage(conversation:IMConversation,message:Message,completion:@escaping (Bool) -> Void)
    //发送文字信息
    public func sendMessage(conversation:IMConversation,message:String,completion:@escaping (Bool,IMTextMessage?) -> Void){
        do {
            let textMessage = IMTextMessage(text: message)
            try conversation.send(message: textMessage) { (result) in
                switch result {
                case .success:
                    completion(true,textMessage)
                    break
                case .failure(error: let error):
                    print(error)
                    completion(false,nil)
                }
            }
        } catch {
            print(error)
        }
    }
    
    //发送图片信息
    public func sendImageMessage(conversation:IMConversation,image:UIImage,completion:@escaping (Bool,IMImageMessage?) -> Void){
        do {
            let imageMessage = IMImageMessage(data: image.pngData()!)
            try conversation.send(message: imageMessage){ (result) in
                switch result {
                case .success:
                    completion(true,imageMessage)
                    break
                case .failure(error: let error):
                    print(error)
                    completion(false,nil)
                }
            }
        } catch {
            print(error)
        }
    }
    //发送音频信息
    public func sendAudioMessage(conversation:IMConversation,audioFileURL:URL,completion:@escaping (Bool,IMAudioMessage?) -> Void){
        do {
            let audioMessage = IMAudioMessage(filePath: audioFileURL.path)
            try conversation.send(message: audioMessage, completion: { (result) in
                switch result {
                case .success:
                    completion(true,audioMessage)
                    break
                case .failure(error: let error):
                    completion(false,nil)
                    print(error)
                }
            })
        } catch {
            print(error)
        }
    }
    
   
}

extension Date{
    // 转成当前时区的日期
      static func dateFromGMT(_ date: Date) -> Date {
          let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: date))
          return date.addingTimeInterval(secondFromGMT)
      }
}

