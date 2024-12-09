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

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var realmManager = RecentSearchRealmManager()
    
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
        
        // 앱 첫 실행 시 keyChain 정보를 삭제
        removeKeychainAtFirstLaunch()
        return true
    }

    private func removeKeychainAtFirstLaunch() {
        guard UserDefaults.isFirstLaunch() else {
            return
        }
        do {
            try KeychainManager.delete(account: "accessToken")
            try KeychainManager.delete(account: "refreshToken")
        } catch {
            print(error)
        }
    }
    
    // 리프레시 토큰 유효성 검사
    func applicationDidBecomeActive(_ application: UIApplication) {
        handleRefreshToken()
    }
    
    private func handleRefreshToken() {
        if !isRefreshTokenValid() {
            deleteUserData()
            moveToMainPage()
        }
    }
    
    private func isRefreshTokenValid() -> Bool {
        guard let issuedAt = UserDefaultsManager.getData(type: Date.self, forKey: .refreshTokenIssuedAt) else {
            return false // 발급 시점을 알 수 없으면 토큰이 유효하지 않음
        }
        let validityPeriod: TimeInterval = 30 * 24 * 60 * 60 // 1달(30일)을 초 단위로
        let expirationDate = issuedAt.addingTimeInterval(validityPeriod)
        
        return Date() < expirationDate // 현재 시간과 만료 시간을 비교
    }
    
    private func deleteUserData() {
        do {
            // Keychain 삭제
            try KeychainManager.delete(account: "accessToken")
            try KeychainManager.delete(account: "refreshToken")
            
            // 최근 검색 기록 삭제
            if realmManager.deleteAllData() {
                print("Successfully deleted all data")
            } else {
                print("Failed to delete all data")
            }
            
            // UserDefaults 삭제
            UserDefaultsManager.UserDefaultsKeys.allCases.forEach { key in
                UserDefaultsManager.removeData(key: key)
            }
        } catch {
            print(error)
        }
    }
    
    private func moveToMainPage() {
        let mainVCBundle = UIStoryboard.init(name: "Login", bundle: nil)
        guard let mainVC = mainVCBundle.instantiateViewController(withIdentifier: "NavigationVC") as? NavigationController else { return }
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainVC, animated: false)
    }

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
    
    // Google 로그인 등록
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
