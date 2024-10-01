//
//  ProfileTabViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

class MyProfileTabViewController: UIViewController {
    
    // MARK: - Properties
    
    let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
    
    // MARK: - Views
    
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
    
    // MARK: - Lifecycle
    
    // Container View에 데이터 전달(ViewDidLoad보다 먼저 실행)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //storyboard에서 설정한 identifier와 동일한 이름
        if segue.identifier == "embedContainer" {
            let postListVC = segue.destination as! PostListViewController
            postListVC.handle = handle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
        setUpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpData()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func clickSettingBtn(_ sender: Any) {
        guard let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsViewController else {return}
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        guard let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else {return}
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    @objc private func viewFollowerTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 0
        followListVC.handle = handle
        followListVC.followerCount = UserDefaultsManager.getData(type: Int.self, forKey: .followerCount) ?? 0
        followListVC.followingCount = UserDefaultsManager.getData(type: Int.self, forKey: .followingCount) ?? 0
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func viewFollowingTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 1
        followListVC.handle = handle
        followListVC.followerCount = UserDefaultsManager.getData(type: Int.self, forKey: .followerCount) ?? 0
        followListVC.followingCount = UserDefaultsManager.getData(type: Int.self, forKey: .followingCount) ?? 0
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    // MARK: - Functions
    
    private func setUpViewController() {
        self.navigationController?.isNavigationBarHidden = true
        
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        
        whiteBackground1.layer.cornerRadius = 8
        
        viewFollowerList()
        viewFollowingList()
        
        userHandle.text = "@\(handle)"
        
        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.topAnchor.constraint(equalTo: self.whiteBackground1.bottomAnchor, constant: 5).isActive = true
        postListTabmanView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        postListTabmanView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        postListTabmanView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
    }
    
    private func viewFollowerList() { /*  UITapGestureRecognizer 사용 */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowerTapped))
        followerList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func viewFollowingList() { /*  UITapGestureRecognizer 사용 */
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowingTapped))
        followingList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpData() {
        let request = ProfileRetrievalRequest(page: 0)
        ProfileService.getProfile(handle: handle, request: request) { data, failed in
            guard let data = data else {
                switch failed {
                case .clientError:
                    self.present(UIAlertController.networkErrorAlert(title: "유효하지 않은 멤버의 handle입니다."), animated: true)
                case .disconnected:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .unknownError:
                    self.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            print("=== Profile, setup data succeeded ===")
            print("== data: \(data)")
            
            // load 프로필 이미지
            if let url = URL(string: data.result.profileImage ?? "") {
                self.profileImage.load(with: url)
            }
            
            // 필요한 데이터 뷰에 반영
            self.setUpResponseData(data.result)
            
            // UserDefaultsManager에 데이터 저장 후 관리
            self.setUpUserDefaults(data.result)
        }
    }
    
    private func setUpResponseData(_ resposeData: ProfileRetrievalResult) {
        self.profileImage.contentMode = .scaleAspectFill
        self.userName.text = String(resposeData.name ?? "")
        self.userMessage.text = String(resposeData.message ?? "")
        self.postCount.text = String(resposeData.totalPostNum ?? 0)
        self.followerCount.text = String(resposeData.followerCount ?? 0)
        self.followingCount.text = String(resposeData.followingCount ?? 0)
    }
    
    private func setUpUserDefaults(_ resposeData: ProfileRetrievalResult) {
        UserDefaultsManager.setData(value: resposeData.name, key: .name)
        UserDefaultsManager.setData(value: resposeData.message, key: .message)
        UserDefaultsManager.setData(value: resposeData.followerCount, key: .followerCount)
        UserDefaultsManager.setData(value: resposeData.followingCount, key: .followingCount)
        UserDefaultsManager.setData(value: resposeData.profileImage, key: .profileImgUrl)
    }
}
