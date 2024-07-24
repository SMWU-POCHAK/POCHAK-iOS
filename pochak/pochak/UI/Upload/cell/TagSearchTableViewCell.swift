//
//  TagSearchTableViewCell.swift
//  pochak
//
//  Created by 장나리 on 6/29/24.
//

import UIKit

class TagSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    
    static let identifier = "TagSearchTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAttribute()
        configureCellAppearance()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupAttribute(){
        profileImg.layer.cornerRadius = 40/2
    }
    
    // 이미지 설정 함수
    func configure(with imageUrl: String) {
        if let url = URL(string: imageUrl) {
            profileImg.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                    self.profileImg.contentMode = .scaleAspectFill
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func configureCellAppearance() {
        // 전체 셀에 둥근 모서리 적용
        self.contentView.layer.backgroundColor = UIColor(named: "gray02")?.cgColor
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.masksToBounds = true
        
        // 첫 번째 셀과 마지막 셀의 외형을 설정
        if let tableView = self.superview as? UITableView {
            let indexPath = tableView.indexPath(for: self)!
            let isFirstCell = indexPath.row == 0
            let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            
            if isFirstCell && isLastCell {
                // 아이템이 하나인 경우
                self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0) // separator를 보이지 않도록
            } else if isFirstCell {
                // 첫 번째 셀
                self.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            } else if isLastCell {
                // 마지막 셀
                self.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.separatorInset = UIEdgeInsets(top: 0, left: bounds.size.width, bottom: 0, right: 0) // separator를 보이지 않도록
            } else {
                // 그 외의 경우
                self.contentView.layer.maskedCorners = []
                self.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            }
        }
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
}
