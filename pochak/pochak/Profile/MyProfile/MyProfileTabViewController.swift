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
    
    // MARK: - Data
    
    let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
//    let handle = APIConstants.dayeonHandle // 임시 핸들
    
    // MARK: - View Lifecycle
    
    // Container View에 데이터 전달(ViewDidLoad보다 먼저 실행)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //storyboard에서 설정한 identifier와 동일한 이름
        if segue.identifier == "embedContainer" {
            let postListVC = segue.destination as! PostListViewController
            postListVC.handle = handle
        }
    }
    
    override func viewDidLoad() {
        print(">>>>>>>>>>>>>>>> viewDidLoad handle : \(handle)")
        print(">>>>>>>>>>>>>>>> viewDidLoad - myProfile")

        super.viewDidLoad()
        
        // 네비게이션 바 숨기기
        self.navigationController?.isNavigationBarHidden = true

        // 프로픨 디자인
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        
        // 흰색 배경 디자인
        whiteBackground1.layer.cornerRadius = 8
    
        // 팔로워 / 팔로잉 레이블 선택
        viewFollowerList()
        viewFollowingList()
        
        // 핸들 설정
        userHandle.text = "@\(handle)"
    
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
        print(">>>>>>>>>>>>>>>> view will appear - myProfile")
        
        // 뷰가 나타날 때에는 네비게이션 바 숨기기
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(">>>>>>>>>>>>>>>> viewWillDisappear - myProfile")
        
        // 뷰가 사라질 때에는 네비게이션 바 다시 보여주기
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Method
    
    private func loadProfileData() {
        
        // 1. API 호출
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(handle, 0,{ response in
            switch response {
            case .success(let resultData):
                // 이미지 데이터
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
                
                // 2. 필요한 데이터 뷰에 반영
                self.profileImage.contentMode = .scaleAspectFill /* 원 면적에 사진 크기 맞춤 */
                self.userName.text = String(resultData.name ?? "")
                self.userMessage.text = String(resultData.message ?? "")
                self.postCount.text = String(resultData.totalPostNum ?? 0)
                self.followerCount.text = String(resultData.followerCount ?? 0)
                self.followingCount.text = String(resultData.followingCount ?? 0)
                
                // 3. UserDefaultsManager에 새로운 데이터 저장 후 관리 : followerCount, followingCount
                UserDefaultsManager.setData(value: resultData.name, key: .name)
                UserDefaultsManager.setData(value: resultData.message, key: .message)
                UserDefaultsManager.setData(value: resultData.followerCount, key: .followerCount)
                UserDefaultsManager.setData(value: resultData.followingCount, key: .followingCount)
            case .MEMBER4002:
                print("유효하지 않은 멤버의 handle입니다.")
                self.present(UIAlertController.networkErrorAlert(title: "유효하지 않은 멤버의 handle입니다."), animated: true)
            }
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
