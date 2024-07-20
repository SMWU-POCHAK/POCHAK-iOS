//
//  AppDelegate.swift
//  pochak
//
//  Created by 장나리 on 2023/06/26.
//

import UIKit
import GoogleSignIn
import RealmSwift

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
        
        // Realm 마이그레이션
        let config = Realm.Configuration(
            schemaVersion: 2, // Update schema version to the latest version you want to use
            migrationBlock: { migration, oldSchemaVersion in
                print("Old Schema Version: \(oldSchemaVersion)")
                if oldSchemaVersion < 2 {
                    migration.enumerateObjects(ofType: RecentSearchModel.className()) { oldObject, newObject in
                        newObject!["name"] = "" // Set default value for the new 'name' property
                    }
                }
            }
        )
    
        Realm.Configuration.defaultConfiguration = config
        _ = try! Realm()
        
        
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
