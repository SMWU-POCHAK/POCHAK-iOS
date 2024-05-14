//
//  UITextView+Extension.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/29.
//

import UIKit

// 멘션된 아이디를 clickable하게 바꿔주는 텍스트 뷰
// 한글, 영문, 숫자만 가능
class MentionTextView: UITextView {
    var idArray: [String] = []
    
    
    func findOutMetionedId() {
        self.isEditable = false
        self.isSelectable = true
        self.isScrollEnabled = false
        
        
        // mentionTextView의 텍스트에 기본으로 적용되는 설정 값
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "Pretendard-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 12.0, weight: .medium),
          ]
        
        let nsText: NSString = self.text as NSString
        let attrString = NSMutableAttributedString(string: nsText as String, attributes: attributes)

        // 대소문자 구분없이 해당 @어쩌구저쩌구 형식의 텍스트 탐지기 만들기
        let mentionDetector = try? NSRegularExpression(pattern: "@(\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        
        // 실제로 string에서 탐지
        let results = mentionDetector?.matches(in: self.text,
                                               options: NSRegularExpression.MatchingOptions.withoutAnchoringBounds,
                                               range: NSMakeRange(0, self.text.utf16.count))

        // 탐지된 아이디가 있는지 확인
        guard let results = results else { return }
        
        // 아이디 추출
        idArray = results.map{ (self.text as NSString).substring(with: $0.range(at: 1)) }
                                
        if !idArray.isEmpty {
            var i = 0
            for var word in idArray {
                word = "@" + word
                if word.hasPrefix("@") {
                    let matchRange:NSRange = nsText.range(of: word as String, options: [.caseInsensitive, .backwards])
                    
                    // @로 시작하는 텍스트인 경우의 속성
                    let linkAttributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor(named: "Primary") ?? .black,
                        .font: UIFont(name: "Pretendard-Medium", size: 12.0) ?? UIFont.systemFont(ofSize: 14.0, weight: .regular),
                        .link: "\(i)",
                      ]
                    attrString.setAttributes(linkAttributes, range: matchRange)
                    i += 1
                }
            }
        }

        self.attributedText = attrString
    }
}
