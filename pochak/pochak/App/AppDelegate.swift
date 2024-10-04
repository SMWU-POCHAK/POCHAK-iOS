//
//  AppDelegate.swift
//  pochak
//
//  Created by 장나리 on 2023/06/26.
//

import UIKit
import GoogleSignIn
import RealmSwift
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(2)
        
        /* 내비게이션 바 설정 */
        let backButtonImage = UIImage(named: "ChevronLeft")?.withRenderingMode(.alwaysOriginal).withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0))
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)

        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().tintColor = .black
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        
        // 탭바 폰트 설정
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        ]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .selected)
        
        // Realm 마이그레이션 : Realm 스키마 업데이트 시 schemaVersion을 올리고, 변경사항이 반영될 수 있도록 초기화 진행
        let config = Realm.Configuration(
            schemaVersion: 2,
            migrationBlock: { migration, oldSchemaVersion in
                print("Old Schema Version: \(oldSchemaVersion)")
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: RecentSearchModel.className()) { oldObject, newObject in
                        newObject!["name"] = ""
                    }
                }
            }
        )
    
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        // 앱이 시작될 때 Firebase 연동
        FirebaseApp.configure()
        
        /// 앱 실행 시 사용자에게 알림 허용 권한 받기
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한 설정(알람창, 앱에 뱃지, 알람소리)
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        /// UNUserNotificationCenterDelegate를 구현한 메소드 실행
        application.registerForRemoteNotifications()
        
        /// Firebase Meesaging delegate 설정
        Messaging.messaging().delegate = self
        
        /// FCM 발급받은 토큰 가져오기
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } 
            else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        // 앱 첫 실행 시 keyChain 정보를 삭제
        removeKeychainAtFirstLaunch()
        return true
    }
    
    private func removeKeychainAtFirstLaunch() {
        guard UserDefaults.isFirstLaunch() else {
            return
        }
        
        // 첫 실행이라면 keyChain 정보를 삭제
        do {
            try KeychainManager.delete(account: "accessToken")
            try KeychainManager.delete(account: "refreshToken")
        } catch {
            print(error)
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // Google 로그인
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Extension: UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {

    /// 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Background, APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// Foreground(앱 켜진 상태) 에서 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Foreground, 메시지 수신")
        completionHandler([.banner, .badge, .sound])
    }

//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        completionHandler()
//    }
}

// MARK: - Extension: MessagingDelegate (for Firebase Messaging)

extension AppDelegate: MessagingDelegate {
    
    /// FCM토큰이 변경되었을 때를 감지, 새로운 토큰으로 갱신해서 저장
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

}
