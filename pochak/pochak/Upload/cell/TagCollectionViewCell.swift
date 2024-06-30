//
//  TagCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/07/23.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteBtn: UIImageView!
    @IBOutlet weak var tagIdLabel: UILabel!
    
    static let identifier = "TagCollectionViewCell"
    
    var deleteButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViewCornerRadius()
        setupDeleteButton()
    }
    
    private func setupViewCornerRadius(){
        self.layer.cornerRadius = 6
    }

    private func setupDeleteButton() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteButtonTapped))
        deleteBtn.isUserInteractionEnabled = true
        deleteBtn.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func deleteButtonTapped() {
        deleteButtonAction?()
    }
}
