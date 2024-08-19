//
//  SearchResultTableViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/09/03.
//

import UIKit
import Kingfisher

final class SearchResultTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "SearchResultTableViewCell"
    
    var deleteButtonAction: (() -> Void)?
    
    // MARK: - Views

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var deleteBtn: UIImageView!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttribute()
        imageViewClickGesture()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions

    @objc func imageViewTapped() {
           deleteButtonAction?()
    }
    
    // MARK: - Functions

    private func setupAttribute(){
        profileImg.layer.cornerRadius = 52/2
        profileImg.contentMode = .scaleAspectFill
    }
    
    private func imageViewClickGesture(){
        // UITapGestureRecognizer 생성
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))

        // 이미지뷰에 UITapGestureRecognizer 추가
        deleteBtn.addGestureRecognizer(tapGesture)

        // 사용자와 상호 작용이 가능하도록
        deleteBtn.isUserInteractionEnabled = true
    }
}
