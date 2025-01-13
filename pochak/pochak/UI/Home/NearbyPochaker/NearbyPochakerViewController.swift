//
//  NearbyPochakerViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/14/25.
//

import UIKit
import SnapKit

final class NearbyPochakerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let circle1Radius: CGFloat = 656
    private let circle2Radius: CGFloat = 484
    private let circle3Radius: CGFloat = 312
    private let circle4Radius: CGFloat = 148
    
    // MARK: - Views
    
    private lazy var circle1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFF6E7", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle1Radius / 2
        return view
    }()
    
    private lazy var circle2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFEED0", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle2Radius / 2
        return view
    }()
    
    private lazy var circle3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFE2AF", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle3Radius / 2
        return view
    }()
    
    private lazy var circle4: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "FFD489", alpha: 0.5)
        view.clipsToBounds = true
        view.layer.cornerRadius = circle4Radius / 2
        return view
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = "내 주변 포착 친구를 찾고, 포착하세요!"
        label.font = UIFont(name: "Pretendard-Semibold", size: 16)
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        self.navigationItem.title = "내 주변 포착"
        
        addViews()
        setupConstraints()
    }
    
    // MARK: - Layout
    
    private func addViews() {
        view.addSubview(circle1)
        view.addSubview(circle2)
        view.addSubview(circle3)
        view.addSubview(circle4)
        view.addSubview(guideLabel)
    }
    
    private func setupConstraints() {
        circle1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(28)
            make.width.height.equalTo(circle1Radius)
        }
        
        circle2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circle1.snp.top).inset((circle1Radius - circle2Radius) / 2)
            make.width.height.equalTo(circle2Radius)
        }
        
        circle3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circle2.snp.top).inset((circle2Radius - circle3Radius) / 2)
            make.width.height.equalTo(circle3Radius)
        }
        
        circle4.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(circle3.snp.top).inset((circle3Radius - circle4Radius) / 2)
            make.width.height.equalTo(circle4Radius)
        }
        
        guideLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(70)
        }
    }
    
    // MARK: - Actions
    
    // MARK: - Functions
}
