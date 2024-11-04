//
//  MyProfileTabViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

final class MyProfileTabViewController: UIViewController {
    
    // MARK: - Properties
    
    private let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
    
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
        addSubview()
        setUpUIConstraints()
        setUpRefreshControl()
        setUpData()
        setUpViewController()
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
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func viewFollowingTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else {return}
        followListVC.index = 1
        followListVC.handle = handle
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
        
    @objc private func refreshData(_ sender: Any) {
        print("refresh")
//        imageArray = []
//        currentFetchingPage = 0
        setUpData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.contentScrollView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Functions
    
    private let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor(named: "gray01")
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
    }()
    
    private func addSubview() {
        self.view.addSubview(contentScrollView)
        contentScrollView.addSubview(topUIView)
        topUIView.addSubview(postListTabmanView)
        
    }
    
    private func setUpUIConstraints() {
        topUIView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                contentScrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
                contentScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                contentScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                contentScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                topUIView.topAnchor.constraint(equalTo: contentScrollView.topAnchor),
                topUIView.leadingAnchor.constraint(equalTo: contentScrollView.leadingAnchor),
                topUIView.trailingAnchor.constraint(equalTo: contentScrollView.trailingAnchor),
                topUIView.bottomAnchor.constraint(equalTo: contentScrollView.bottomAnchor),
                topUIView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
                postListTabmanView.topAnchor.constraint(equalTo: self.whiteBackground1.bottomAnchor, constant: 5),
                postListTabmanView.leadingAnchor.constraint(equalTo: topUIView.leadingAnchor),
                postListTabmanView.trailingAnchor.constraint(equalTo: topUIView.trailingAnchor),
                postListTabmanView.bottomAnchor.constraint(equalTo: topUIView.bottomAnchor),
        ])
    }
    
    private func setUpRefreshControl() {
        contentScrollView.refreshControl = UIRefreshControl()
        contentScrollView.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
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
    
    private func setUpResponseData(_ responseData: ProfileRetrievalResult) {
        self.profileImage.contentMode = .scaleAspectFill
        self.userName.text = String(responseData.name ?? "")
        self.userMessage.text = String(responseData.message ?? "")
        self.postCount.text = String(responseData.totalPostNum ?? 0)
        self.followerCount.text = String(responseData.followerCount ?? 0)
        self.followingCount.text = String(responseData.followingCount ?? 0)
    }
    
    private func setUpUserDefaults(_ responseData: ProfileRetrievalResult) {
        UserDefaultsManager.setData(value: responseData.name, key: .name)
        UserDefaultsManager.setData(value: responseData.message, key: .message)
        UserDefaultsManager.setData(value: responseData.profileImage, key: .profileImgUrl)
    }
}
