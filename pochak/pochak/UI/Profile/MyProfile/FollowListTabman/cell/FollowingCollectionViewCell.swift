//
//  FollowingCollectionViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class FollowingCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Data
    
    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followStateToggleBtn: UIButton!
    
    static let identifier = "FollowingCollectionViewCell" // Collection View가 생성할 cell임을 명시
    var handle:String = ""
    
    // MARK: - Cell LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 프로필 레이아웃
        profileImageBtn.imageView?.contentMode = .scaleAspectFill // 사진 안 넣어지는 문제 -> 버튼 type을 custom으로 변경 + style default로 변경
        profileImageBtn.clipsToBounds = true // cornerRadius 적용 안되는 경우 추가
        profileImageBtn.layer.cornerRadius = 26
        
        followStateToggleBtn.isHidden = false
    }
    
    // MARK: - Method
    
    func configure(_ memberDataModel : MemberListDataModel){
        // 프로필 이미지 설정
        var imageURL = memberDataModel.profileImage
        if let url = URL(string: imageURL) {
            profileImageBtn.kf.setImage(with: url, for: .normal)
        }
        
        // 프로필 정보 설정
        userId.text = memberDataModel.handle
        userName.text = memberDataModel.name
        handle = memberDataModel.handle
        
        
        // 팔로우 유무 설정
        if let isFollow = memberDataModel.isFollow {
            followStateToggleBtn.isHidden = false
            if isFollow {
                // 버튼 레이아웃
                followStateToggleBtn.setTitle("팔로잉", for: .normal)
                followStateToggleBtn.backgroundColor = UIColor(named: "gray03")
                followStateToggleBtn.setTitleColor(UIColor.white, for: .normal)
                followStateToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
                followStateToggleBtn.layer.cornerRadius = 5
                followStateToggleBtn.addTarget(self, action: #selector(toggleFollowBtn), for: .touchUpInside)
            } else if !isFollow {
                // 버튼 레이아웃
                followStateToggleBtn.setTitle("팔로우", for: .normal)
                followStateToggleBtn.backgroundColor = UIColor(named: "yellow00")
                followStateToggleBtn.setTitleColor(UIColor.white, for: .normal)
                followStateToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
                followStateToggleBtn.layer.cornerRadius = 5
                followStateToggleBtn.addTarget(self, action: #selector(toggleFollowBtn), for: .touchUpInside)
            }
        } else {
            followStateToggleBtn.isHidden = true
        }
    }

    @objc func toggleFollowBtn(_ sender: UIButton) {
        let handle = handle
        FollowToggleDataManager.shared.followToggleDataManager(handle, { resultData in
            print(resultData.message)
            if resultData.message == "성공적으로 팔로우를 취소하였습니다." {
                sender.setTitle("팔로우", for: .normal)
                sender.backgroundColor = UIColor(named: "yellow00")
            } else if resultData.message == "성공적으로 팔로우하였습니다."{
                sender.setTitle("팔로잉", for: .normal)
                sender.backgroundColor = UIColor(named: "gray03")
            }
        })
    }
}
