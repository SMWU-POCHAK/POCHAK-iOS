//
//  PostCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/07/12.
//

import UIKit
import Kingfisher

final class PostCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "PostCollectionViewCell"
    
    // MARK: - Views

    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
