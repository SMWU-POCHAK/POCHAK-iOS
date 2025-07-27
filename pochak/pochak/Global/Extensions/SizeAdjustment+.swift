//
//  SizeAdjustment+.swift
//  pochak
//
//  Created by Suyeon Hwang on 2/9/25.
//

import UIKit

/**
 - Description:
 스크린 너비 390(아이폰13, 13 Pro)를 기준으로 디자인이 나왔을 때 현재 기기의 스크린 사이즈에 비례하는 수치를 Return합니다.
 현재 디폴트는 아이폰 13 기준입니다.
 
 - Note:
 기기별 대응에 사용하면 됩니다.
 ex) (size: 20.adjusted)
 */
extension CGFloat {
    var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 390
        return self * ratio
    }
    
    /// Height에 대해 resize
    var adjustedH: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 844
        return self * ratio
    }
}

extension Double {
    var adjusted: Double {
        let ratio: Double = Double(UIScreen.main.bounds.width / 390)
        return self * ratio
    }
    
    var adjustedH: Double {
        let ratio: Double = Double(UIScreen.main.bounds.height / 844)
        return self * ratio
    }
}
