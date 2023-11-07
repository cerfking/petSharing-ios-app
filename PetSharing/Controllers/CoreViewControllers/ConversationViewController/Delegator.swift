//
//  Delegator.swift
//  NCUTer
//
//  Created by 陆华敬 on 2022/3/20.
//

import Foundation
import LeanCloud

class Delegator {
    static let delegator = Delegator()
    
}

extension Delegator:IMClientDelegate {
    func client(_ client: IMClient, event: IMClientEvent) {
        
    }
    
    func client(_ client: IMClient, conversation: IMConversation, event: IMConversationEvent) {
        switch event {
          case .message(event: let messageEvent):
              switch messageEvent {
              case .received(message: let message):
                let messageId = message.ID
                DatabaseManager.shared.getUser(user: LCUser(objectId: message.fromClientID!)){ user in
                    let sender = Sender(photoURL: (user?.profilePhoto)!, senderId: message.fromClientID!, displayName: (user?.nickname)!)
                    let result = convertStringToDictionary(text:(message.content?.string)!)
                    let messageContent = result?["_lctext"]
                    let message = Message( sender: sender,messageId: messageId!, sentDate: message.sentDate!, kind: .text(messageContent as! String))
                    NotificationCenter.default.post(name: NSNotification.Name("newMessageReceived"), object: message)
                }
            
              default:
                  break
              }
          default:
              break
          }
    }
    
}


