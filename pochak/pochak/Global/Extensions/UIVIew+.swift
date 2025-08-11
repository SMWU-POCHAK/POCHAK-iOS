//
//  UIVIew.swift
//  pochak
//
//  Created by 장나리 on 6/30/24.
//

import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func setGradient(color1: UIColor, color2: UIColor, isHorizontal: Bool){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor,color2.cgColor]
        gradient.locations = [0.0, 1.0]
        if isHorizontal {
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
//        else {
//            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
//            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
//        }
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
}
