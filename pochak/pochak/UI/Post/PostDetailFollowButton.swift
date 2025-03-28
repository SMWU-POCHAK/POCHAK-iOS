//
//  PostDetailFollowButton.swift
//  pochak
//
//  Created by Suyeon Hwang on 3/28/25.
//

import UIKit

final class PostDetailFollowButton: UIButton {

    // MARK: - Properties

    var isFollowing: Bool = true {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    // MARK: - Initialization

    init() {
        super.init(frame: .zero)

        let font = UIFont(name: "Pretendard-Bold", size: 16)

        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString("팔로우")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font : font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor.white]))
        config.background.cornerRadius = 5
        config.contentInsets = .init(top: 8, leading: 14, bottom: 8, trailing: 14)
        config.baseBackgroundColor = UIColor(named: "yellow00")

        self.configuration = config

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

        self.configurationUpdateHandler = buttonStateHandler
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
