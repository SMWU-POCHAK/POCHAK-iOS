//
//  OtherCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/07/12.
//

import UIKit

class OtherCollectionViewCell: UICollectionViewCell {
    static let identifier = "OtherCollectionViewCell"

    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupAttribute()
        setupComment()
    }

    private func setupAttribute(){
        img.layer.cornerRadius = 50/2
    }
    func setupComment(){
//        // Label의 설정
//        comment.numberOfLines = 0
//        comment.lineBreakMode = .byWordWrapping
//        
//        comment.sizeToFit()
//        
//        // 텍스트가 label에 맞게 자동으로 조절되도록 설정
//        let newSize = comment.sizeThatFits(CGSize(width: comment.frame.width, height: CGFloat.greatestFiniteMagnitude))
//        comment.frame.size = CGSize(width: comment.frame.width, height: newSize.height)

    }
    func configure(with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            img.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                    self.img.contentMode = .scaleAspectFill
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
    }

}
