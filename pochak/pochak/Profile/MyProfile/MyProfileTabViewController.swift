//
//  ProfileTabViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class MyProfileTabViewController: UIViewController {

    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerList: UIStackView!
    @IBOutlet weak var followingList: UIStackView!
    @IBOutlet weak var whiteBackground1: UIView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var postListTabmanView: UIView!
    @IBOutlet weak var updateProfileBtn: UIButton!
    @IBOutlet weak var topUIView: UIView!
    @IBOutlet weak var settingBtn: UIButton!
    
    // 필요한 데이터 불러온 후 변수에 저장
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    // let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
    let handle = APIConstants.dayeonHandle // 임시 핸들
    
    override func viewDidLoad() {
        super.viewDidLoad()


        // 프로픨 디자인
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        
        // 흰색 배경 디자인
        whiteBackground1.layer.cornerRadius = 8
    
        // 팔로워 / 팔로잉 레이블 선택
        viewFollowerList()
        viewFollowingList()
    
        // Back 버튼 커스텀
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // 포스트 탭맨 뷰 constraint 설정
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.whiteBackground1.bottomAnchor, constant: 5).isActive = true
        postListTabmanView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        postListTabmanView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        postListTabmanView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true

        // API
        loadProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        // API
        loadProfileData()
        
        // 뷰가 나타날 때에는 네비게이션 바 숨기기
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 뷰가 사라질 때에는 네비게이션 바 다시 보여주기
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func loadProfileData() {
        // let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
        self.userHandle.text = "@\(handle)"

        print("------------------- loadProfileData() 안에 handle 있는지 검사 -------------------")
        print(handle)
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(handle,{ [self]resultData in
      
            // 프로필 이미지
            let imageURL = resultData.profileImage ?? ""
            UserDefaultsManager.setData(value: imageURL, key: .profileImgUrl)
            if let url = URL(string: imageURL) {
                self.profileImage.kf.setImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        print("Image successfully loaded: \(value.image)")
                    case .failure(let error):
                        print("Image failed to load with error: \(error.localizedDescription)")
                    }
                }
            }

            // 1. 데이터 뷰에 반영
            self.profileImage.contentMode = .scaleAspectFill /* 원 면적에 사진 크기 맞춤 */
            self.userName.text = String(resultData.name ?? "")
            self.userMessage.text = String(resultData.message ?? "")
            self.postCount.text = String(resultData.totalPostNum ?? 0)
            self.followerCount.text = String(resultData.followerCount ?? 0)
            self.followingCount.text = String(resultData.followingCount ?? 0)
            
            // 2. UserDefaultsManager에 데이터 저장 후 관리
            UserDefaultsManager.setData(value: resultData.name, key: .name)
            UserDefaultsManager.setData(value: resultData.message, key: .message)
            UserDefaultsManager.setData(value: resultData.followerCount, key: .followerCount)
            UserDefaultsManager.setData(value: resultData.followingCount, key: .followingCount)
        })
    }
    
    @IBAction func clickSettingBtn(_ sender: Any) {
        guard let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsViewController else {return}
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func updateProfile(_ sender: Any) {

        guard let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else {return}
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    private func viewFollowerList() { /*  UITapGestureRecognizer 사용 */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowerTapped))
        followerList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func viewFollowingList() { /*  UITapGestureRecognizer 사용 */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowingTapped))
        followingList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func viewFollowerTapped(){
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 0
        followListVC.handle = handle
        followListVC.followerCount = UserDefaultsManager.getData(type: Int.self, forKey: .followerCount) ?? 0
        followListVC.followingCount = UserDefaultsManager.getData(type: Int.self, forKey: .followingCount) ?? 0
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
        
    @objc private func viewFollowingTapped(){
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 1
        followListVC.handle = handle
        followListVC.followerCount = UserDefaultsManager.getData(type: Int.self, forKey: .followerCount) ?? 0
        followListVC.followingCount = UserDefaultsManager.getData(type: Int.self, forKey: .followingCount) ?? 0
        self.navigationController?.pushViewController(followListVC, animated: true)
    }

}
