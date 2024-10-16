//
//  PostCollectionViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit
import Kingfisher

class ProfilePostCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "ProfilePostCollectionViewCell" // Collection View가 생성할 cell임을 명시

    // MARK: - Views
    
    @IBOutlet weak var profilePostImage: UIImageView!
    
    // MARK: - LifeCycle

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Functions
    
    func setUpCellData(_ postDataModel : PostDataModel) {
        var imageURL = postDataModel.postImage
        if let url = URL(string: (imageURL)) {
            profilePostImage.load(with: url)
        }
//        if let url = URL(string: imageURL) {
//            
//            profilePostImage.kf.setImage(with: url) { result in
//                switch result {
//                case .success(let value):
//                    print("Image successfully loaded: \(value.image)")
//                case .failure(let error):
//                    print("Image failed to load with error: \(error.localizedDescription)")
//                }
//            }
//        }
    }
}
