//
//  UIAlertController+.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/14/24.
//

import UIKit

extension UIAlertController {
    /// 타이틀에 폰트 적용하는 메소드
    /// - Parameters:
    ///   - family: 폰트 패밀리 (디폴트는 .Bold)
    ///   - size: 폰트 사이즈 (디폴트는 16)
    func setTitleFont(family: UIFont.Family = .Bold, size: CGFloat = 16) {
        guard let title = self.title else { return }
        
        let attributedTitle = NSMutableAttributedString(string: title,
                                                        attributes: [NSAttributedString.Key.font : UIFont.Pretendard(size: size, family: family) as Any])
        setValue(attributedTitle, forKey: "attributedTitle")
    }
    
    
    /// 메시지에 폰트 적용하는 메소드
    /// - Parameters:
    ///   - family: 폰트 패밀리 (디폴트는 Medium)
    ///   - size: 폰트 사이즈 (디폴트는 13)
    func setMessageFont(family: UIFont.Family = .Medium, size: CGFloat = 13) {
        guard let message = self.message else { return }
        
        let attributedMessage = NSMutableAttributedString(string: message,
                                                          attributes: [NSAttributedString.Key.font : UIFont.Pretendard(size: size, family: family) as Any])
        setValue(attributedMessage, forKey: "attributedMessage")
    }
}
