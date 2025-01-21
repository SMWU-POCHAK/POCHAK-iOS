//
//  LocalPushNotificationManager.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/22/25.
//

import UserNotifications

final class LocalPushNotificationManager {
    
    static let shared = LocalPushNotificationManager()
    
    private init() { }
    
    /// 로컬에서 푸시 알림을 보내는 메소드
    /// - Parameters:
    ///   - title: 푸시 알림 제목
    ///   - body: 푸시 알림 바디
    ///   - identifier: 푸시 알림의 identifier
    func sendPushNotification(title: String, body: String, identifier: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = .default

        let request = UNNotificationRequest(identifier: identifier,
                                            content: notificationContent,
                                            trigger: nil)

        // 알림 등록
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[!] LocalPushNotificationManager Error: ", error)
            }
        }
    }
}
