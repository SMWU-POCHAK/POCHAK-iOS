//
//  DeleteViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/13/24.
//

import UIKit

final class DeleteViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "DeleteViewCell"
    
    // MARK: - Views
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12.adjusted
        view.alignment = .center
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "TrashIcon")
        return view
    }()
    
    private let deleteLabel: UILabel = {
        let label = UILabel()
        label.text = "삭제하기"
        label.font = .Pretendard(size: 16, family: .Medium)
        label.setLineHeightByPx(value: 20)
        label.textColor = UIColor(named: "pink00")
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
        
        [iconImageView, deleteLabel].forEach {
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
