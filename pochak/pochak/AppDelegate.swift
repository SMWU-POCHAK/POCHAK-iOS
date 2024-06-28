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
        
        // 탭바 폰트 설정
        let appearance = UITabBarItem.appearance()
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium)
        ]
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .normal)
        appearance.setTitleTextAttributes(attributes as [NSAttributedString.Key : Any], for: .selected)
        
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
                
        return true
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
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var handled: Bool

          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }

          // Handle other custom URL types.

          // If not handled by this app, return false.
          return false
    }

}

