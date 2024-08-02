//
//  UIImageView+.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/1/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    
    /// URL에 해당하는 이미지를 UIImageView에 넣는 함수 (with Kingfisher)
    func load(with url: URL) {
        self.kf.cancelDownloadTask()
        self.kf.setImage(with: url, placeholder: UIImage(), options: [.cacheOriginalImage]) { result in
            switch result {
            case .success(let value):
                print("Image successfully loaded: \(value.image)")
            case .failure(let error):
                print("Image failed to load with error: \(error.localizedDescription)")
            }
        }
    }
}
