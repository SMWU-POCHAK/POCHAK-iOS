//
//  OtherUseProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import UIKit

class OtherUserProfileViewController: UIViewController {

    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerList: UIStackView!
    @IBOutlet weak var followingList: UIStackView!
    @IBOutlet weak var whiteBackground: UIView!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userMessage: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followToggleBtn: UIButton!
    @IBOutlet weak var postListTabmanView: UIView!
    

    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId) ?? "socialId not found"
    var recievedHandle: String?
    var recievedFollowerCount : Int = 0
    var recievedFollowingCount : Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Back 버튼 커스텀
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // 프로픨 디자인
        profileBackground.layer.cornerRadius = 50
        profileImage.layer.cornerRadius = 46
        
        // 둥근 모서리 적용
        whiteBackground.layer.cornerRadius = 8
        followToggleBtn.layer.cornerRadius = 8
        
        // 팔로워 / 팔로잉 레이블 선택
        viewFollowerList()
        viewFollowingList()
        
        // 포스트 탭맨 뷰
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.followToggleBtn.bottomAnchor, constant: 20).isActive = true
        postListTabmanView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        postListTabmanView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        postListTabmanView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        // API
        loadProfileData()
        
        // 버튼 레이아웃
        followToggleBtn.setTitle("팔로잉", for: .normal)
        followToggleBtn.backgroundColor = UIColor(named: "gray03")
        followToggleBtn.setTitleColor(UIColor(named: "gray07"), for: .normal)
        followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
        followToggleBtn.layer.cornerRadius = 5
        
        // 네비게이션 바 설정
        self.navigationItem.title = recievedHandle ?? "handle not found"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        // , .font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.heavy)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""
        
    }
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        // API
        loadProfileData()
        
        // 네비게이션 바 설정
        self.navigationItem.title = recievedHandle ?? "handle not found"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.topItem?.title = ""
    }
    
    private func loadProfileData() {
//        // LoginUser 정보 가져오기
//        let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? "handle not found"
//        let name = UserDefaultsManager.getData(type: String.self, forKey: .name) ?? "name not found"
//        let message = UserDefaultsManager.getData(type: String.self, forKey: .message) ?? "message not found"
//        
//        self.userHandle.text = "@" + (recievedHandle ?? "handle not found")
//        self.userName.text = name
//        self.userMessage.text = message
//        
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(recievedHandle ?? "",{resultData in
            print("myProfilePochakPostDataManager")
            print(resultData)
            
            // 프로필 이미지
            let imageURL = resultData.profileImage ?? ""
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
            self.userName.text = String(resultData.name ?? "")
            self.userMessage.text = String(resultData.message ?? "")
            self.postCount.text = String(resultData.totalPostNum ?? 0)
            self.followerCount.text = String(resultData.followerCount ?? 0)
            self.followingCount.text = String(resultData.followingCount ?? 0)
            self.recievedFollowerCount = resultData.followerCount ?? 0
            self.recievedFollowingCount = resultData.followingCount ?? 0
                    
            if resultData.isFollow == true {
                // 버튼 레이아웃
                self.followToggleBtn.setTitle("팔로잉", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "gray03")
                self.followToggleBtn.setTitleColor(UIColor(named: "gray07"), for: .normal)
                self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
                self.followToggleBtn.layer.cornerRadius = 5
            } else {
                self.followToggleBtn.setTitle("팔로우", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "yellow00")
                self.followToggleBtn.setTitleColor(UIColor(named: "gray07"), for: .normal)
                self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
                self.followToggleBtn.layer.cornerRadius = 5
            }
        })
    }
    
    // MARK: - follow toggle
    
    @IBAction func followToggleButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        
        FollowToggleDataManager.shared.followToggleDataManager(recievedHandle ?? "", { resultData in
            print(resultData.message)
        })
        
        if sender.isSelected {
            // 알림창
            let alert = UIAlertController(title:"팔로우를 취소할까요?",message: "팔로우를 취소하면, 피드에 업로드된 관련 사진이 사라집니다.",preferredStyle: UIAlertController.Style.alert)
            let cancle = UIAlertAction(title: "나가기", style: .default, handler: nil)
            let ok = UIAlertAction(title: "계속하기", style: .destructive, handler: {
                action in
                sender.setTitle("팔로우", for: .normal)
                sender.backgroundColor = UIColor(named: "yellow00")
                sender.setTitleColor(UIColor(named: "gray07"), for: .normal)
                sender.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
            })
            alert.addAction(cancle)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil) // present는 VC에서만 동작
        } else {
            sender.setTitle("팔로잉", for: .normal)
            sender.backgroundColor = UIColor(named: "gray03")
            sender.setTitleColor(UIColor(named: "gray07"), for: .normal)
            sender.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) // 폰트 설정
        }
        
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
        followListVC.handle = recievedHandle ?? ""
        followListVC.followerCount = recievedFollowerCount
        followListVC.followingCount = recievedFollowingCount
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
        
    @objc private func viewFollowingTapped(){
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 1
        followListVC.handle = recievedHandle ?? ""
        followListVC.followerCount = recievedFollowerCount
        followListVC.followingCount = recievedFollowingCount
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
//    @objc private func clickSettingButton(_ sender: UIButton) {
//        guard let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else {return}
//        self.navigationController?.pushViewController(updateProfileVC, animated: true)
//    }
}
