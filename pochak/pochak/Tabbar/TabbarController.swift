//
//  TabbarController.swift
//  pochak
//
//  Created by 장나리 on 6/26/24.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabBarHeight()
        setTabbar()
        setTabbarShadow()
        adjustTabBarItemTextPosition()
        
    }
    
    func setTabbar(){
        self.selectedIndex = 0
        self.tabBar.tintColor = UIColor(named: "navy00")
    }
    
    private func setTabBarHeight() {
        
        let customTabBar = CustomTabBar()
        let hasBottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0 > 0
        customTabBar.customHeight = hasBottomInset ? 98 : 58 // 베젤이 있는 경우와 없는 경우의 높이 설정
        setValue(customTabBar, forKey: "tabBar")
        
    }
    
    func setTabbarShadow(){
        let appearance = UITabBarAppearance()
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
    
    func adjustTabBarItemTextPosition() {
            guard let items = tabBar.items else { return }

            // Adjust title position for all tab bar items
            for item in items {
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5) // 텍스트를 위로 5만큼 이동
            }
        }
}
