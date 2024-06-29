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
        
        // 현재 프로필 페이지의 네비게이션 바 설정
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.topItem?.title = "@" + (recievedHandle ?? "handle not found")
        
        // 다음 나올 VC의 Back 버튼 커스텀
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // 더보기 버튼
        let barButton = UIBarButtonItem(image: UIImage(named: "moreButtonIcon"), style: .plain, target: self, action: #selector(moreButtonPressed))
        self.navigationItem.rightBarButtonItem = barButton
        
        // 프로픨 디자인
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        profileImage.contentMode = .scaleAspectFill
        
        // 둥근 모서리 적용
        whiteBackground.layer.cornerRadius = 8
        followToggleBtn.layer.cornerRadius = 8
        
        // 팔로워 / 팔로잉 레이블 선택
        viewFollowerList()
        viewFollowingList()
        
        // 포스트 탭맨 뷰
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.followToggleBtn.bottomAnchor, constant: 5).isActive = true
        postListTabmanView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        postListTabmanView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        postListTabmanView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        // API
        loadProfileData()
        
//        // 버튼 레이아웃
//        followToggleBtn.setTitle("팔로잉", for: .normal)
//        followToggleBtn.backgroundColor = UIColor(named: "gray03")
//        followToggleBtn.setTitleColor(UIColor.white, for: .normal)
//        followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16) // 폰트 설정
//        followToggleBtn.layer.cornerRadius = 5
    
        
//        // userHandle
//        self.userHandle.text = "@\(String(describing: recievedHandle))"
//        self.userHandle.font = UIFont(name: "Pretendard-Bold", size: 20)
//        self.userHandle.textColor = UIColor.black
//        self.userHandle.translatesAutoresizingMaskIntoConstraints = false
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        // API
        loadProfileData()
        
//        // 네비게이션 바 설정
//        self.navigationItem.title = recievedHandle ?? "handle not found"
//        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//        self.navigationController?.navigationBar.tintColor = .white
//        self.navigationController?.navigationBar.topItem?.title = ""
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
                self.followToggleBtn.setTitleColor(UIColor.white, for: .normal)
                self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16) // 폰트 설정
                self.followToggleBtn.layer.cornerRadius = 5
            } else {
                self.followToggleBtn.setTitle("팔로우", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "yellow00")
                self.followToggleBtn.setTitleColor(UIColor.white, for: .normal)
                self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16) // 폰트 설정
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
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Bold", size: 18), NSAttributedString.Key.foregroundColor: UIColor.black]
            let titleString = NSAttributedString(string: "팔로우를 취소할까요?", attributes: titleAttributes as [NSAttributedString.Key : Any])
            
            let messageAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-Regular", size: 14), NSAttributedString.Key.foregroundColor: UIColor.black]
            let messageString = NSAttributedString(string: "팔로우를 취소하면, 피드에 업로드된 관련 사진이 사라집니다.", attributes: messageAttributes as [NSAttributedString.Key : Any])
            
            alert.setValue(titleString, forKey: "attributedTitle")
            alert.setValue(messageString, forKey: "attributedMessage")
            
            
            let cancelAction = UIAlertAction(title: "나가기", style: .default, handler: nil)
            cancelAction.setValue(UIColor(named: "gray05"), forKey: "titleTextColor")
            
            let okAction = UIAlertAction(title: "계속하기", style: .destructive, handler: {
                action in
                sender.setTitle("팔로우", for: .normal)
                sender.backgroundColor = UIColor(named: "yellow00")
            })
            okAction.setValue(UIColor(named: "yellow00"), forKey: "titleTextColor")

            alert.addAction(cancelAction)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil) // present는 VC에서만 동작
        } else {
            sender.setTitle("팔로잉", for: .normal)
            sender.backgroundColor = UIColor(named: "gray03")
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
    
    @objc func moreButtonPressed(){
        guard let profileMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "profileMenuVC") as? ProfileMenuViewController else {return}
        let sheet = profileMenuVC.sheetPresentationController
        
        let multiplier = 0.25
        let fraction = UISheetPresentationController.Detent.custom { context in
            self.view.bounds.height * multiplier
        }
        sheet?.detents = [fraction]
        sheet?.prefersGrabberVisible = true
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false

        present(profileMenuVC, animated: true)
    }

}
