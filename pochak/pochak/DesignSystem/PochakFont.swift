//
//  PochakFontConfig.swift
//  pochak
//
//  Created by Haru on 12/25/24.
//

import UIKit

enum PochakFontConfig {
    case body0
    case body3
    case body3_1
    case body4
    
    case displayLarge
    case displayMedium
    case displaySmall
    case headlineLarge
    case headlineMedium
    case bodyLarge
    case bodyMedium
    case bodyMediumSmall
    case bodySmall
    case bodyExtraSmall
    case bodyMini
    case captionLarge
    case captionMedium
    case captionSmall
    case captionExtraSmall
    
    var size: CGFloat {
        switch self {
        case .body0:
            return 18
        case .body3, .body3_1:
            return 14
        case .body4:
            return 13
        case .displayLarge:
            return 26
        case .displayMedium, .displaySmall:
            return 22
        case .headlineLarge, .headlineMedium:
            return 20
        case .bodyLarge:
            return 18
        case .bodyMedium, .bodySmall:
            return 16
        case .bodyMediumSmall, .bodyExtraSmall, .bodyMini:
            return 14
        case .captionLarge, .captionMedium:
            return 12
        case .captionSmall, .captionExtraSmall:
            return 11

        }
    }
    
    var font: UIFont {
        switch self {
        case .body0, .body3, .body3_1:
            return .Pretendard(size: size, family: .Bold)
        case .body4:
            return .Pretendard(size: size, family: .Medium)
        case .displayLarge, .displayMedium:
            return .Pretendard(size: size, family: .Bold)
        case .displaySmall:
            return .Pretendard(size: size, family: .Medium)
        case .headlineLarge:
            return .Pretendard(size: size, family: .Bold)
        case .headlineMedium:
            return .Pretendard(size: size, family: .Medium)
        case .bodyLarge, .bodyMedium, .bodyMini:
            return .Pretendard(size: size, family: .Bold)
        case .bodySmall:
            return .Pretendard(size: size, family: .Medium)
        case .bodyMediumSmall, .bodyExtraSmall:
            return .Pretendard(size: size, family: .Regular)
        case .captionLarge:
            return .Pretendard(size: size, family: .Bold)
        case .captionMedium:
            return .Pretendard(size: size, family: .Medium)
        case .captionSmall:
            return UIFont.italicSystemFont(ofSize: size)
        case .captionExtraSmall:
            return .Pretendard(size: size, family: .Regular)
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .body0:
            return 24
        case .body3:
            return 18
        case .body3_1:
            return 16.8
        case .body4:
            return 18
        case .displayLarge:
            return 30
        case .displayMedium, .displaySmall:
            return 28
        case .headlineLarge:
            return 28
        case .headlineMedium:
            return 26
        case .bodyLarge:
            return 24
        case .bodyMedium, .bodySmall:
            return 22
        case .bodyMediumSmall, .bodyExtraSmall, .bodyMini:
            return 20
        case .captionLarge, .captionMedium:
            return 16
        case .captionSmall, .captionExtraSmall:
            return 16
        }
    }
}
