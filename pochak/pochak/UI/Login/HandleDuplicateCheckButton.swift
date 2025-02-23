//
//  HandleDuplicateCheckButton.swift
//  pochak
//
//  Created by Suyeon Hwang on 12/22/24.
//

import UIKit

final class HandleDuplicateCheckButton: UIButton {
    
    // MARK: - Properties
    
    var isActive: Bool = true {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        
        let font = UIFont(name: "Pretendard-Bold", size: 14)
        
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("중복확인")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font : font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: "yellow00")]))
        config.background.cornerRadius = 12.5
        config.contentInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6)
        config.baseBackgroundColor = UIColor(named: "yellow01")
        
        self.configuration = config
        
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            switch self.isActive {
            case true:
                self.isEnabled = true
                button.configuration?.background.backgroundColor = UIColor(named: "yellow01")
                button.configuration?.attributedTitle = AttributedString("중복확인")
                button.configuration?.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor(named: "yellow00"), NSAttributedString.Key.font: font]))
            case false:
                self.isEnabled = false
                button.configuration?.background.backgroundColor = UIColor(named: "gray02")
                button.configuration?.attributedTitle = AttributedString("확인완료")
                button.configuration?.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor(named: "gray04"), NSAttributedString.Key.font: font]))
            }
        }
        
        self.configurationUpdateHandler = buttonStateHandler
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
