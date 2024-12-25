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

extension UILabel {
    func applyPochakFont(_ config: PochakFontConfig) {
        self.font = config.font
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = config.lineHeight - config.font.lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: config.font,
            .paragraphStyle: paragraphStyle
        ]
        
        if let text = self.text {
            self.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        
        let padding = (config.lineHeight - config.font.lineHeight) / 2
        self.layoutMargins = UIEdgeInsets(top: padding,
                                          left: self.layoutMargins.left,
                                          bottom: padding,
                                          right: self.layoutMargins.right)
    }
}

extension UITextView {
    func applyPochakFont(_ config: PochakFontConfig) {
        self.font = config.font
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = config.lineHeight - config.font.lineHeight
        paragraphStyle.alignment = self.textAlignment
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: config.font,
            .paragraphStyle: paragraphStyle
        ]
        
        if let text = self.text {
            self.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
        
        let padding = (config.lineHeight - config.font.lineHeight) / 2
        self.textContainerInset = UIEdgeInsets(top: padding,
                                               left: self.textContainerInset.left,
                                               bottom: padding,
                                               right: self.textContainerInset.right)
    }
}
