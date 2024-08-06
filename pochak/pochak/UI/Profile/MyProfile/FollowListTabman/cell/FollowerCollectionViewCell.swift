//
//  TabbarHeadingCollectionViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class FollowerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Data
    
    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    
    var localHandle: String = ""
    var searchedHandle: String = ""
    var parentVC: UIViewController!
    weak var delegate: RemoveImageDelegate?
    static let identifier = "FollowerCollectionViewCell" // Collection View가 생성할 cell임을 명시
    var loginUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)

    // MARK: - Cell LifeCylce
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // 프로필 레이아웃
        profileImageBtn.imageView?.contentMode = .scaleAspectFill // 사진 안 넣어지는 문제 -> 버튼 type을 custom으로 변경 + style default로 변경
        profileImageBtn.clipsToBounds = true // cornerRadius 적용 안되는 경우 추가
        profileImageBtn.layer.cornerRadius = 26
        
        deleteBtn.isHidden = false
        followBtn.isHidden = false
    }
    
    // MARK: - Method
    
    func configure(_ memberDataModel : MemberListDataModel){
        let imageURL = memberDataModel.profileImage
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
        localHandle = memberDataModel.handle
        
        // 삭제 버튼 설정
        print("searchedHandle : \(searchedHandle)")
        print("loginUserHandle : \(loginUserHandle)")
        
        // 내 프로필 팔로워 리스트 조회한 경우
        if searchedHandle == loginUserHandle {
            followBtn.isHidden = true
            deleteBtn.isHidden = false
            deleteBtn.setTitle("삭제", for: .normal)
            deleteBtn.backgroundColor = UIColor(named: "gray03")
            deleteBtn.setTitleColor(UIColor.white, for: .normal)
            deleteBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
            deleteBtn.layer.cornerRadius = 5
            deleteBtn.addTarget(self, action: #selector(deleteFollowerBtn), for: .touchUpInside)
        }
        // 남의 프로필 파로워 리스트 조회한 경우
        else {
            // 팔로우 유무 설정
            if let isFollow = memberDataModel.isFollow {
                deleteBtn.isHidden = true
                followBtn.isHidden = false
                if isFollow {
                    // 버튼 레이아웃
                    followBtn.setTitle("팔로잉", for: .normal)
                    followBtn.backgroundColor = UIColor(named: "gray03")
                    followBtn.setTitleColor(UIColor.white, for: .normal)
                    followBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
                    followBtn.layer.cornerRadius = 5
                    followBtn.addTarget(self, action: #selector(toggleFollowBtn), for: .touchUpInside)
                } else if !isFollow {
                    // 버튼 레이아웃
                    followBtn.setTitle("팔로우", for: .normal)
                    followBtn.backgroundColor = UIColor(named: "yellow00")
                    followBtn.setTitleColor(UIColor.white, for: .normal)
                    followBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
                    followBtn.layer.cornerRadius = 5
                    followBtn.addTarget(self, action: #selector(toggleFollowBtn), for: .touchUpInside)
                }
            } else {
                // nil(자기자신인 경우)
                deleteBtn.isHidden = true
                followBtn.isHidden = true
            }
            
        }
    }
    
    @objc func deleteFollowerBtn(_ sender: Any) {
        print("========= deleteFollowerBtn Pressed!========")
        let handle = localHandle
        guard let superView = self.superview as? UICollectionView else {
            print("superview is not a UICollectionView - getIndexPath")
            return
        }
        guard let indexPath = superView.indexPath(for: self) else {return}
        delegate?.removeFromCollectionView(at: indexPath, handle)
    }
    
    @objc func toggleFollowBtn(_ sender: UIButton) {
        print("========= toggleFollowBtn Pressed!========")
        let handle = localHandle
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
