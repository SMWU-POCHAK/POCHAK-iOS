//
//  NearbyPochakerView.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/22/25.
//

import UIKit
import SnapKit

protocol NearbyPochakerViewDelegate: AnyObject {
    func viewDidTap(_ view: NearbyPochakerView)
}

final class NearbyPochakerView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: NearbyPochakerViewDelegate?
    
    // MARK: - Views
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "pochakIcon")
        view.layer.cornerRadius = 52 / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()
    
    private let handleLabel: UILabel = {
        let label = UILabel()
        //label.text = "handle"
        label.font = UIFont(name: "Pretendard-Regular", size: 13)
        label.textColor = UIColor(hexCode: "2F2E2D")
        label.setLineHeightByPx(value: 18)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        
        addGesture()
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(handle: String) {
        self.init(frame: .zero)
        
        self.handleLabel.text = handle
    }
    
    // MARK: - Layout
    
    private func addViews() {
        self.addSubview(profileImageView)
        self.addSubview(handleLabel)
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(52)
            make.top.equalToSuperview()
        }
        
        handleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Actions
    
    @objc private func viewDidTap() {
        delegate?.viewDidTap(self)
    }
    
    // MARK: - Functions
    
    private func addGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    func getHandle() -> String {
        guard let handle = handleLabel.text else { fatalError("[!] Error: handleLabel.text is nil!")}
        return handle
    }
}
