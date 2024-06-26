//
//  CustomTabbar.swift
//  pochak
//
//  Created by 장나리 on 6/26/24.
//

import UIKit

class CustomTabBar: UITabBar {
    var customHeight: CGFloat = 60 // 원하는 높이 설정

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = customHeight
        return sizeThatFits
    }
}
