//
//  MemorySummaryView.swift
//  pochak
//
//  Created by Haru on 12/2/24.
//

import UIKit
import SnapKit

protocol MemorySummaryViewDelegate: AnyObject {
    func didSelectMemoryCount(type: MemoryType)
}

class MemorySummaryView: UIView {
    weak var delegate: MemorySummaryViewDelegate?
    
    override var intrinsicContentSize: CGSize {
        let width = UIScreen.main.bounds.width - 40
        let height: CGFloat = 210
        return CGSize(width: width, height: height)
    }
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        return view
    }()
    
    private var profileImageGroupView = UIView()
    
    private let friendProfileView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 42
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let myProfileView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 42
        imageView.layer.borderWidth = 1.5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black
        label.applyPochakFont(.body3_1)
        return label
    }()
    
    private let postCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .black
        label.applyPochakFont(.body3_1)
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: MemorySummary) {
        if let url = URL(string: viewModel.memberProfileImage) {
            friendProfileView.load(with: url)
        }
        
        if let url = URL(string: viewModel.loginMemberProfileImage) {
            myProfileView.load(with: url)
        }
        
        if let followDate = viewModel.bondedDate {
            let followPeriod = Date.formatDateRange(fromDateString: followDate)
            dateRangeLabel.text = followPeriod
        }
        
        let followDay = viewModel.followDay ?? 0
        postCountLabel.text = "서로 포착해준지 \(followDay+1)일"
        setupStatsItems(pochakCount: viewModel.pochakCount,
                        bondedCount: viewModel.bondedCount,
                        pochakedCount: viewModel.pochakedCount)
    }
    
    private func configure(memberProfileImage: String,
                           loginMemberProfileImage: String,
                           followedDate: Date,
                           followDay: Int,
                           pochakCount: Int,
                           bondedCount: Int,
                           pochakedCount: Int
    ) {
        if let url = URL(string: memberProfileImage) {
            friendProfileView.load(with: url)
        }
        
        if let url = URL(string: loginMemberProfileImage) {
            myProfileView.load(with: url)
        }
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(dateRangeLabel)
        containerView.addSubview(postCountLabel)
        containerView.addSubview(statsStackView)
        addSubview(profileImageGroupView)
        profileImageGroupView.addSubview(friendProfileView)
        profileImageGroupView.addSubview(myProfileView)
        
        setupConstraints()
    }
    
    private func setupStatsItems(pochakCount: Int,
                                 bondedCount: Int,
                                 pochakedCount: Int
    ) {
        let statsItems: [(MemoryType, Int)] = [
            (.pochak, pochakCount),
            (.bonded, bondedCount),
            (.pochaked, pochakedCount)
        ]
        
        statsItems.forEach { type, count in
            let containerView = createStatsItemView(type: type, count: count)
            statsStackView.addArrangedSubview(containerView)
        }
    }
    
    private func createStatsItemView(type: MemoryType, count: Int) -> UIView {
        let containerButton = UIButton()
        containerButton.tag = type.hashValue
        if count > 0 {
            containerButton.addAction(UIAction { _ in
                self.didSelectMemoryCount(type: type)
            }, for: .touchUpInside)
        }

        
        let titleLabel = UILabel()
        titleLabel.text = type.title
        titleLabel.applyPochakFont(.body3)
        titleLabel.textColor = .black
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        titleLabel.applyPochakFont(.body3_1)
        
        containerButton.addSubview(titleLabel)
        containerButton.addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.centerX.bottom.equalToSuperview()
        }
        
        return containerButton
    }
    
    private func setupConstraints() {
        profileImageGroupView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(148)
            $0.height.equalTo(84)
        }
        
        friendProfileView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(84)
        }
        
        myProfileView.snp.makeConstraints {
            $0.centerY.equalTo(friendProfileView.snp.centerY)
            $0.left.equalTo(friendProfileView.snp.right).offset(-20)
            $0.width.height.equalTo(84)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(profileImageGroupView.snp.bottom).offset(-26)
            $0.height.equalTo(152)
            $0.width.equalToSuperview()
        }
        
        dateRangeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(37)
            $0.centerX.equalToSuperview()
        }
        
        postCountLabel.snp.makeConstraints {
            $0.top.equalTo(dateRangeLabel.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        
        statsStackView.snp.makeConstraints {
            $0.top.equalTo(postCountLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(55)
            $0.height.equalTo(42)
        }
    }
    
    private func didSelectMemoryCount(type: MemoryType) {
        delegate?.didSelectMemoryCount(type: type)
    }
}
