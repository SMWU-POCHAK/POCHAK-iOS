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
    
    func setUpCellData(_ postDataModel : ProfilePostList) {
        var imageURL = postDataModel.postImage
        if let url = URL(string: (imageURL)) {
            profilePostImage.load(with: url)
        }
    }
}
