//
//  TabbarController.swift
//  pochak
//
//  Created by 장나리 on 6/26/24.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarHeight()
        setTabbar()
        setTabbarShadow()
    }

    private func setTabbar() {
        // 설정할 뷰 컨트롤러들 생성
        let homeTabViewController = UIStoryboard(name: "HomeTab", bundle: nil).instantiateViewController(withIdentifier: "HomeTabViewController")
        let postTabViewController = UIStoryboard(name: "PostTab", bundle: nil).instantiateViewController(withIdentifier: "PostTabViewController")
        let cameraTabViewController = UIStoryboard(name: "CameraTab", bundle: nil).instantiateViewController(withIdentifier: "CameraViewController")
        let alarmTabViewController = UIStoryboard(name: "AlarmTab", bundle: nil).instantiateViewController(withIdentifier: "AlarmViewController")
        let myProfileViewController = UIStoryboard(name: "ProfileTab", bundle: nil).instantiateViewController(withIdentifier: "MyProfileTabVC")
        
        let homeNavController = UINavigationController(rootViewController: homeTabViewController)
        let postNavController = UINavigationController(rootViewController: postTabViewController)
        let cameraNavController = UINavigationController(rootViewController: cameraTabViewController)
        let alarmNavController = UINavigationController(rootViewController: alarmTabViewController)
        let myProfileNavController = UINavigationController(rootViewController: myProfileViewController)

        // 탭 바 컨트롤러에 뷰 컨트롤러들 설정
        self.setViewControllers([homeNavController, postNavController, cameraNavController, alarmNavController, myProfileNavController], animated: false)

        // 탭 바 아이템 설정
        if let items = tabBar.items {
            items[0].selectedImage = UIImage(named: "home_logo_fill")?.withRenderingMode(.alwaysOriginal)
            items[0].image = UIImage(named: "home_logo")?.withRenderingMode(.alwaysOriginal)
            items[0].title = "홈"
            
            items[1].selectedImage = UIImage(named: "post_fill")?.withRenderingMode(.alwaysOriginal)
            items[1].image = UIImage(named: "post")?.withRenderingMode(.alwaysOriginal)
            items[1].title = "탐색"

            items[2].selectedImage = UIImage(named: "pochak_fill")?.withRenderingMode(.alwaysOriginal)
            items[2].image = UIImage(named: "pochak")?.withRenderingMode(.alwaysOriginal)
            items[2].title = "카메라"

            items[3].selectedImage = UIImage(named: "alarm_fill")?.withRenderingMode(.alwaysOriginal)
            items[3].image = UIImage(named: "alarm")?.withRenderingMode(.alwaysOriginal)
            items[3].title = "알림"

            items[4].selectedImage = UIImage(named: "profile_fill")?.withRenderingMode(.alwaysOriginal)
            items[4].image = UIImage(named: "profile")?.withRenderingMode(.alwaysOriginal)
            items[4].title = "프로필"
        }

        // 기본 선택 인덱스 설정
        self.selectedIndex = 0

        // 탭 바의 틴트 색상 설정
        self.tabBar.tintColor = UIColor(named: "navy00")
    }

    private func setTabBarHeight() {
        // 탭바 높이 조정
        let customTabBar = CustomTabBar()
        let hasBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        customTabBar.customHeight = hasBottomInset ? 94 : 64 // 베젤이 있는 경우와 없는 경우의 높이 설정
        setValue(customTabBar, forKey: "tabBar")
        
    }
    
    private func setTabbarShadow(){
        let appearance = UITabBarAppearance()
        
        let tabBarItemAppearance = UITabBarItemAppearance()

        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 13)]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 13)]
        tabBarItemAppearance.normal.titlePositionAdjustment = .init(horizontal: 0, vertical: -5)
        tabBarItemAppearance.selected.titlePositionAdjustment = .init(horizontal: 0, vertical: -5)
        
        appearance.stackedLayoutAppearance = tabBarItemAppearance

        
        // set tabbar opacity
        appearance.configureWithOpaqueBackground()

        // remove tabbar border line
        appearance.shadowColor = UIColor.clear

        // set tabbar background color
        appearance.backgroundColor = .white

        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
                // set tabbar opacity
                tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }

        // set tabbar tintColor
        tabBar.tintColor = .black

        // set tabbar shadow
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor(red: 0.8471, green: 0.8627, blue: 0.8902, alpha: 1.0).cgColor /* #d8dce3 */
        tabBar.layer.shadowOpacity = 0.6  // 60% opacity
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 4)  // Shadow height of 4px
        tabBar.layer.shadowRadius = 20
    }
}
