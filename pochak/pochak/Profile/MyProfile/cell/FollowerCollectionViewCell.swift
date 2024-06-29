//
//  TabbarHeadingCollectionViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class FollowerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var localHandle: String = ""
    var parentVC: UIViewController!

    weak var delegate: RemoveImageDelegate?
        
    
    // Collection View가 생성할 cell임을 명시
    static let identifier = "FollowerCollectionViewCell"
    
    func configure(_ memberDataModel : MemberListDataModel){
        let imageURL = memberDataModel.profileImage ?? ""
        if let url = URL(string: imageURL) {
            profileImageBtn.kf.setImage(with: url, for: .normal, completionHandler:  { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            })
        }
        userId.text = memberDataModel.handle
        userName.text = memberDataModel.name
        localHandle = memberDataModel.handle ?? ""
    }
    
    @IBAction func deleteFollowerBtn(_ sender: Any) {
        let handle = localHandle
        print("inside deleteFollowerBtn!!!!!")
        // index
        guard let superView = self.superview as? UICollectionView else {
            print("superview is not a UICollectionView - getIndexPath")
            return
        }
        guard let indexPath = superView.indexPath(for: self) else {return}
        print(indexPath.row)
        delegate?.removeFromCollectionView(at: indexPath, handle)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // 프로필 레이아웃
        // 사진 안 넣어짐 -> 버튼 type을 custom으로 변경 + style default로 변경
        profileImageBtn.contentMode = .scaleAspectFill
        profileImageBtn.clipsToBounds = true // cornerRadius 적용 안됨 해결
        profileImageBtn.layer.cornerRadius = 26
        
        // 버튼 레이아웃
        deleteBtn.setTitle("삭제", for: .normal)
        deleteBtn.backgroundColor = UIColor(named: "gray03")
        deleteBtn.setTitleColor(UIColor.white, for: .normal)
        deleteBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
        deleteBtn.layer.cornerRadius = 5
        
    }

}
