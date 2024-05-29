//
//  TabbarController.swift
//  pochak
//
//  Created by 장나리 on 2023/07/02.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setTabbar()
        setTabbarShadow()
    }
    
    func setTabbar(){
        self.selectedIndex = 0
        self.tabBar.tintColor = UIColor(named: "navy00")
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
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 6
    }
}
