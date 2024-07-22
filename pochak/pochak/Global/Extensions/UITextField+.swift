//
//  UITextField+.swift
//  pochak
//
//  Created by 장나리 on 6/28/24.
//

import UIKit

extension UITextField {
    // placeholder 설정
    func setPlaceholderColor(_ placeholderColor: UIColor?, font: String, fontSize: CGFloat) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor ?? UIColor.lightText,
                .font: UIFont(name: font, size: fontSize)
            ].compactMapValues { $0 }
        )
    }
}
