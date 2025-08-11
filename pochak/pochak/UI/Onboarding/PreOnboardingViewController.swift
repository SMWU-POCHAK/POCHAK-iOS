//
//  PreOnboardingViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/2/25.
//

import UIKit
import SnapKit

protocol PreOnboardingDelegate: AnyObject {
    func didTapStartButton(_ preOnboardingVC: PreOnboardingViewController)
}

class PreOnboardingViewController: UIViewController {

    // MARK: - Properties
    
    weak var preOnboardingDelegate: PreOnboardingDelegate?
    
    // MARK: - Views
    
    private let logoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "wordLogoBig")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let sloganImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pochak_slogan")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let startButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        
        let font = UIFont(name: "Pretendard-Bold", size: 16)
        config.attributedTitle = AttributedString("시작하기")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font: font,
                                                                  NSAttributedString.Key.foregroundColor: UIColor.white]))
        config.background.cornerRadius = 15
        config.contentInsets = .init(top: 13.adjustedH, leading: .zero, bottom: 13.adjustedH, trailing: .zero)
        config.baseBackgroundColor = UIColor(named: "yellow00")

        button.configuration = config
        button.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        addViews()
        setupConstraints()
    }
    
    // MARK: - Actions
    
    @objc private func didTapStartButton() {
//        let onboardingViewController = OnboardingViewController()
//        navigationController?.pushViewController(onboardingViewController, animated: true)
        preOnboardingDelegate?.didTapStartButton(self)
    }
    
    // MARK: - Functions
    
    private func addViews() {
        view.addSubview(logoImageView)
        view.addSubview(sloganImageView)
        view.addSubview(startButton)
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(300.adjustedH)
            make.height.equalTo(38.adjustedH)
            make.centerX.equalToSuperview()
        }
        sloganImageView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(12.adjustedH)
            make.height.equalTo(18.adjustedH)
            make.centerX.equalToSuperview()
        }
        startButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20.adjusted)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

}
