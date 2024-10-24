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
    
    // MARK: - Properties
    
    let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId)
    var receivedHandle: String?
    var receivedFollowerCount: Int = 0
    var receivedFollowingCount: Int = 0
    var receivedIsFollow: Bool?
    var searchBlockedUser: Bool = false
    lazy var moreButton: UIBarButtonItem = { // 업로드 버튼
        let barButton = UIBarButtonItem(image: UIImage(named: "moreButtonIcon"), style: .plain, target: self, action: #selector(moreButtonPressed))
        return barButton
    }()
    
    // MARK: - Views
    
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
    @IBOutlet weak var updateProfileBtn: UIButton!
    
    // MARK: - Lifecycle
    
    // Container View에 데이터 전달(ViewDidLoad보다 먼저 실행)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //storyboard에서 설정한 identifier와 동일한 이름
        if segue.identifier == "embedContainer" {
            let postListVC = segue.destination as! PostListViewController
            postListVC.handle = receivedHandle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        setUpViewController()
        setUpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // VC가 나타날 때 네비게이션바 숨김
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        setUpData()
    }
    
    // MARK: - Actions
    
    @IBAction func followToggleButton(_ sender: UIButton) {
        if receivedIsFollow! {
            showAlert(alertType: .confirmAndCancel,
                      titleText: "팔로우를 취소할까요?",
                      messageText: "",
                      cancelButtonText: "나가기",
                      confirmButtonText: "계속하기"
            )
        } else {
            FollowToggleDataManager.shared.followToggleDataManager(self.receivedHandle ?? "", { resultData in
                print(resultData.message)
            })
            self.receivedIsFollow = true
            sender.setTitle("팔로잉", for: .normal)
            sender.backgroundColor = UIColor(named: "gray03")
        }
    }
    
    @objc private func viewFollowerTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 0
        followListVC.handle = receivedHandle ?? ""
        followListVC.followerCount = receivedFollowerCount
        followListVC.followingCount = receivedFollowingCount
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func viewFollowingTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 1
        followListVC.handle = receivedHandle ?? ""
        followListVC.followerCount = receivedFollowerCount
        followListVC.followingCount = receivedFollowingCount
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc func moreButtonPressed() {
        guard let profileMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "profileMenuVC") as? ProfileMenuViewController else {return}
        let sheet = profileMenuVC.sheetPresentationController
        profileMenuVC.receivedHandle = receivedHandle
        
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
    
    // MARK: - Functions
    
    @IBAction func updateProfile(_ sender: Any) {
        guard let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else {return}
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    private func setUpNavigationBar() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        self.navigationItem.title = "@" + (receivedHandle ?? "handle not found")
        self.navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setUpViewController() {
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        profileImage.contentMode = .scaleAspectFill
        
        whiteBackground.layer.cornerRadius = 8
        followToggleBtn.layer.cornerRadius = 8
        
        viewFollowerList()
        viewFollowingList()
        
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.followToggleBtn.bottomAnchor, constant: 5).isActive = true
        postListTabmanView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        postListTabmanView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        postListTabmanView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        updateProfileBtn.layer.isHidden = true
    }
    
    private func viewFollowerList() { //  UITapGestureRecognizer 사용
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowerTapped))
        followerList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func viewFollowingList() { //  UITapGestureRecognizer 사용
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowingTapped))
        followingList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpData() {
        MyProfilePostDataManager.shared.myProfileUserAndPochakedPostDataManager(receivedHandle ?? "",0,{
            response in
            switch response {
            case .success(let resultData):
                let currentHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
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
                
                // 필요한 데이터 뷰에 반영
                self.userName.text = String(resultData.name ?? "")
                self.userMessage.text = String(resultData.message ?? "")
                self.postCount.text = String(resultData.totalPostNum ?? 0)
                self.followerCount.text = String(resultData.followerCount ?? 0)
                self.followingCount.text = String(resultData.followingCount ?? 0)
                self.receivedFollowerCount = resultData.followerCount ?? 0
                self.receivedFollowingCount = resultData.followingCount ?? 0
                self.receivedIsFollow = resultData.isFollow
                
                // 버튼 설정
                if currentHandle == self.receivedHandle{
                    /// 내 프로필 조회한 경우
                    self.followToggleBtn.layer.isHidden = true
                    self.updateProfileBtn.layer.isHidden = false
                    self.postListTabmanView.topAnchor.constraint(equalTo: self.whiteBackground.bottomAnchor, constant: 5).isActive = true
                    self.moreButton.isHidden = true
                    
                } else {
                    self.followToggleBtn.setTitleColor(UIColor.white, for: .normal)
                    self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16) // 폰트 설정
                    self.followToggleBtn.layer.cornerRadius = 5
                    
                    if resultData.isFollow == true {
                        /// 팔로우 중인 유저인 경우
                        self.followToggleBtn.setTitle("팔로잉", for: .normal)
                        self.followToggleBtn.backgroundColor = UIColor(named: "gray03")
                        
                    } else {
                        /// 팔로우하고 있지 않은 유저인 경우
                        self.followToggleBtn.setTitle("팔로우", for: .normal)
                        self.followToggleBtn.backgroundColor = UIColor(named: "yellow00")
                        
                    }
                }
            case .MEMBER4002:
                self.navigationController?.popViewController(animated: true)
                print("유효하지 않은 멤버의 handle입니다.")
                self.navigationItem.title = ""
                self.searchBlockedUser = true
                self.showAlert(alertType: .confirmOnly,
                               titleText: "차단한 유저의 프로필입니다.",
                               messageText: "차단해제를 원하시면\n설정 탭의 차단관리 페이지를 확인해주세요.",
                               cancelButtonText: "",
                               confirmButtonText: "확인"
                )
            }
        })
    }
}

// MARK: - Extension : CustomAlertDelegate, SecondViewControllerDelegate

extension OtherUserProfileViewController: CustomAlertDelegate {
    
    func confirmAction() {
        if searchBlockedUser {
            print("confirm selected!")
        } else {
            FollowToggleDataManager.shared.followToggleDataManager(receivedHandle ?? "", { resultData in
                print(resultData.message)
            })
            self.receivedIsFollow = false
            followToggleBtn.setTitle("팔로우", for: .normal)
            followToggleBtn.backgroundColor = UIColor(named: "yellow00")
        }
    }
    
    func cancel() {
        print("취소하기 선택됨")
    }
}

extension OtherUserProfileViewController: SecondViewControllerDelegate {
    
    // 차단한 유저의 프로필 조회 시 VC를 dismiss하여 전 화면으로 돌아감
    func dismissSecondViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
