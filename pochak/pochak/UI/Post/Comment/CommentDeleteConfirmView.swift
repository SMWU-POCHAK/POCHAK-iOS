//
//  CommentDeleteConfirmView.swift
//  pochak
//
//  Created by Suyeon Hwang on 6/16/25.
//

import UIKit

final class CommentDeleteConfirmView: UIView {
    
    // MARK: - Properties
    
    var cancelButtonAction: (() -> Void)?
    
    // MARK: - Views
    
    private let informationLabel: UILabel = {
        let label = UILabel()
        label.text = "댓글이 삭제되었습니다. 취소하려면 누르세요."
        label.applyPochakFont(.body3)
        label.textColor = .white
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("취소")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.foregroundColor: UIColor.white,
                                                                                 NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .bold)]))
        config.contentInsets = .zero
        button.configuration = config
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(hexCode: "6C757D", alpha: 0.8)
        
        setupView()
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        print("💡 터치된 뷰: \(String(describing: view))")
        print("버튼 인터랙션: \(cancelButton.isUserInteractionEnabled)")
        print("버튼 enabled: \(cancelButton.isEnabled)")
        return view
    }
    
    // MARK: - Layout
    
    private func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 12
    }
    
    private func addViews() {
        self.addSubview(informationLabel)
        self.addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        informationLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.leading.equalToSuperview().inset(17)
            make.trailing.lessThanOrEqualTo(cancelButton.snp.leading).offset(-24)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.centerX.equalTo(informationLabel.snp.centerX)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(33)
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        print("\(#function) -- 삭제 취소")
        cancelButtonAction?()
    }
}
