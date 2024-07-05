//
//  UILabel+.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/5/24.
//

import UIKit

extension UILabel {
    /// 픽셀 값으로 UILabel의 line height 지정하는 함수
    func setLineHeightByPx(value: CGFloat){
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = value
            style.alignment = .center
            
            attributeString.addAttribute(.paragraphStyle,
                                         value: style,
                                         range: NSRange(location: 0, length: attributeString.length))
            attributedText = attributeString
        }
    }
}
