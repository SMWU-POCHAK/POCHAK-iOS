//
//  PochakAlarmCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 5/14/24.
//

import UIKit

class PochakAlarmTableViewCell: UITableViewCell {

    static let identifier = "PochakAlarmTableViewCell"

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    var previewBtnAction: (() -> Void)?
    
    @IBAction func previewBtnTapped(_ sender: Any) {
        print("버튼 클릭")
        previewBtnAction?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupAttribute()
        configureCellAppearance()
    }
    
    private func setupAttribute(){
        img.layer.cornerRadius = 48/2
        
        previewBtn.layer.masksToBounds = true
    }
    
    func configureCellAppearance() {
        
        // 첫 번째 셀과 마지막 셀의 외형을 설정
        if let tableView = self.superview as? UITableView {
            let indexPath = tableView.indexPath(for: self)!
            let isFirstCell = indexPath.row == 0
            let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            
            if isFirstCell && isLastCell {
                // 아이템이 하나인 경우
                self.lineView.isHidden = true // separator를 보이지 않도록
            } else if isFirstCell {
                // 첫 번째 셀
                self.lineView.isHidden = false
                print("첫번째")
            } else if isLastCell {
                // 마지막 셀
                self.lineView.isHidden = true // separator를 보이지 않도록
                print("마지막")
            } else {
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
