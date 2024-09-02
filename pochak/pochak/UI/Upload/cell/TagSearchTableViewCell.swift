//
//  TagSearchTableViewCell.swift
//  pochak
//
//  Created by 장나리 on 6/29/24.
//

import UIKit

class TagSearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TagSearchTableViewCell"
    
    // MARK: - Views

    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    // MARK: - lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttribute()
        configureCellAppearance()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureCellAppearance()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 재사용 시 초기화
        self.contentView.layer.maskedCorners = []
    }
    
    // MARK: - Functions

    private func setupAttribute() {
        profileImg.layer.cornerRadius = 40/2
        profileImg.contentMode = .scaleAspectFill
    }
    
    /// 전체 셀에 둥근 모서리 적용
    private func configureCellAppearance() {
        self.contentView.layer.backgroundColor = UIColor(named: "gray02")?.cgColor
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
        
        if let tableView = self.superview as? UITableView {
            let indexPath = tableView.indexPath(for: self)!
            let row = indexPath.row
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)

            switch row {
            case 0 where numberOfRows == 1:
                // 아이템이 하나인 경우
                self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
                
            case 0:
                // 첫 번째 셀
                self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                
            case numberOfRows - 1:
                // 마지막 셀
                self.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0)
                
            default:
                // 그 외의 경우
                self.contentView.layer.maskedCorners = []
                self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
    }
}
