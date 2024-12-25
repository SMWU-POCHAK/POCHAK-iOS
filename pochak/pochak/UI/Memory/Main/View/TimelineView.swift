//
//  TimelineView.swift
//  pochak
//
//  Created by Haru on 12/2/24.
//

import UIKit
import SnapKit

class TimelineView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "타임라인"
        label.applyPochakFont(.body0)
        return label
    }()
    
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.text = "2024년 5월 14일 ~ 2024년 10월 5일"
        label.applyPochakFont(.captionMedium)
        label.textColor = .black
        return label
    }()
    
    private let timelineStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .top
        stack.spacing = 16
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        followPeriod: String,
        with timeLineItemList: [TimelineItem]
    ) {
        dateRangeLabel.text = followPeriod
        timeLineItemList.forEach { item in
            let itemView = createTimelineItemView(item: item)
            timelineStackView.addArrangedSubview(itemView)
        }
        layoutIfNeeded()
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateRangeLabel)
        containerView.addSubview(timelineStackView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.height.equalTo(24)
        }
        
        dateRangeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        
        timelineStackView.snp.makeConstraints {
            $0.top.equalTo(dateRangeLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func createTimelineItemView(item: TimelineItem) -> UIView {
        let containerView = UIView()
        let textContainerView = UIView()
        
        let dateLabel = UILabel()
        dateLabel.text = Date.formatTimelineDate(fromDateString: item.date ?? "")
        dateLabel.applyPochakFont(.captionMedium)
        dateLabel.textColor = .black
        
        let iconImageView = UIImageView()
        iconImageView.image = item.icon == .profile ?
        UIImage(resource: .icProfile)
        : UIImage(resource: .icCamera)
        iconImageView.tintColor = .black
        iconImageView.contentMode = .scaleAspectFit
        
        let messageLabel = UILabel()
        messageLabel.text = item.message
        messageLabel.applyPochakFont(.bodyMini)
        messageLabel.textColor = .black.withAlphaComponent(0.55)
        messageLabel.numberOfLines = 0
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(textContainerView)
        textContainerView.addSubview(dateLabel)
        textContainerView.addSubview(messageLabel)
        
        containerView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(35)
        }
        
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
        }
        
        textContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).offset(18)
        }
        
        return containerView
    }
}
