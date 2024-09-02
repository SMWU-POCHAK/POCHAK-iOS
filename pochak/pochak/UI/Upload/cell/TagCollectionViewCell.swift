//
//  TagCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/07/23.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TagCollectionViewCell"
    
    var deleteButtonAction: (() -> Void)?

    // MARK: - Views

    @IBOutlet weak var deleteBtn: UIImageView!
    @IBOutlet weak var tagIdLabel: UILabel!
            
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewCornerRadius()
        setupDeleteButton()
    }
    
    // MARK: - Actions

    @objc private func deleteButtonTapped() {
        deleteButtonAction?()
    }
    
    // MARK: - Functions
    
    private func setupViewCornerRadius() {
        self.layer.cornerRadius = 6
    }

    private func setupDeleteButton() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteButtonTapped))
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(tapGestureRecognizer)
    }
}
