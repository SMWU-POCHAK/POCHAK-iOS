//
//  TaggedUsersTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 7/26/24.
//

import UIKit

final class TaggedUsersTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TaggedUsersTableViewCell"
    
    // MARK: - Views
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 40 / 2
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.alignment = .leading
        view.distribution = .fill
        return view
    }()
    
    private let handleLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3_1)
        label.numberOfLines = 1
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = .Pretendard(family: .Regular)
        label.setLineHeightByPx(value: 20)
        label.numberOfLines = 1
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Functions
    
    private func addViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        
        [handleLabel, nicknameLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(profileImageView.snp.height).multipliedBy(1)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func configure(tagData: TaggedMember) {
        if let profileImageURL = URL(string: tagData.profileImage) {
            profileImageView.load(with: profileImageURL)
        }
        handleLabel.text = tagData.handle
        nicknameLabel.text = tagData.name
    }
}
