//
//  FixedTagCollectionViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/29/25.
//

import UIKit
import SnapKit

final class FixedTagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "FixedTagCollectionViewCell"
    
    // MARK: - Views
    
    private let handleLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3_1)
        label.textColor = UIColor(named: "navy00")
        label.text = "handle"
        return label
    }()
    
    private let pinImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "PinIcon")
        return view
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor(named: "yellow00")
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 6
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func addViews() {
        contentView.addSubview(handleLabel)
        contentView.addSubview(pinImageView)
    }
    
    private func setupConstraints() {
        handleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        pinImageView.snp.makeConstraints { make in
            make.leading.equalTo(handleLabel.snp.trailing).offset(4)
            make.centerY.equalTo(handleLabel.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    // MARK: - Functions
    
    func configure(with handle: String) {
        self.handleLabel.text = handle
    }
}
