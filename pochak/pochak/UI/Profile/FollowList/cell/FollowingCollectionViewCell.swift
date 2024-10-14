//
//  FollowingCollectionViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

final class FollowingCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "FollowingCollectionViewCell" // Collection View가 생성할 cell임을 명시
    
    var cellHandle: String = ""
    
    // MARK: - Views
    
    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var followStateToggleBtn: UIButton!
    
    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCell()
    }
    
    // MARK: - Actions
    
    @objc func toggleFollowBtn(_ sender: UIButton) {
        UserService.postFollowRequest(handle: cellHandle) { data, failed in
            guard let data = data else {
                print("error")
                return
            }
            print(data.message)
            if data.message == "성공적으로 팔로우를 취소하였습니다." {
                sender.setTitle("팔로우", for: .normal)
                sender.backgroundColor = UIColor(named: "yellow00")
            } else if data.message == "성공적으로 팔로우하였습니다."{
                sender.setTitle("팔로잉", for: .normal)
                sender.backgroundColor = UIColor(named: "gray03")
            }
        }
    }
    
    // MARK: - Functions
    
    private func setUpCell() {
        profileImageBtn.imageView?.contentMode = .scaleAspectFill
        profileImageBtn.clipsToBounds = true
        profileImageBtn.layer.cornerRadius = 26
        
        followStateToggleBtn.isHidden = false
    }
    
    func setUpCellData(_ memberDataModel : MemberListData) {
        var imageURL = memberDataModel.profileImage
        if let url = URL(string: imageURL) {
            profileImageBtn.kf.setImage(with: url, for: .normal)
        }
        userId.text = memberDataModel.handle
        userName.text = memberDataModel.name
        cellHandle = memberDataModel.handle
        
        // 버튼 설정
        if let isFollow = memberDataModel.isFollow {
            /// followStateToggleBtn이 view에 나타나도록 설정
            followStateToggleBtn.isHidden = false
            
            /// followStateToggleBtn  레이아웃 설정
            followStateToggleBtn.setTitleColor(UIColor.white, for: .normal)
            followStateToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
            followStateToggleBtn.layer.cornerRadius = 5
            followStateToggleBtn.addTarget(self, action: #selector(toggleFollowBtn), for: .touchUpInside)
            
            /// 1. cell 유저를 팔로우 중인 경우
            if isFollow {
                /// 팔로잉 버튼 나타나도록 설정
                followStateToggleBtn.setTitle("팔로잉", for: .normal)
                followStateToggleBtn.backgroundColor = UIColor(named: "gray03")
            }
            /// 2. cell 유저를 팔로우하고 있지 않은 경우
            else if !isFollow {
                /// 팔로우 버튼 나타나도록 설정
                followStateToggleBtn.setTitle("팔로우", for: .normal)
                followStateToggleBtn.backgroundColor = UIColor(named: "yellow00")
            }
        }
        /// 3. cell 유저가 자기 자신인 경우(isFollow == nil)
        else {
            /// 아무 버튼도 나타나지 않도록 설정
            followStateToggleBtn.isHidden = true
        }
    }
}
