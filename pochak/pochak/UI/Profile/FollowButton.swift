//
//  FollowButton.swift
//  pochak
//
//  Created by Suyeon Hwang on 2/28/25.
//

import UIKit

final class FollowButton: UIButton {
    
    // MARK: - Properties
    
    var isFollowing: Bool = true {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: .zero)
        
        let font = UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)
        
        self.configuration = self.configureInitialButtonState(font: font)  // button configuration
        self.configurationUpdateHandler = self.createButtonStateHandler(font: font)  // button state handler
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Function
    
    /// 팔로우버튼의 configuration 초기화
    /// - Parameter font: 팔로우 버튼에 사용할 폰트
    /// - Returns: UIButton.Configuation
    private func configureInitialButtonState(font: UIFont) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("팔로우")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font: font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor.white]))
        config.background.cornerRadius = 15
        config.contentInsets = .init(top: 10, leading: 0, bottom: 10, trailing: 0)
        config.baseBackgroundColor = UIColor(named: "yellow00")
        
        return config
    }
    
    private func createButtonStateHandler(font: UIFont) -> UIButton.ConfigurationUpdateHandler {
        let buttonStateHandler: UIButton.ConfigurationUpdateHandler = { button in
            switch self.isFollowing {
            case true:
                button.configuration?.background.backgroundColor = UIColor(hexCode: "CECCC8")
                button.configuration?.attributedTitle = AttributedString("팔로잉")
                button.configuration?.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]))
            case false:
                button.configuration?.background.backgroundColor = UIColor(named: "yellow00")
                button.configuration?.attributedTitle = AttributedString("팔로우")
                button.configuration?.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: font]))
            }
        }
        return buttonStateHandler
    }
}
