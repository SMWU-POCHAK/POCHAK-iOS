//
//  CheckButton.swift
//  pochak
//
//  Created by Suyeon Hwang on 11/8/24.
//

import UIKit

final class CheckButton: UIButton {
    
    var isChecked: Bool = false {
        didSet {
            updateButtonConfiguration()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initButton()
        
//        if isSelected {
//            self.layer.backgroundColor = UIColor(named: "yellow00")?.cgColor
//            self.layer.borderColor = nil
//            print("isSelected")
//        }
//        else {
//            self.layer.borderWidth = 1.2
//            self.layer.borderColor = UIColor(named: "gray03")?.cgColor
//            self.layer.backgroundColor = nil
//            print("is not selected")
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func initButton() {
        self.isEnabled = true
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
        updateButtonConfiguration()
    }
    
    private func updateButtonConfiguration() {
        self.isSelected = isChecked
        self.layer.borderWidth = isChecked ? 0 : 1.2
        self.layer.borderColor = isChecked ? nil : UIColor(named: "gray03")?.cgColor
        self.layer.backgroundColor = isChecked ? UIColor(named: "yellow00")?.cgColor : nil
        
        if isChecked {
            self.setImage(UIImage(named: "Checkmark"), for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
        }
        else {
            self.setImage(nil, for: .normal)
        }
    }
}
