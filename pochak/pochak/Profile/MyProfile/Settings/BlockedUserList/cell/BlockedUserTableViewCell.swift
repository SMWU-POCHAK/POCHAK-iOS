//
//  BlockedUserTableViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 7/5/24.
//

import UIKit

class BlockedUserTableViewCell: UITableViewCell {
    
    static let identifier = "BlockedUserTableViewCell"

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var unblockButton: UIButton!
    
    var cellHandle: String?
    weak var delegate: RemoveCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 프로필 레이아웃
        profileImg.contentMode = .scaleAspectFill // 사진 안 넣어지는 문제 -> 버튼 type을 custom으로 변경 + style default로 변경
        profileImg.clipsToBounds = true // cornerRadius 적용 안되는 경우 추가
        profileImg.layer.cornerRadius = 26
        
        // 버튼 레이아웃
        unblockButton.setTitle("차단해제", for: .normal)
        unblockButton.backgroundColor = UIColor(named: "gray03")
        unblockButton.setTitleColor(UIColor.white, for: .normal)
        unblockButton.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
        unblockButton.layer.cornerRadius = 5
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Function
    
    func setData(_ blockedUserList :  BlockedUserListDataModel){
        let imageURL = blockedUserList.profileImage ?? ""
        if let url = URL(string: imageURL) {
            profileImg.kf.setImage(with: url, completionHandler:  { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            })
        }
        userHandle.text = blockedUserList.handle
        userName.text = blockedUserList.name
        cellHandle = blockedUserList.handle ?? ""
    }
    
    @IBAction func unblockBtnSelected(_ sender: Any) {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UICollectionView - getIndexPath")
            return
        }
        guard let indexPath = superView.indexPath(for: self) else {return}
        delegate?.removeCell(at: indexPath, cellHandle ?? "")
        print(delegate)
        print("unblockBtnSelected!!")
    }
}
