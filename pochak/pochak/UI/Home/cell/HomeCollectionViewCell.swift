//
//  HomeCollectionViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/11.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "HomeCollectionViewCell"

    // MARK: - Views
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.prepare(image: nil)
    }
    
    // MARK: - Functions
    
    func prepare(image: UIImage?) {
        self.imageView.image = image
    }
}
