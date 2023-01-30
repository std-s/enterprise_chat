//
//  NotificationService.swift
//  NotificationService
//
//  Created by x on 2022/5/31.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    var isSound: Bool = false;

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let userInfo = request.content.userInfo as NSDictionary
            let clientID = userInfo["clientMsgID"] as! NSString
            print("didReceive:\(userInfo.description)")
            if clientID != "" {
                
                let key = "key";
                UserDefaults.standard.set(request.identifier, forKey: key);
                bestAttemptContent.title = "\(bestAttemptContent.title)"
                bestAttemptContent.sound = UNNotificationSound(named: .init(rawValue: "call.caf"))
                isSound = true;
                
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        isSound = false;
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
