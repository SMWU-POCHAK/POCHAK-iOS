//
//  PochakAlarmCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 5/14/24.
//

import UIKit

class PochakAlarmTableViewCell: UITableViewCell {
    
    // MARK: - Properties

    static let identifier = "PochakAlarmTableViewCell"
    var previewBtnClickAction: (() -> Void)?

    // MARK: - Views

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    @IBAction func previewBtnAction(_ sender: Any) {
        print("버튼 클릭")
        previewBtnClickAction?()
    }
    
    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAttribute()
        configureCellAppearance()
    }
    
    // MARK: - Functions

    private func setupAttribute() {
        img.layer.cornerRadius = 48/2
//        comment.lineBreakMode = .byCharWrapping
//        comment.lineBreakStrategy = .hangulWordPriority
        previewBtn.layer.masksToBounds = true
    }
    
    private func configureCellAppearance() {
        // 첫 번째 셀과 마지막 셀의 외형을 설정
        if let tableView = self.superview as? UITableView {
            let indexPath = tableView.indexPath(for: self)!
            let row = indexPath.row
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            
            switch row {
            case 0 where numberOfRows == 1:
                // 아이템이 하나인 경우
                self.lineView.isHidden = true // separator를 보이지 않도록
                
            case 0:
                // 첫 번째 셀
                self.lineView.isHidden = false
                print("첫번째")
                
            case numberOfRows - 1:
                // 마지막 셀
                self.lineView.isHidden = true // separator를 보이지 않도록
                print("마지막")
                
            default:
                // 그 외의 경우
                self.lineView.isHidden = false
            }
        }
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
