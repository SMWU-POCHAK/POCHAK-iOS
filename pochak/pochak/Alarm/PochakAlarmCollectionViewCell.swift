//
//  PochakAlarmCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 5/14/24.
//

import UIKit

class PochakAlarmCollectionViewCell: UICollectionViewCell {

    static let identifier = "PochakAlarmCollectionViewCell"

    
    @IBOutlet weak var previewBtn: UIButton!
    
    var previewBtnAction: (() -> Void)?
    
    @IBAction func previewBtnTapped(_ sender: Any) {
        previewBtnAction?()
    }
    
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAttribute()
    }
    
    private func setupAttribute(){
        img.layer.cornerRadius = 50/2
        
        previewBtn.layer.masksToBounds = true
        previewBtn.layer.cornerRadius = 5
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
