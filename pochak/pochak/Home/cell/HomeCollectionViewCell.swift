//
//  HomeCollectionViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/11.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepare(image: nil)
    }
    
    // MARK: - Helpers
    func prepare(image: UIImage?){
        self.imageView.image = image
    }

    // 각 게시글의 사진을 미리 보기 해야 하기 위한 메소드
    //public func setupData(_ imageURLStr: String?){
        // 이미지뷰의 이미지 업로드

//        guard let imageURLStr = imageURLStr else {
//            return
//        }
//
//        if let url = URL(string: imageURLStr) {
//            postImageView.kf.setImage(
//                with: url,
//                placeholder: UIImage(systemName: "photo"))
//        }
//    }
}
