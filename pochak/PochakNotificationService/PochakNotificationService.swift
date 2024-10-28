//
//  NotificationService.swift
//  PochakNotificationService
//
//  Created by Suyeon Hwang on 10/28/24.
//

import UserNotifications
import FirebaseMessaging

class PochakNotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    /// APNs를 수신하면 didReceive 메소드가 호출되고
    /// contentHandler 클로저를 수행하면 푸시가 노출됨
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            
            contentHandler(bestAttemptContent)
        }
        
//        // UNMutableNotificationContent는 notification content의 정보를 가지고 있는 클래스
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//        
//        guard let bestAttemptContent else { return }
//        
//        // 알람의 내용을 변경
//        bestAttemptContent.title = "변경 " + request.content.title
//        bestAttemptContent.body = "변경 " + request.content.body
//        
//        // 푸시 알림의 이미지
//        let imageURLString = request.content.userInfo["image"] as! String
//
//        
//        contentHandler(bestAttemptContent)
    }
    
    /// didReceive에서 contentHandler가 호출되지 않고 특정 시간이 경과되면 호출되는 메소드
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
