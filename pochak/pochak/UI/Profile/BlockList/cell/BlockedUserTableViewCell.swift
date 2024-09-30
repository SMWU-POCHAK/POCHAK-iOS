//
//  BlockedUserTableViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 7/5/24.
//

import UIKit

class BlockedUserTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "BlockedUserTableViewCell" // Table View가 생성할 cell임을 명시
    
    var cellHandle: String?
    weak var delegate: RemoveCellDelegate?
    
    // MARK: - Views
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Actions
    
    @IBAction func unblockBtnSelected(_ sender: Any) {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UICollectionView - getIndexPath")
            return
        }
        guard let indexPath = superView.indexPath(for: self) else {return}
        delegate?.removeCell(at: indexPath, cellHandle ?? "")
    }
    
    // MARK: - Functions
    
    func setUpCell() {
        profileImg.contentMode = .scaleAspectFill
        profileImg.clipsToBounds = true
        profileImg.layer.cornerRadius = 26
        
        unblockButton.setTitle("차단해제", for: .normal)
        unblockButton.backgroundColor = UIColor(named: "gray03")
        unblockButton.setTitleColor(UIColor.white, for: .normal)
        unblockButton.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
        unblockButton.layer.cornerRadius = 5
    }
    
    func setUpCellData(_ blockedUserList :  BlockList) {
        // load 프로필 이미지
        var imageURL = blockedUserList.profileImage
        if let url = URL(string: (imageURL)) {
            profileImg.load(with: url)
        }
        userHandle.text = blockedUserList.handle
        userName.text = blockedUserList.name
        cellHandle = blockedUserList.handle
    }
}
