//
//  OtherUseProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import UIKit

protocol SecondViewControllerDelegate: AnyObject {
    func dismissSecondViewController()
}

class OtherUserProfileViewController: UIViewController {
    // MARK: - Data
    
    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var followerList: UIStackView!
    @IBOutlet weak var followingList: UIStackView!
    @IBOutlet weak var whiteBackground: UIView!
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
    var receivedIsFollow: Bool?
    
    // MARK: - View Lifecycle
    
    // Container View에 데이터 전달(ViewDidLoad보다 먼저 실행)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let currentHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
        if segue.identifier == "embedContainer" {
            let postListVC = segue.destination as! PostListViewController
            postListVC.handle = recievedHandle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 현재 프로필 페이지의 네비게이션바 커스텀
        navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "@" + (recievedHandle ?? "handle not found")
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font : UIFont(name: "Pretendard-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)]
        
        // 다음부터 나올 VC의 Back 버튼 커스텀
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        // 네베게이션바 오른쪽에 더보기 메뉴 버튼 추가
        let barButton = UIBarButtonItem(image: UIImage(named: "moreButtonIcon"), style: .plain, target: self, action: #selector(moreButtonPressed))
        self.navigationItem.rightBarButtonItem = barButton
        
        // 프로픨 디자인
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        profileImage.contentMode = .scaleAspectFill
        
        // 둥근 모서리 적용
        whiteBackground.layer.cornerRadius = 8
        followToggleBtn.layer.cornerRadius = 8
        
        // 팔로워 혹은 팔로잉 버튼 클릭
        viewFollowerList()
        viewFollowingList()
        
        // Tabman constraint 설정
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.followToggleBtn.bottomAnchor, constant: 5).isActive = true
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
    
    // MARK: - Method
    
    private func loadProfileData() {
        
        // 1. API 호출
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(recievedHandle ?? "",{resultData in
         
            // 이미지 데이터
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
            
            // 2. 필요한 데이터 뷰에 반영
            self.userName.text = String(resultData.name ?? "")
            self.userMessage.text = String(resultData.message ?? "")
            self.postCount.text = String(resultData.totalPostNum ?? 0)
            self.followerCount.text = String(resultData.followerCount ?? 0)
            self.followingCount.text = String(resultData.followingCount ?? 0)
            self.recievedFollowerCount = resultData.followerCount ?? 0
            self.recievedFollowingCount = resultData.followingCount ?? 0
            self.receivedIsFollow = resultData.isFollow
            
            // 팔로우 중인지에 따라 다른 버튼 커스텀
            if resultData.isFollow == true {
                // 팔로우 중인 유저인 경우
                self.followToggleBtn.setTitle("팔로잉", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "gray03")
                self.followToggleBtn.setTitleColor(UIColor.white, for: .normal)
                self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16) // 폰트 설정
                self.followToggleBtn.layer.cornerRadius = 5
            } else {
                // 팔로우하고 있지 않은 유저인 경우
                self.followToggleBtn.setTitle("팔로우", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "yellow00")
                self.followToggleBtn.setTitleColor(UIColor.white, for: .normal)
                self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16) // 폰트 설정
                self.followToggleBtn.layer.cornerRadius = 5
            }
        })
    }
    
    @IBAction func followToggleButton(_ sender: UIButton) {
        if receivedIsFollow! {
            showAlert(alertType: .confirmAndCancel,
                      titleText: "팔로우를 취소할까요?",
                      messageText: "",
                      cancelButtonText: "나가기",
                      confirmButtonText: "계속하기"
            )
        } else {
            FollowToggleDataManager.shared.followToggleDataManager(self.recievedHandle ?? "", { resultData in
                print(resultData.message)
            })
            self.receivedIsFollow = true
            sender.setTitle("팔로잉", for: .normal)
            sender.backgroundColor = UIColor(named: "gray03")
        }
    }
    
    private func viewFollowerList() { //  UITapGestureRecognizer 사용
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowerTapped))
        followerList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func viewFollowingList() { //  UITapGestureRecognizer 사용
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
        profileMenuVC.receivedHandle = recievedHandle
        
        let multiplier = 0.25
        let fraction = UISheetPresentationController.Detent.custom { context in
            self.view.bounds.height * multiplier
        }
        sheet?.detents = [fraction]
        sheet?.prefersGrabberVisible = true
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false
        
        // delegate 채택
        profileMenuVC.delegate = self
        present(profileMenuVC, animated: true)
    }
}

// MARK: - Extension

extension OtherUserProfileViewController: CustomAlertDelegate {
    
    func confirmAction() {
        FollowToggleDataManager.shared.followToggleDataManager(self.recievedHandle ?? "", { resultData in
            print(resultData.message)
        })
        self.receivedIsFollow = false
        followToggleBtn.setTitle("팔로우", for: .normal)
        followToggleBtn.backgroundColor = UIColor(named: "yellow00")
    }
    
    func cancel() {
        print("취소하기 선택됨")
    }
}

extension OtherUserProfileViewController: SecondViewControllerDelegate {
    func dismissSecondViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
