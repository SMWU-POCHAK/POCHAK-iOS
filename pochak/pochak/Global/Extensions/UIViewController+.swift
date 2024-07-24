//
//  CustomProgressBar.swift
//  pochak
//
//  Created by 장나리 on 7/1/24.
//

import UIKit

extension UIViewController {
    func showProgressBar() {
        let progressBar = UIActivityIndicatorView(style: .large)
        progressBar.center = view.center
        progressBar.startAnimating()
        view.addSubview(progressBar)
    }
    
    func hideProgressBar() {
        if let progressBar = view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            progressBar.stopAnimating()
            progressBar.removeFromSuperview()
        }
    }
}
