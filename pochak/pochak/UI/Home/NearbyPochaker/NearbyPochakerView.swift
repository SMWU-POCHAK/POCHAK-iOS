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
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 0
        view.alignment = .center
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "pochakIcon")
        view.layer.cornerRadius = 52.adjusted / 2
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()
    
    private let handleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Pretendard-Regular", size: 13)
        label.textColor = UIColor(hexCode: "2F2E2D")
        label.setLineHeightByPx(value: 18)
        return label
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.alpha = 0
        self.isUserInteractionEnabled = true
        self.translatesAutoresizingMaskIntoConstraints = false
        
        addGesture()
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    convenience init(handle: String) {
//        self.init(frame: .zero)
//        
//        self.handleLabel.text = handle
//    }
    
    // MARK: - Layout
    
    private func addViews() {
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(profileImageView)
        stackView.addArrangedSubview(handleLabel)
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(52.adjusted)
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
    
    func configure(handle: String, profileImgUrl: String) {
        self.handleLabel.text = handle
        if let url = URL(string: profileImgUrl) {
            self.profileImageView.load(with: url)
        }
    }
    
    func getHandle() -> String {
        guard let handle = handleLabel.text else { fatalError("[!] Error: handleLabel.text is nil!")}
        return handle
    }
    
    func showViewWithAnimation(duration: TimeInterval = 1, delay: TimeInterval = 0) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            self.alpha = 1  // 점점 나타남
        })
    }
}
