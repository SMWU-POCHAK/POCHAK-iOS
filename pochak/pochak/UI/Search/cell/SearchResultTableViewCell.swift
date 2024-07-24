//
//  SearchResultTableViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/09/03.
//

import UIKit
import Kingfisher

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var deleteBtn: UIImageView!
    
    static let identifier = "SearchResultTableViewCell"
    
    var deleteButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttribute()
        // Initialization code
        print("SearchResultTableViewCell")
        imageViewClickGesture()
    }

    private func setupAttribute(){
        profileImg.layer.cornerRadius = 52/2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func imageViewClickGesture(){
        // UITapGestureRecognizer 생성
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))

        // 이미지뷰에 UITapGestureRecognizer 추가
        deleteBtn.addGestureRecognizer(tapGesture)

        // 사용자 상호 작용을 가능하게 하려면 반드시 다음을 설정해야 합니다.
        deleteBtn.isUserInteractionEnabled = true
    }

    @objc func imageViewTapped() {
           deleteButtonAction?()
    }
    
    // 이미지 설정 함수
    func configure(with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            profileImg.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                    self.profileImg.contentMode = .scaleAspectFill
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
    }
}
