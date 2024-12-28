//
//  FCMTokenManager.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/19/24.
//

import Foundation
import UserNotifications
import UIKit

class FCMTokenManager {
    
    static let shared = FCMTokenManager()
    
    func getPushNotificationPermission() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            /// 사용자에게 알림 허용 권한 받기
            UNUserNotificationCenter.current().delegate = appDelegate
            
            // 필요한 알림 권한 설정(알람창, 앱에 뱃지, 알람소리)
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
            
            /// UNUserNotificationCenterDelegate를 구현한 메소드 실행
            UIApplication.shared.registerForRemoteNotifications()
            
            // FIXME: 고민
            // 일단 권한과 상관없이 토큰은 등록...?
            //appDelegate.fetchFCMToken()
        }
    }
}
