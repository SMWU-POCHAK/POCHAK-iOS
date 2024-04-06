//
//  ProfileTabViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import Tabman
import Pageboy
import UIKit
import Kingfisher

class MyProfileTabViewController: TabmanViewController {

    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerList: UIStackView!
    @IBOutlet weak var followingList: UIStackView!
    @IBOutlet weak var whiteBackground1: UIView!
    @IBOutlet weak var whiteBackground2: UIView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var postListTabmanView: UIView!
    
    
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    override func viewDidLoad() {
        super.viewDidLoad()

        // 프로픨 디자인
        profileBackground.layer.cornerRadius = 50
        profileImage.layer.cornerRadius = 46
        
        // 흰색 배경 디자인
        whiteBackground1.layer.cornerRadius = 8
        whiteBackground2.layer.cornerRadius = 8
    
        // 팔로워 / 팔로잉 레이블 선택
        viewFollowerList()
        viewFollowingList()
    
        // Back 버튼 커스텀
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // settingButton
        let settingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        settingButton.setImage(UIImage(named: "settingIcon"), for: .normal)
        settingButton.addTarget(self, action: #selector(clickSettingButton), for: .touchUpInside)
//        // constraint 설정
//        settingButton.translatesAutoresizingMaskIntoConstraints = false
//        settingButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
////        settingButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
//        settingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
//        settingButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true

        
        let barButton = UIBarButtonItem(customView: settingButton)
        //assign button to navigationbar
        self.navigationItem.rightBarButtonItem = barButton
//        
        // shareButton
        self.shareBtn.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
        
        // 포스트 탭맨 뷰
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.whiteBackground2.bottomAnchor, constant: 20).isActive = true
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
    }
    
    
    private func loadProfileData() {
//        let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
        let handle = "dxxynni" // 임시 핸들
//        self.userHandle.text = "@" + handle
        self.userHandle.text = "@dxxynni"
        
//        let message = UserDefaultsManager.getData(type: String.self, forKey: .message) ?? ""
//        self.userMessage.text = message
//        
//        let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? ""
//        self.userName.text = name

        print("handle 있는지 검사-------------------")
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

            self.profileImage.contentMode = .scaleAspectFill // 원 면적에 사진 크기 맞춤
            self.userName.text = String(resultData.name ?? "")
            self.userMessage.text = String(resultData.message ?? "")
            self.shareBtn.setTitle("pochak.site/@" + String(resultData.handle ?? ""), for: .normal)
            // font not changing? 스토리보드에서 버튼 style을 default로 변경
            self.shareBtn.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
            self.postCount.text = String(resultData.totalPostNum ?? 0)
            self.followerCount.text = String(resultData.followerCount ?? 0)
            self.followingCount.text = String(resultData.followingCount ?? 0)
            
            UserDefaultsManager.setData(value: resultData.name, key: .name)
            UserDefaultsManager.setData(value: resultData.message, key: .message)
            
        })
    }
    

    // MARK: - view Follower / Following List
    //  UITapGestureRecognizer 사용
    private func viewFollowerList() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowerTapped))
        followerList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func viewFollowingList() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowingTapped))
        followingList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func viewFollowerTapped(){
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 0
        followListVC.handle = "dxxynni"
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
        
    @objc private func viewFollowingTapped(){
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 1
        followListVC.handle = "dxxynni"
        self.navigationController?.pushViewController(followListVC, animated: true)
    }

    
    @objc private func clickSettingButton(_ sender: UIButton) {
        let accessToken = GetToken().getAccessToken()
        print(accessToken)
        guard let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else {return}
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
}


