//
//  AlarmCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/07/08.
//

import UIKit
import Kingfisher

class AlarmCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlarmCollectionViewCell"
    
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var img: UIImageView!
    

    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var refuseBtn: UIButton!
    
    var acceptButtonAction: (() -> Void)?
    var refuseButtonAction: (() -> Void)?

    
    @IBAction func acceptBtnTapped(_ sender: Any) {
        acceptButtonAction?()
    }
    @IBAction func refuseBtnTapped(_ sender: Any) {
        refuseButtonAction?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupAttribute()

    }

    private func setupAttribute(){
        img.layer.cornerRadius = 50/2
    }
    func setupData(){
        
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
