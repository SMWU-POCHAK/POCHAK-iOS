//
//  UIImageView+.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/1/24.
//

import UIKit

extension UIImageView {
    
    /// URL에 해당하는 이미지를 UIImageView에 넣는 함수
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
