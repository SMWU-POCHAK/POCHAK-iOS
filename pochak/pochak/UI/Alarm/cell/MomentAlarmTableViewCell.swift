//
//  MomentAlarmTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/12/25.
//

import UIKit

class MomentAlarmTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "MomentAlarmTableViewCell"
    var previewBtnClickAction: (() -> Void)?
    
    // MARK: - Views
    
    @IBOutlet weak var userImageView1: UIImageView!
    @IBOutlet weak var userImageView2: UIImageView!
    @IBOutlet weak var alarmContentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupAttribute()
        addPreviewGesture()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @objc private func previewImageViewDidTap(_ sender: Any) {
        print("버튼 클릭")
        previewBtnClickAction?()
    }
    
    // MARK: - Functions
    
    private func setupAttribute() {
        userImageView1.layer.cornerRadius = 44 / 2
        userImageView2.layer.cornerRadius = 44 / 2
        timeLabel.applyPochakFont(.bodyExtraSmall)
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 3
    }
    
    private func addPreviewGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewImageViewDidTap(_:)))
        previewImageView.addGestureRecognizer(tapGesture)
    }
}
