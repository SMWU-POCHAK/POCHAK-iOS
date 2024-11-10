//
//  TermsOfAgreeViewController.swift
//  pochak
//
//  Created by Seo Cindy on 7/7/24.
//

import UIKit
import SafariServices

final class TermsOfAgreeViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - Properties
    
    var didAgreeForAll: Bool = false {
        didSet {
            if didAgreeForAll {
                agreeToAllButton.isChecked = true
                nextButton.isActive = true
            }
            else {
                agreeToAllButton.isChecked = false
                nextButton.isActive = false
            }
        }
    }
    
    var didAgreeForPrivacyPolicy: Bool = false {
        didSet {
            privacyPolicyAgreeButton.isChecked = didAgreeForPrivacyPolicy
        }
    }

    var didAgreeForTermsOfUse: Bool = false {
        didSet {
            termsOfUseAgreeButton.isChecked = didAgreeForTermsOfUse
        }
    }
    var delegate: SendDelegate?
    
    // MARK: - Views
    
    private let pochakLetterLogoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logo_full")
        return view
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용을 위해\n이용약관 동의가 필요합니다."
        label.font = UIFont(name: "Pretendard-Bold", size: 26)
        label.numberOfLines = 2
        return label
    }()
    
    private let agreeToAllLabel: UILabel = {
        let label = UILabel()
        label.text = "약관 전체 동의"
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        return label
    }()
    
    private let agreeToAllButton: CheckButton = {
        let button = CheckButton()
        button.addTarget(self, action: #selector(agreeToAllButtonDidTap), for: .touchUpInside)
        button.isChecked = false
        return button
    }()
    
    private let borderLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "gray00")
        return view
    }()
    
    private let termsOfUseAgreeLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let termsOfUseAgreeButton: CheckButton = {
        let button = CheckButton()
        button.addTarget(self, action: #selector(termsOfUseAgreeButtonDidTap), for: .touchUpInside)
        button.isChecked = false
        return button
    }()
    
    private let privacyPolicyAgreeLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let privacyPolicyAgreeButton: CheckButton = {
        let button = CheckButton()
        button.addTarget(self, action: #selector(privacyPolicyAgreeButtonDidTap), for: .touchUpInside)
        button.isChecked = false
        return button
    }()
    
    private let nextButton: NextButton = {
        let button = NextButton()
        button.isActive = false
        button.addTarget(self, action: #selector(nextButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupPochakLogoImageView()
        setupGuideLabel()
        setupAgreeToAllLabel()
        setupAgreeToAllButton()
        setupBorderLine()
        setupTermsOfUseAgreeLabel()
        setupTermsOfUseAgreeButton()
        setupPrivacyPolicyAgreeLabel()
        setupPrivacyPolicyAgreeButton()
        setupNextButton()
    }
    
    // MARK: - Actions
    
    @objc private func termsOfUseAgreeButtonDidTap() {
        print("이용약관 선택됨")
        termsOfUseAgreeButton.isChecked.toggle()
        didAgreeForTermsOfUse = termsOfUseAgreeButton.isChecked
        checkEachAgreeStatus()
    }
    
    @objc private func privacyPolicyAgreeButtonDidTap() {
        print("개인정보 동의 선택됨")
        privacyPolicyAgreeButton.isChecked.toggle()
        didAgreeForPrivacyPolicy = privacyPolicyAgreeButton.isChecked
        checkEachAgreeStatus()
    }
    
    @objc private func termsOfUseLabelDidTap(_ sender: UITapGestureRecognizer) {
        // termsOfUseAgreeLabel에서 선택된 부분의 CGPoint 구하기
        let point = sender.location(in: termsOfUseAgreeLabel)
        
        if let rect = termsOfUseAgreeLabel.boundingRectForCharacterRange(subText: "이용약관"), rect.contains(point) {
            guard let url = URL(string: "https://pochak.notion.site/6520996186464c36a8b3a04bc17fa000?pvs=74") else { return }
            let safariVC = SFSafariViewController(url: url)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet

            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc private func privacyPolicyLabelDidTap(_ sender: UITapGestureRecognizer) {
        // privacyPolicyAgreeLabel에서 선택된 부분의 CGPoint 구하기
        let point = sender.location(in: privacyPolicyAgreeLabel)
        
        if let rect = privacyPolicyAgreeLabel.boundingRectForCharacterRange(subText: "개인정보 수집 및 제공"), rect.contains(point) {
            guard let url = URL(string: "https://pochak.notion.site/e365e34f018949b88543adbe6b0b3746") else { return }
            let safariVC = SFSafariViewController(url: url)
            safariVC.transitioningDelegate = self
            safariVC.modalPresentationStyle = .pageSheet
            present(safariVC, animated: true, completion: nil)
        }
    }
    
    @objc private func agreeToAllButtonDidTap() {
        print("전체 동의 눌림")
        agreeToAllButton.isChecked.toggle()
        didAgreeForAll = agreeToAllButton.isChecked
        changeAllAgreeStatus()
    }
    
    @objc private func nextButtonDidTap() {
        if didAgreeForAll {
            self.dismiss(animated: true)
            delegate?.sendAgreed(agree: true)
        }
    }
    
    // MARK: - Layout
    
    private func setupPochakLogoImageView() {
        view.addSubview(pochakLetterLogoImageView)
        
        pochakLetterLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pochakLetterLogoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            pochakLetterLogoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
        ])
    }
    
    private func setupGuideLabel() {
        view.addSubview(guideLabel)
        
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            guideLabel.leadingAnchor.constraint(equalTo: pochakLetterLogoImageView.leadingAnchor),
            guideLabel.topAnchor.constraint(equalTo: pochakLetterLogoImageView.bottomAnchor, constant: 8),
            
        ])
    }
    
    private func setupAgreeToAllLabel() {
        view.addSubview(agreeToAllLabel)
        
        agreeToAllLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            agreeToAllLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 26),
            agreeToAllLabel.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 127),
        ])
    }
    
    private func setupAgreeToAllButton() {
        view.addSubview(agreeToAllButton)
        
        agreeToAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            agreeToAllButton.widthAnchor.constraint(equalToConstant: 20),
            agreeToAllButton.heightAnchor.constraint(equalTo: agreeToAllButton.widthAnchor, multiplier: 1),
            agreeToAllButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            agreeToAllButton.centerYAnchor.constraint(equalTo: agreeToAllLabel.centerYAnchor)
        ])
    }
    
    private func setupBorderLine() {
        view.addSubview(borderLine)
        
        borderLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            borderLine.heightAnchor.constraint(equalToConstant: 1),
            borderLine.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            borderLine.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            borderLine.topAnchor.constraint(equalTo: agreeToAllLabel.bottomAnchor, constant: 13)
        ])
    }
    
    private func setupTermsOfUseAgreeLabel() {
        view.addSubview(termsOfUseAgreeLabel)
        
        termsOfUseAgreeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        configureUnderlineAttributes(linkText: "이용약관",
                                     generalText: String(format: "[필수]  %@ 동의", "이용약관"),
                                     label: termsOfUseAgreeLabel)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(termsOfUseLabelDidTap(_: )))
        termsOfUseAgreeLabel.addGestureRecognizer(recognizer)
        
        NSLayoutConstraint.activate([
            termsOfUseAgreeLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            termsOfUseAgreeLabel.topAnchor.constraint(equalTo: borderLine.bottomAnchor, constant: 17)
        ])
    }
    
    private func setupTermsOfUseAgreeButton() {
        view.addSubview(termsOfUseAgreeButton)
        
        termsOfUseAgreeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            termsOfUseAgreeButton.trailingAnchor.constraint(equalTo: agreeToAllButton.trailingAnchor),
            termsOfUseAgreeButton.centerYAnchor.constraint(equalTo: termsOfUseAgreeLabel.centerYAnchor),
            termsOfUseAgreeButton.widthAnchor.constraint(equalToConstant: 20),
            termsOfUseAgreeButton.heightAnchor.constraint(equalTo: termsOfUseAgreeButton.widthAnchor, multiplier: 1)
        ])
    }
    
    private func setupPrivacyPolicyAgreeLabel() {
        view.addSubview(privacyPolicyAgreeLabel)
        
        privacyPolicyAgreeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        configureUnderlineAttributes(linkText: "개인정보 수집 및 제공",
                                     generalText: String(format: "[필수]  %@ 동의", "개인정보 수집 및 제공"),
                                     label: privacyPolicyAgreeLabel)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyLabelDidTap(_: )))
        privacyPolicyAgreeLabel.addGestureRecognizer(recognizer)
        
        NSLayoutConstraint.activate([
            privacyPolicyAgreeLabel.leadingAnchor.constraint(equalTo: termsOfUseAgreeLabel.leadingAnchor),
            privacyPolicyAgreeLabel.topAnchor.constraint(equalTo: termsOfUseAgreeLabel.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupPrivacyPolicyAgreeButton() {
        view.addSubview(privacyPolicyAgreeButton)
        
        privacyPolicyAgreeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            privacyPolicyAgreeButton.trailingAnchor.constraint(equalTo: termsOfUseAgreeButton.trailingAnchor),
            privacyPolicyAgreeButton.centerYAnchor.constraint(equalTo: privacyPolicyAgreeLabel.centerYAnchor),
            privacyPolicyAgreeButton.widthAnchor.constraint(equalToConstant: 20),
            privacyPolicyAgreeButton.heightAnchor.constraint(equalTo: privacyPolicyAgreeButton.widthAnchor, multiplier: 1)
        ])
    }
    
    private func setupNextButton() {
        view.addSubview(nextButton)
        
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nextButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    // MARK: - Functions
    
    private func configureUnderlineAttributes(linkText: String, generalText: String, label: UILabel) {
        let generalFont = UIFont(name: "Pretendard-Medium", size: 16)

        // NSAttributedString.Key, Value 속성 정의
        let generalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "gray05"),
            .font: generalFont
        ]
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(named: "gray05"),
            .font: generalFont
        ]
        
        let mutableString = NSMutableAttributedString()

        // generalAttributes(기본 스타일) 적용
        mutableString.append(
            NSAttributedString(string: generalText, attributes: generalAttributes)
        )

        // 각 문자열의 range에 linkAttributes 적용
        mutableString.setAttributes(
            linkAttributes,
            range: (generalText as NSString).range(of: linkText)
        )

        label.attributedText = mutableString
    }
    
    private func changeAllAgreeStatus() {
        didAgreeForTermsOfUse = didAgreeForAll
        didAgreeForPrivacyPolicy = didAgreeForAll
    }
    
    private func checkEachAgreeStatus() {
        didAgreeForAll = didAgreeForTermsOfUse && didAgreeForPrivacyPolicy
    }
}

extension UIButton {
    func setUnderline() {
        guard let title = title(for: .normal) else { return }
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: title.count)
        )
        setAttributedTitle(attributedString, for: .normal)
    }
}
