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
//        setTabBarHeight()
        setTabbar()
        setTabbarShadow()
    }
    
    private func setTabbar(){
        self.selectedIndex = 0
        self.tabBar.tintColor = UIColor(named: "navy00")
    }

    private func setTabBarHeight() {
        // 탭바 높이 조정
        let customTabBar = CustomTabBar()
        let hasBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        customTabBar.customHeight = hasBottomInset ? 90 : 56 // 베젤이 있는 경우와 없는 경우의 높이 설정
        setValue(customTabBar, forKey: "tabBar")
        
    }
    
    private func setTabbarShadow(){
        let appearance = UITabBarAppearance()
        
        let tabBarItemAppearance = UITabBarItemAppearance()

        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 13)]
        tabBarItemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Medium", size: 13)]
        
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
