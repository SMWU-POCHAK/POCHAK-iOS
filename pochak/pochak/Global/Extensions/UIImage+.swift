//
//  UIImage+.swift
//  pochak
//
//  Created by Suyeon Hwang on 6/23/24.
//

import UIKit

extension UIImage {
    func resizeImage(size: CGSize) -> UIImage {
      let originalSize = self.size
      let ratio: CGFloat = {
          return originalSize.width > originalSize.height ? 1 / (size.width / originalSize.width) :
                                                            1 / (size.height / originalSize.height)
      }()

      return UIImage(cgImage: self.cgImage!, scale: self.scale * ratio, orientation: self.imageOrientation)
    }
    
    convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}
