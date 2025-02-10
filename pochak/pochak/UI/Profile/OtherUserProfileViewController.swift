//
//  OtherUseProfileViewController.swift
//  pochak
//
//  Created by Seo Cindy on 1/16/24.
//

import UIKit
import Foundation

protocol SecondViewControllerDelegate: AnyObject {
    func dismissSecondViewController()
}

final class OtherUserProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    var receivedHandle: String?
    var receivedFollowerCount: Int = 0
    var receivedFollowingCount: Int = 0
    var receivedIsFollow: Bool?
    private let socialId = UserDefaultsManager.getData(type: String.self, forKey: .socialId)
    private var searchBlockedUser: Bool = false
    
    private lazy var moreButton: UIBarButtonItem = { // 업로드 버튼
        let barButton = UIBarButtonItem(image: UIImage(named: "moreButtonIcon"), style: .plain, target: self, action: #selector(moreButtonPressed))
        return barButton
    }()
    
    private let contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor(named: "gray01")
        return scrollView
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
    @IBOutlet weak var topUIView: UIView!
    
    private lazy var memoryButton: UIButton = {
        let button = UIButton()
        let memoryImage = UIImage(resource: .icMemory)
        button.setImage(memoryImage, for: .normal)
        button.addAction(UIAction { _ in
            self.navigateToMemoryView()
        }, for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
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
        addSubview()
        setUpUIConstraints()
        setUpRefreshControl()
        setUpNavigationBar()
        setUpViewController()
        setUpMemoryButton()
        setUpData()
        initializeSingleton()
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
                      confirmButtonText: "계속하기")
        } else {
            if let handle = receivedHandle {
                UserService.postFollowRequest(handle: handle) { [weak self] data, failed in
                    guard let data = data else {
                        switch failed {
                        case .disconnected:
                            self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                        case .serverError:
                            self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                        case .unknownError:
                            self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                        default:
                            self?.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                        }
                        return
                    }
                    self?.receivedIsFollow = true
                    sender.setTitle("팔로잉", for: .normal)
                    sender.backgroundColor = UIColor(named: "gray03")
                    self?.setUpData()
                }
            } else {
                print("No handle received")
            }
        }
    }
    
    private func navigateToMemoryView() {
        guard let userID = receivedHandle else { return }
        let viewModel = MemoryViewModel(userID: userID)
        let summaryViewController = MemoryViewController(viewModel: viewModel)
        summaryViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(summaryViewController, animated: true)
    }
    
    @IBAction func updateProfile(_ sender: Any) {
        guard let updateProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else { return }
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }

    @objc private func viewFollowerTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else { return }
        followListVC.index = 0
        followListVC.handle = receivedHandle ?? ""
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func viewFollowingTapped() {
        guard let followListVC = self.storyboard?.instantiateViewController(withIdentifier: "FollowListVC")
                as? FollowListViewController else { return }
        followListVC.index = 1
        followListVC.handle = receivedHandle ?? ""
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func moreButtonPressed() {
        guard let profileMenuVC = self.storyboard?.instantiateViewController(withIdentifier: "profileMenuVC")
                as? ProfileMenuViewController else { return }
        let sheet = profileMenuVC.sheetPresentationController
        profileMenuVC.receivedHandle = receivedHandle
        
        let multiplier = 0.25
        let fraction = UISheetPresentationController.Detent.custom { context in
            self.view.bounds.height * multiplier
        }
        sheet?.detents = [fraction]
        sheet?.prefersGrabberVisible = true
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false
        
        profileMenuVC.delegate = self
        present(profileMenuVC, animated: true)
    }
    
    @objc private func refreshData(_ sender: Any) {
        setUpData()
        DispatchQueue.main.async() {
            self.contentScrollView.refreshControl?.endRefreshing()
        }
    }
    
    @objc private func totalHeightUpdated() {
        ProfileDataSingleton.shared.currentTabIndex == 0 ?
        (updatePostListTabmanViewHeight(ProfileDataSingleton.shared.firstTabHeight)) :
        (updatePostListTabmanViewHeight(ProfileDataSingleton.shared.secondTabHeight))
    }
    
    // MARK: - Functions
    
    private func addSubview() {
        self.view.addSubview(contentScrollView)
        contentScrollView.addSubview(topUIView)
        topUIView.addSubview(postListTabmanView)
    }
    
    private func setUpUIConstraints() {
        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        topUIView.translatesAutoresizingMaskIntoConstraints = false
        postListTabmanView.translatesAutoresizingMaskIntoConstraints = false
        profileBackground.translatesAutoresizingMaskIntoConstraints = false
        whiteBackground.translatesAutoresizingMaskIntoConstraints = false
        userName.translatesAutoresizingMaskIntoConstraints = false
        userMessage.translatesAutoresizingMaskIntoConstraints = false
        followToggleBtn.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        updateProfileBtn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let scrollContentGuide = contentScrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            topUIView.topAnchor.constraint(equalTo: scrollContentGuide.topAnchor),
            topUIView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topUIView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topUIView.bottomAnchor.constraint(equalTo: postListTabmanView.bottomAnchor), // Dynamic height for topUIView
            
            profileBackground.topAnchor.constraint(equalTo: topUIView.topAnchor, constant: 20),
            profileBackground.leadingAnchor.constraint(equalTo: topUIView.leadingAnchor, constant: 20),
            
            userName.topAnchor.constraint(equalTo: profileBackground.topAnchor, constant: 15),
            userName.leadingAnchor.constraint(equalTo: profileBackground.trailingAnchor, constant: 20),
            userName.trailingAnchor.constraint(equalTo: topUIView.trailingAnchor),
            
            profileImage.centerXAnchor.constraint(equalTo: profileBackground.centerXAnchor),
            profileImage.centerYAnchor.constraint(equalTo: profileBackground.centerYAnchor),
            
            updateProfileBtn.bottomAnchor.constraint(equalTo: profileBackground.bottomAnchor, constant: -5),
            updateProfileBtn.trailingAnchor.constraint(equalTo: profileBackground.trailingAnchor, constant: -5),
            
            userMessage.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 10),
            userMessage.leadingAnchor.constraint(equalTo: profileBackground.trailingAnchor, constant: 20),
            userMessage.trailingAnchor.constraint(equalTo: topUIView.trailingAnchor),
            
            whiteBackground.topAnchor.constraint(equalTo: profileBackground.bottomAnchor, constant: 20),
            whiteBackground.leadingAnchor.constraint(equalTo: profileBackground.leadingAnchor),
            whiteBackground.centerXAnchor.constraint(equalTo: topUIView.centerXAnchor),
            whiteBackground.trailingAnchor.constraint(equalTo: topUIView.trailingAnchor, constant: -20),
            
            followToggleBtn.topAnchor.constraint(equalTo: whiteBackground.bottomAnchor, constant: 9),
            followToggleBtn.leadingAnchor.constraint(equalTo: whiteBackground.leadingAnchor),
            followToggleBtn.trailingAnchor.constraint(equalTo: whiteBackground.trailingAnchor),
            
            postListTabmanView.topAnchor.constraint(equalTo: followToggleBtn.bottomAnchor, constant: 5),
            postListTabmanView.leadingAnchor.constraint(equalTo: topUIView.leadingAnchor),
            postListTabmanView.trailingAnchor.constraint(equalTo: topUIView.trailingAnchor),
            postListTabmanView.heightAnchor.constraint(equalToConstant: view.frame.height - 350)
        ])
    }
    
    private func setUpRefreshControl() {
        contentScrollView.refreshControl = UIRefreshControl()
        contentScrollView.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    private func setUpNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationItem.title = "@" + (receivedHandle ?? "handle not found")
        navigationItem.rightBarButtonItem = moreButton
    }
    
    private func setUpMemoryButton() {
        view.addSubview(memoryButton)
        
        memoryButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.trailing.equalTo(profileBackground.snp.trailing)
            make.bottom.equalTo(profileBackground.snp.bottom).offset(11)
        }
    }
    
    private func setUpViewController() {
        profileBackground.layer.cornerRadius = 58
        profileImage.layer.cornerRadius = 55
        profileImage.contentMode = .scaleAspectFill
        whiteBackground.layer.cornerRadius = 8
        followToggleBtn.layer.cornerRadius = 8
        viewFollowerList()
        viewFollowingList()
        updateProfileBtn.layer.isHidden = true
        contentScrollView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(totalHeightUpdated), name: .didUpdateTotalHeight, object: nil)
    }
    
    private func setUpData() {
        let request = ProfileRetrievalRequest(page: 0)
        if let handle = receivedHandle {
            ProfileService.getProfile(handle: handle, request: request) { data, failed in
                guard let data = data else {
                    switch failed {
                    case .clientError:
                        self.navigationItem.title = ""
                        self.searchBlockedUser = true
                        self.showAlert(alertType: .confirmOnly,
                                       titleText: "차단한 유저의 프로필입니다.",
                                       messageText: "차단해제를 원하시면\n설정 탭의 차단관리 페이지를 확인해주세요.",
                                       cancelButtonText: "",
                                       confirmButtonText: "확인")
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
                
                // 프로필 이미지 로드
                if let url = URL(string: data.result.profileImage ?? "") {
                    self.profileImage.load(with: url)
                }
                
                // 필요한 데이터 뷰에 반영
                self.setUpResponseData(data.result)
                
                // 팔로우 버튼 설정
                self.setUpFollowBtn(data.result)
            }
        } else {
            print("No handle received")
        }
    }
    
    private func initializeSingleton() {
        ProfileDataSingleton.shared.currentTabIndex = 0
        ProfileDataSingleton.shared.firstTabHeight = 0.0
        ProfileDataSingleton.shared.secondTabHeight = 0.0
        ProfileDataSingleton.shared.firstTabIsCurrentlyFetching = false
        ProfileDataSingleton.shared.secondTabIsCurrentlyFetching = false
        ProfileDataSingleton.shared.firstTabIsLastPage = false
        ProfileDataSingleton.shared.secondTabIsLastPage = false
    }
    
    private func viewFollowerList() { //  UITapGestureRecognizer 사용
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowerTapped))
        followerList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func viewFollowingList() { //  UITapGestureRecognizer 사용
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewFollowingTapped))
        followingList.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpResponseData(_ responseData: ProfileRetrievalResult) {
        self.userName.text = String(responseData.name ?? "")
        self.userMessage.text = String(responseData.message ?? "")
        self.postCount.text = String(responseData.totalPostNum ?? 0)
        self.followerCount.text = String(responseData.followerCount ?? 0)
        self.followingCount.text = String(responseData.followingCount ?? 0)
        self.receivedFollowerCount = responseData.followerCount ?? 0
        self.receivedFollowingCount = responseData.followingCount ?? 0
        self.receivedIsFollow = responseData.isFollow
    }
    
    private func setUpFollowBtn(_ responseData: ProfileRetrievalResult) {
        let currentHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
        if currentHandle == self.receivedHandle {
            /// 내 프로필 조회한 경우
            self.followToggleBtn.layer.isHidden = true
            self.updateProfileBtn.layer.isHidden = false
            self.postListTabmanView.topAnchor.constraint(equalTo: self.whiteBackground.bottomAnchor, constant: 5).isActive = true
            self.moreButton.isHidden = true
            
        } else {
            self.followToggleBtn.setTitleColor(UIColor.white, for: .normal)
            self.followToggleBtn.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 16)
            self.followToggleBtn.layer.cornerRadius = 5
            
            if responseData.isFollow == true {
                /// 팔로우 중인 유저인 경우
                self.followToggleBtn.setTitle("팔로잉", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "gray03")
                self.profileBackground.backgroundColor = UIColor(resource: .yellow00)
            } else {
                /// 팔로우하고 있지 않은 유저인 경우
                self.followToggleBtn.setTitle("팔로우", for: .normal)
                self.followToggleBtn.backgroundColor = UIColor(named: "yellow00")
            }
            
            self.memoryButton.isHidden = responseData.isBonded == false
        }
    }
    
    private func updatePostListTabmanViewHeight(_ height: CGFloat) {
        postListTabmanView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                if height >= constraint.constant && constraint.constant != 0 {
                    constraint.isActive = false
                    
                    // 새로운 높이 제약 조건 추가
                    postListTabmanView.heightAnchor.constraint(equalToConstant: height).isActive = true
                    UIView.animate(withDuration: 0.3, animations: {
                        self.contentScrollView.layoutIfNeeded()
                    }) { _ in
                        // ScrollView의 contentSize 업데이트
                        self.contentScrollView.contentSize = CGSize(
                            width: self.contentScrollView.frame.width,
                            height: self.topUIView.frame.height
                        )
                    }
                } else {
                    print("height : \(height)")
                    print("constraint.constant : \(constraint.constant)")
                    print("no posts yet")
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extension: CustomAlertDelegate, SecondViewControllerDelegate

extension OtherUserProfileViewController: CustomAlertDelegate {
    
    func confirmAction() {
        if searchBlockedUser {
            self.navigationController?.popViewController(animated: true)
        } else {
            if let handle = receivedHandle {
                UserService.postFollowRequest(handle: handle) { [weak self] data, failed in
                    guard let data = data else {
                        switch failed {
                        case .disconnected:
                            self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                        case .serverError:
                            self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                        case .unknownError:
                            self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                        default:
                            self?.present(UIAlertController.networkErrorAlert(title: "요청에 실패하였습니다."), animated: true)
                        }
                        return
                    }
                    print(data.message)
                    self?.receivedIsFollow = false
                    self?.followToggleBtn.setTitle("팔로우", for: .normal)
                    self?.followToggleBtn.backgroundColor = UIColor(named: "yellow00")
                    self?.setUpData()
                }
            } else {
                print("No handle received")
            }
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

extension OtherUserProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (contentScrollView.contentOffset.y > (contentScrollView.contentSize.height - contentScrollView.frame.size.height)) {
            if (ProfileDataSingleton.shared.currentTabIndex == 0 &&
                !ProfileDataSingleton.shared.firstTabIsCurrentlyFetching &&
                !ProfileDataSingleton.shared.firstTabIsLastPage) {
                NotificationCenter.default.post(name: .didHitBottom, object: nil)
            } else if (ProfileDataSingleton.shared.currentTabIndex == 1 &&
                       !ProfileDataSingleton.shared.secondTabIsCurrentlyFetching &&
                       !ProfileDataSingleton.shared.secondTabIsLastPage) {
                NotificationCenter.default.post(name: .didHitBottom, object: nil)
            }
        }
    }
}
