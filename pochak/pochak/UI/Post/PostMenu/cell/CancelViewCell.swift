//
//  CancelViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/13/24.
//

import UIKit

final class CancelViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "CancelViewCell"
    
    // MARK: - Views
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.alignment = .center
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "CancelIcon")
        return view
    }()
    
    private let cancelLabel: UILabel = {
        let label = UILabel()
        label.text = "취소하기"
        label.font = .Pretendard(size: 16, family: .Medium)
        label.setLineHeightByPx(value: 20)
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    private func addViews() {
        contentView.addSubview(stackView)
        
        [iconImageView, cancelLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.adjusted)
            make.top.bottom.equalToSuperview().inset(12.adjustedH)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24.adjusted)
        }
    }
}
