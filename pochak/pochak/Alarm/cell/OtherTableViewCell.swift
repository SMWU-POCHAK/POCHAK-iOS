//
//  OtherCollectionViewCell.swift
//  pochak
//
//  Created by 장나리 on 2023/07/12.
//

import UIKit

class OtherTableViewCell: UITableViewCell {
    static let identifier = "OtherTableViewCell"

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupAttribute()
        configureCellAppearance()
    }

    private func setupAttribute(){
        img.layer.cornerRadius = 48/2
        comment.lineBreakMode = .byCharWrapping
//        comment.lineBreakStrategy = .hangulWordPriority

        self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
