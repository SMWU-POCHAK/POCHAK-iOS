//
//  TabbarHeadingCollectionViewCell.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class FollowerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "FollowerCollectionViewCell" // Collection View가 생성할 cell임을 명시
    
    var cellHandle: String = "" // 현재 cell의 handle
    var searchedHandle: String = "" // 검색한 프로필의 handle
    var loginUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle) // 로그인된 유저의 handle
    var parentVC: UIViewController?
    weak var delegate: RemoveImageDelegate?
    
    
    // MARK: - Views
    
    @IBOutlet weak var profileImageBtn: UIButton!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var followBtn: UIButton!
    
    
    // MARK: - LifeCylce
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpCell()
    }
    
    // MARK: - Actions
    
    @objc func deleteFollowerBtn(_ sender: Any) {
        guard let superView = self.superview as? UICollectionView else {
            print("superview is not a UICollectionView - getIndexPath")
            return
        }
        guard let indexPath = superView.indexPath(for: self) else { return }
        delegate?.removeFromCollectionView(at: indexPath, cellHandle)
    }
    
    @objc func toggleFollowBtn(_ sender: UIButton) {
        UserService.postFollowRequest(handle: cellHandle) { data, failed  in
            guard let data = data else {
                print("error")
                return
            }
            
            var resultCode = data.code
            print(data.message)
            if resultCode == "FOLLOW2002" {
                sender.setTitle("팔로우", for: .normal)
                sender.backgroundColor = UIColor(named: "yellow00")
            } else if resultCode == "FOLLOW2001" {
                sender.setTitle("팔로잉", for: .normal)
                sender.backgroundColor = UIColor(named: "gray03")
            }
            
        }
//        FollowToggleDataManager.shared.followToggleDataManager(cellHandle, { resultData in
//            var resultCode = resultData.code
//            print(resultData.message)
//            if resultCode == "FOLLOW2002" {
//                sender.setTitle("팔로우", for: .normal)
//                sender.backgroundColor = UIColor(named: "yellow00")
//            } else if resultCode == "FOLLOW2001" {
//                sender.setTitle("팔로잉", for: .normal)
//                sender.backgroundColor = UIColor(named: "gray03")
//            }
//        })
    }
    
    // MARK: - Functions
    
    private func setUpCell() {
        profileImageBtn.imageView?.contentMode = .scaleAspectFill
        profileImageBtn.clipsToBounds = true
        profileImageBtn.layer.cornerRadius = 26
        
        deleteBtn.isHidden = false
        followBtn.isHidden = false
    }
    
    func setUpCellData(_ memberDataModel : MemberListData) {
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
        cellHandle = memberDataModel.handle
        
        // 버튼 설정
        /// 내 프로필 팔로워 리스트 조회한 경우 : 삭제 버튼
        if searchedHandle == loginUserHandle {
            /// deleteBtn만 view에 나타나도록 설정
            followBtn.isHidden = true
            deleteBtn.isHidden = false
            
            /// deleteBtn  레이아웃 설정
            deleteBtn.setTitle("삭제", for: .normal)
            deleteBtn.backgroundColor = UIColor(named: "gray03")
            deleteBtn.setTitleColor(UIColor.white, for: .normal)
            deleteBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14)
            deleteBtn.layer.cornerRadius = 5
            deleteBtn.addTarget(self, action: #selector(deleteFollowerBtn), for: .touchUpInside)
        }
        /// 남의 프로필 팔로워 리스트 조회한 경우 : 팔로우/팔로잉 버튼
        else {
            if let isFollow = memberDataModel.isFollow {
                /// followBtn만 view에 나타나도록 설정
                deleteBtn.isHidden = true
                followBtn.isHidden = false
                
                /// followBtn 기본 레이아웃 설정
                followBtn.setTitleColor(UIColor.white, for: .normal)
                followBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14)
                followBtn.layer.cornerRadius = 5
                followBtn.addTarget(self, action: #selector(toggleFollowBtn), for: .touchUpInside)
                
                /// 1. cell 유저를 팔로우 중인 경우
                if isFollow {
                    /// 팔로잉 버튼 나타나도록 설정
                    followBtn.setTitle("팔로잉", for: .normal)
                    followBtn.backgroundColor = UIColor(named: "gray03")
                }
                /// 2. cell 유저를 팔로우하고 있지 않은 경우
                else if !isFollow {
                    /// 팔로우 버튼 나타나도록 설정
                    followBtn.setTitle("팔로우", for: .normal)
                    followBtn.backgroundColor = UIColor(named: "yellow00")
                }
            }
            /// 3. cell 유저가 자기 자신인 경우(isFollow == nil)
            else {
                /// 아무 버튼도 나타나지 않도록 설정
                deleteBtn.isHidden = true
                followBtn.isHidden = true
            }
        }
    }
}
