//
//  UIFont+Extension.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

extension UIFont {
    
    enum Family: String {
        case Black, Bold, ExtraBold, ExtraLight, Light, Medium, Regular, SemiBold, Thin
    }
    
    // 디폴트 크기: 14, family: .Regular
    static func Pretendard(size: CGFloat = 14, family: Family = .Regular) -> UIFont {
        return UIFont(name: "Pretendard-\(family)", size: size)!
    }
}
