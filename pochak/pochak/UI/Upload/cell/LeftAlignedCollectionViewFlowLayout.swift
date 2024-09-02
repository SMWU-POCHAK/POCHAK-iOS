//
//  LeftAlignedCollectionViewFlowLayout.swift
//  pochak
//
//  Created by 장나리 on 12/28/23.
//

import Foundation
import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    /// 아이템들의 위치를 조정하여 각 행에서 왼쪽 정렬 되도록 함
    /// Parameter rect: 레이아웃 속성을 반환할 사각형 영역
    /// - Returns: 사각형 내에 포함된 아이템들의 `UICollectionViewLayoutAttributes` 배열
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}
