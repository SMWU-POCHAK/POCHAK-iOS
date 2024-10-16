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
    
//    func changeRootVC(_ vc:UIViewController, animated: Bool) {
//        guard let window = self.window else { return }
//        window.rootViewController = vc // root 전환
//        UIView.transition(with: window, duration: 0.2, options: [.transitionCrossDissolve], animations: nil, completion: nil)
//    }

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
            print("scene delegate login succeed")
            print(keyChainToken)
            let access = GetToken.getAccessToken()
            print(access)
            
            let tabBarController = CustomTabBarController()
        
            window?.rootViewController = tabBarController
            window?.makeKeyAndVisible()
            
        } else {
            // 로그인 안된 상태
            print("scene delegate login not yet!")

            let mainNavigationVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC")
            
            window?.rootViewController = mainNavigationVC
            window?.makeKeyAndVisible()
            
        }
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
}
