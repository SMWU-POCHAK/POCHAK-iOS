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
    
    /// UILabel 내의 특정 문자열의 CGRect를 반환하는 메소드
    /// - Parameter subText: CGRect값을 알고 싶은 특정 문자열
    /// - Returns: 해당 문자열의 CGRect
    func boundingRectForCharacterRange(subText: String) -> CGRect? {
        guard let attributedText = attributedText else { return nil }
        guard let text = self.text else { return nil }

        guard let subRange = text.range(of: subText) else { return nil }
        let range = NSRange(subRange, in: text)

        // attributedText를 기반으로 한 NSTextStorage를 선언하고 NSLayoutManager를 추가
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addLayoutManager(layoutManager)

        // instrinsicContentSize를 기반으로 NSTextContainer를 선언
        let textContainer = NSTextContainer(size: intrinsicContentSize)

        // 정확한 CGRect를 구해야하므로 padding 값은 0
        textContainer.lineFragmentPadding = 0.0

        // layoutManager에 추가
        layoutManager.addTextContainer(textContainer)
        var glyphRange = NSRange()

        // 주어진 범위(rage)에 대한 실질적인 glyphRange 구하기
        layoutManager.characterRange(
            forGlyphRange: range,
            actualGlyphRange: &glyphRange
        )

        // textContainer 내의 지정된 glyphRange에 대한 CGRect 값 반환
        return layoutManager.boundingRect(
            forGlyphRange: glyphRange,
            in: textContainer
        )
    }
    
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
