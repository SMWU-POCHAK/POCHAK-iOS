//
//  AutoSizingCollectionView.swift
//  pochak
//
//  Created by Suyeon Hwang on 2/16/25.
//

import UIKit

/// 스크롤뷰의 하단에 들어가는 컬렉션뷰일 경우 자신의 content size를 알아서 계산할 수 있도록 하는 collection view
final class AutoSizingCollectionView: UICollectionView {
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return contentSize
    }
}
