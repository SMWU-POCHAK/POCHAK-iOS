//
//  OnboardingPageViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/3/25.
//

import UIKit
import SnapKit

class OnboardingPageViewController: UIViewController {
    
    // MARK: - Views
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.displayLarge)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.bodySmall)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    
    init(imageName: String, title: String, subtitle: String) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = UIImage(named: imageName)
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.setGradient(color1: .white, color2: UIColor(hexCode: "FFDA98"), isHorizontal: false)
        addViews()
        setupConstraints()
    }
    
    // MARK: - Functions
    
    private func addViews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12.adjustedH)
            make.centerX.equalTo(titleLabel.snp.centerX)
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(14.adjustedH)
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(21.adjusted)
        }
    }
}
