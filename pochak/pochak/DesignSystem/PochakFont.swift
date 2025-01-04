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
    
    case displayLarge
    case displayMedium
    case displaySmall
    case headlineLarge
    case headlineMedium
    case bodyLarge
    case bodyMedium
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
        case .body3:
            return 13
        case .body3_1:
            return 14
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
        case .bodyExtraSmall, .bodyMini:
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
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .displayLarge, .displayMedium:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .displaySmall:
            return UIFont.systemFont(ofSize: size, weight: .medium)
        case .headlineLarge:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .headlineMedium:
            return UIFont.systemFont(ofSize: size, weight: .medium)
        case .bodyLarge, .bodyMedium, .bodyMini:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .bodySmall:
            return UIFont.systemFont(ofSize: size, weight: .medium)
        case .bodyExtraSmall:
            return UIFont.systemFont(ofSize: size, weight: .regular)
        case .captionLarge:
            return UIFont.systemFont(ofSize: size, weight: .bold)
        case .captionMedium:
            return UIFont.systemFont(ofSize: size, weight: .medium)
        case .captionSmall:
            return UIFont.italicSystemFont(ofSize: size)
        case .captionExtraSmall:
            return UIFont.systemFont(ofSize: size, weight: .regular)
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
        case .bodyExtraSmall, .bodyMini:
            return 20
        case .captionLarge, .captionMedium:
            return 16
        case .captionSmall, .captionExtraSmall:
            return 16
        }
    }
}
