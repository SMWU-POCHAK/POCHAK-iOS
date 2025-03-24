//
//  SceneDelegate.swift
//  pochak
//
//  Created by 장나리 on 2023/06/26.
//

import UIKit
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Main.storyboard 가져오기
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        if let keyChainToken = (try? KeychainManager.load(account: "accessToken")) {
            // 로그인 된 상태
            print(keyChainToken)
            let access = GetToken.getAccessToken()
            print(access)
            
            let tabBarController = CustomTabBarController()
            
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
        } else {
            // 로그인 안된 상태
            print("New User")

            let mainNavigationVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC")
            
            window?.rootViewController = mainNavigationVC
            window?.makeKeyAndVisible()
        }
        
        self.checkAndUpdateIfNeeded()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("=== scene will enter foreground ===")
        //self.checkAndUpdateIfNeeded()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // Root 화면 전환
    func changeRootViewController (_ vc: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        window.rootViewController = vc // 화면 전환
    }
    
    // Google 로그인
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
            let _ = GIDSignIn.sharedInstance.handle(url)
        }
    
    // 업데이트가 필요한지 확인 후 업데이트 alert을 띄우는 메소드
    func checkAndUpdateIfNeeded() {
        print("=== check and update if needed ===")
        let latestVersion = AppStoreUpdateManager.shared.getLatestVersion()
        
        DispatchQueue.main.async {
            guard let marketingVersion = latestVersion else {
                print("[!] Error - Failed to find AppStore marketing version.")
                return
            }

            // 현재 기기의 버전
            let currentProjectVersion = AppStoreUpdateManager.currentAppVersion ?? ""

            let splitMarketingVersionByDot = marketingVersion.split(separator: ".").map { $0 }
            let splitCurrentProjectVersionByDot = currentProjectVersion.split(separator: ".").map { $0 }
            print("[Version Update] marketing version: \(splitMarketingVersionByDot)")
            print("[Version Update] current version: \(splitCurrentProjectVersionByDot)")
            do {
                print(">> [Version Update] Refresh token is...")
                try print(KeychainManager.load(account: "refreshToken"))
            } catch {
                print("[!] Error - failed to load refresh token")
            }

            if splitCurrentProjectVersionByDot.count > 0 && splitMarketingVersionByDot.count > 0 {
                // 현재 기기의 Major, Minor 버전이 앱스토어의 Major, Minor 버전보다 낮다면 Alert
                if splitCurrentProjectVersionByDot[0] < splitMarketingVersionByDot[0] {
                    UserDefaultsManager.setData(value: false, key: .rejectedUpdateBefore)
                    self.showUpdateAlert(isForcedToUpdate: true)
                }
                else if splitCurrentProjectVersionByDot[1] < splitMarketingVersionByDot[1] {
                    UserDefaultsManager.setData(value: false, key: .rejectedUpdateBefore)
                    self.showUpdateAlert(isForcedToUpdate: true)
                }
                // Patch의 버전이 다르면
                else if splitCurrentProjectVersionByDot[2] < splitMarketingVersionByDot[2]{
                    print(">> [Version Update] Patch version is different.")
                    let rejectedUpdateBefore = UserDefaultsManager.getData(type: Bool.self, forKey: .rejectedUpdateBefore)
                    if !(rejectedUpdateBefore ?? false) {
                        print(">> [Version Update] Has not rejected update, show alert.")
                        self.showUpdateAlert(isForcedToUpdate: false)
                    }
                }
            }
        }
    }
    
    /// 업데이트 알림을 띄우는 메소드입니다.
    /// - Parameter isForcedToUpdate: 강제 업데이트할지의 여부
    func showUpdateAlert(isForcedToUpdate: Bool) {
        print(">> [Version Update] App is not in its latest version.")
        let alert = UIAlertController(
            title: "새로운 버전 업데이트",
            message: "안정적인 서비스 사용을 위해\n최신 버전으로 업데이트 해주세요.",
            preferredStyle: .alert
        )
        
        if isForcedToUpdate {
            let updateAction = UIAlertAction(title: "업데이트 하러가기", style: .default) { _ in
                AppStoreUpdateManager.shared.openAppStore()
            }
            alert.addAction(updateAction)
        }
        else {
            let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
                UserDefaultsManager.setData(value: false, key: .rejectedUpdateBefore)
                AppStoreUpdateManager.shared.openAppStore()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                UserDefaultsManager.setData(value: true, key: .rejectedUpdateBefore)  // 다음 번에 앱 실행했을 때 또 업데이트 알림을 띄우지 않기 위해
            }
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
        }
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
