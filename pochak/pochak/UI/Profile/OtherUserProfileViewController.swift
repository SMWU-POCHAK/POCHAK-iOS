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
    
    var isCurrentlyFetching: Bool = false
    
    var receivedHandle: String?
    private var isFollowing: Bool = false
    var searchBlockedUser: Bool = false
    
    private let viewModel = ProfileViewModel()
    private let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
    
    private var pageViewControllerList: [UIViewController] = []
    private let underlineViewWidth: CGFloat = UIScreen.main.bounds.width / 2
    private var currentPage: Int = 0 {
        didSet {
            let direction: UIPageViewController.NavigationDirection = (oldValue <= self.currentPage) ? .forward : .reverse
            self.pageViewController.setViewControllers(
                [pageViewControllerList[self.currentPage]],
                direction: direction,
                animated: true,
                completion: nil
            )
        }
    }
    
    private var profilePageInfo: MyProfileTabPageInfoModel = .init(currentPage: 0, isLastPage: false)
    private var pochakPostPageInfo: MyProfileTabPageInfoModel = .init(currentPage: 0, isLastPage: false)
    
    private var showStickyViews: Bool = false {
        willSet(newValue) {  // sticky와 non-sticky 간의 일관성 유지를 위해 필요
            if newValue {  // sticky view가 보일 예정
                stickySegmentControl.selectedSegmentIndex = currentPage
                changeSelectedSegmentLinePosition()
            }
            else {  // sticky view가 사라질 예정
                segmentControl.selectedSegmentIndex = currentPage
                changeSelectedSegmentLinePosition()
            }
        }
    }
    private var hasScrolled = false  // 초기 상태 체크하는 변수 - 뷰가 로딩되는 과정에서 scrollViewDidScroll이 호출되기 때문에 showStickyViews 값이 의도대로 바뀌지 않음
    
    // MARK: - Views
    
    lazy var moreButtonBarItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem(image: UIImage(named: "moreButtonIcon"), style: .plain, target: self, action: #selector(moreButtonDidTap))
        return barButton
    }()
        
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = true
        view.delegate = self
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let profileView: UIView = UIView()
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 116 / 2
        view.layer.borderColor = UIColor(named: "yellow00")?.cgColor
        view.image = UIImage(named: "pochakIcon")
        view.layer.borderWidth = 3
        return view
    }()
    
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
    
    private let profileEditButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "pencilIcon")
        config.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        config.baseBackgroundColor = UIColor(named: "yellow00")
        config.cornerStyle = .capsule
        
        button.configuration = config
        button.layer.cornerRadius = 25 / 2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(editProfileButtonDidTap), for: .touchUpInside)
        
        button.isHidden = true
        return button
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.bodyMedium)
        label.text = "Suyeon"
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3)
        label.numberOfLines = 3
        label.textAlignment = .left
        label.text = "hello"
        return label
    }()
    
    private let infoHStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 64
        view.alignment = .center
        view.distribution = .fillEqually
        return view
    }()
    
    private let postCountVStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .center
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let postCountLabel: UILabel = {
        let label = UILabel()
        label.text = "게시글"
        label.applyPochakFont(.body3_1)
        return label
    }()
    
    private let postCountNumberLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3)
        label.text = "100"
        return label
    }()
    
    private let followerCountVStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .center
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let followerCountLabel: UILabel = {
        let label = UILabel()
        label.text = "팔로워"
        label.applyPochakFont(.body3_1)
        return label
    }()
    
    private let followerCountNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "150"
        label.applyPochakFont(.body3)
        return label
    }()
    
    private let followingCountVStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .center
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let followingCountLabel: UILabel = {
        let label = UILabel()
        label.text = "팔로잉"
        label.applyPochakFont(.body3_1)
        return label
    }()
    
    private let followingCountNumberLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3)
        label.text = "200"
        return label
    }()
    
    private let followButton: FollowButton = {
        let button = FollowButton()
        button.addTarget(self, action: #selector(followButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let segmentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "POCHAKED", at: 0, animated: true)
        segment.insertSegment(withTitle: "POCHAK", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "warmGray02"),  // TODO: warmGray02가 CECCC8맞는지 확인 필요
            NSAttributedString.Key.font: UIFont.Pretendard(size: 16, family: .Bold),
            NSAttributedString.Key.paragraphStyle: paragraphStyle],
                                       for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "navy00"),
            NSAttributedString.Key.font: UIFont.Pretendard(size: 16, family: .Bold),
            NSAttributedString.Key.paragraphStyle: paragraphStyle],
                                       for: .selected)
        
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        segment.setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segment.addTarget(self, action: #selector(segmentIndexDidChange(_:)), for: .valueChanged)
        return segment
    }()
    
    private let segmentUnderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "yellow00")
        return view
    }()
    
    private let stickySegmentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private let stickySegmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.insertSegment(withTitle: "POCHAKED", at: 0, animated: true)
        segment.insertSegment(withTitle: "POCHAK", at: 1, animated: true)
        segment.selectedSegmentIndex = 0
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "warmGray02"),  // TODO: warmGray02가 CECCC8맞는지 확인 필요
            NSAttributedString.Key.font: UIFont.Pretendard(size: 16, family: .Bold),
            NSAttributedString.Key.paragraphStyle: paragraphStyle],
                                       for: .normal)
        segment.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(named: "navy00"),
            NSAttributedString.Key.font: UIFont.Pretendard(size: 16, family: .Bold),
            NSAttributedString.Key.paragraphStyle: paragraphStyle],
                                       for: .selected)
        
        segment.selectedSegmentTintColor = .clear
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        segment.setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        segment.addTarget(self, action: #selector(segmentIndexDidChange(_:)), for: .valueChanged)
        segment.isHidden = true
        return segment
    }()
    
    private let stickySegmentUnderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "yellow00")
        view.isHidden = true
        return view
    }()
    
    private lazy var vc1 = PostListPageViewController(type: .POCHAKED, parentVC: self, isMyProfile: false)
    private lazy var vc2 = PostListPageViewController(type: .POCHAK, parentVC: self, isMyProfile: false)
    
    private lazy var pageViewController: UIPageViewController = {
        pageViewControllerList = [vc1, vc2]
        
        let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.setViewControllers([self.pageViewControllerList[0]], direction: .forward, animated: true)
        vc.delegate = self
        vc.dataSource = self
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        bind()
        
        addViews()
        setupConstraints()
        addFollwerGestureRecognizer()
        addFollowingGestuerRecognizer()
        
        setUpNavigationBar()
                
        isCurrentlyFetching = true
        viewModel.fetchProfile(isMyProfile: false, handle: receivedHandle!, request: .init(page: profilePageInfo.currentPage), fromCurrentVC: self)
        viewModel.fetchPochakPosts(isMyProfile: true, handle: receivedHandle!, request: .init(page: pochakPostPageInfo.currentPage), fromCurrentVC: self)
        
        setUpRefreshControl()
        
        scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 스크롤뷰 기본 설정 - 충분한 높이로 임의로 설정
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 1200)
        print("scrollView.contentSize: \(scrollView.contentSize)")
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 1200)
        print("contentView.frame: \(contentView.frame)")
        
        updateScrollViewContentSize()
        
        // 스크롤이 시작되기 전, 처음 한번만 호출되도록 설정
        if !hasScrolled {
            hasScrolled = true
            // 초기 상태에서 scrollView의 contentOffset을 설정하여 불필요한 호출을 방지
            scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        }
    }
    
    // MARK: - Actions
    
    @objc private func moreButtonDidTap() {
        guard let profileMenuVC = self.profileTabSb.instantiateViewController(withIdentifier: "profileMenuVC")
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
        self.present(profileMenuVC, animated: true)
    }
    
    private func navigateToMemoryView() {
        guard let userID = receivedHandle else { return }
        let viewModel = MemoryViewModel(userID: userID)
        let summaryViewController = MemoryViewController(viewModel: viewModel)
        summaryViewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(summaryViewController, animated: true)
    }
    
    @objc private func editProfileButtonDidTap(_ sender: Any) {
        guard let updateProfileVC = profileTabSb.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else { return }
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    @objc private func followerStackViewDidTap() {
        guard let followListVC = profileTabSb.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else { return }
        followListVC.index = 0
        followListVC.handle = receivedHandle
        self.navigationController?.pushViewController(followListVC, animated: true)
    }

    @objc private func followingStackViewDidTap() {
        guard let followListVC = profileTabSb.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else { return }
        followListVC.index = 1
        followListVC.handle = receivedHandle
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func followButtonDidTap() {
        if isFollowing {
            showAlert(alertType: .confirmAndCancel,
                      titleText: "팔로우를 취소할까요?",
                      messageText: "",
                      cancelButtonText: "나가기",
                      confirmButtonText: "계속하기")
        }
        else {
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
                    self?.isFollowing = true
                    self?.followButton.isFollowing = true
                }
            } else {
                print("No handle received")
            }
        }
    }
    
    @objc private func segmentIndexDidChange(_ segment: UISegmentedControl) {
        currentPage = segment.selectedSegmentIndex
        changeSelectedSegmentLinePosition()
    }
    
    @objc private func refreshData(_ sender: Any) {
        print("=====================")
        print("REFRESHING  DATA")
        print("=====================")
        self.profilePageInfo = .init(currentPage: 0, isLastPage: false)
        self.pochakPostPageInfo = .init(currentPage: 0, isLastPage: false)
        
        self.vc1.setPostCollectionViewData([])
        self.vc2.setPostCollectionViewData([])
        
        self.isCurrentlyFetching = true
        // TODO: receivedHandle 옵셔널 처리
        viewModel.fetchProfile(isMyProfile: false, handle: receivedHandle!, request: .init(page: profilePageInfo.currentPage), fromCurrentVC: self)
        viewModel.fetchPochakPosts(isMyProfile: true, handle: receivedHandle!, request: .init(page: pochakPostPageInfo.currentPage), fromCurrentVC: self)
        
        DispatchQueue.main.async() {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Layout
    
    private func addViews() {
        view.addSubview(scrollView)
        
        view.addSubview(stickySegmentContainerView)
        stickySegmentContainerView.addSubview(stickySegmentControl)
        stickySegmentContainerView.addSubview(stickySegmentUnderLineView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileView)
        
        profileView.addSubview(profileImageView)
        profileView.addSubview(memoryButton)
        profileView.addSubview(profileEditButton)
        profileView.addSubview(nicknameLabel)
        profileView.addSubview(introLabel)
        
        profileView.addSubview(infoHStackView)
        [postCountVStackView, followerCountVStackView, followingCountVStackView].forEach {
            infoHStackView.addArrangedSubview($0)
        }
        [postCountLabel, postCountNumberLabel].forEach{
            postCountVStackView.addArrangedSubview($0)
        }
        [followingCountLabel, followingCountNumberLabel].forEach{
            followingCountVStackView.addArrangedSubview($0)
        }
        [followerCountLabel, followerCountNumberLabel].forEach{
            followerCountVStackView.addArrangedSubview($0)
        }
        
        profileView.addSubview(followButton)
        
        contentView.addSubview(segmentContainerView)
        segmentContainerView.addSubview(segmentControl)
        segmentContainerView.addSubview(segmentUnderLineView)
        
        contentView.addSubview(pageViewController.view)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        stickySegmentContainerView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(31)
        }
        stickySegmentControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
        }
        stickySegmentUnderLineView.snp.makeConstraints { make in
            make.top.equalTo(stickySegmentControl.snp.bottom).offset(8)
            make.height.equalTo(4)
            make.width.equalTo(underlineViewWidth)
            make.leading.equalTo(stickySegmentControl.snp.leading)
            make.bottom.equalToSuperview()
        }
        
        profileView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(23)
            make.width.height.equalTo(116)
        }
        memoryButton.snp.makeConstraints { make in
            make.width.height.equalTo(48)
            make.trailing.equalTo(profileImageView.snp.trailing)
            make.bottom.equalTo(profileImageView.snp.bottom).offset(11)
        }
        profileEditButton.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageView.snp.bottom)
            make.trailing.equalTo(profileImageView.snp.trailing).inset(11)
            make.width.height.equalTo(25)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.top.equalTo(profileImageView.snp.top).inset(11)
        }
        
        introLabel.snp.makeConstraints { make in
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(20)
        }
        
        infoHStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).offset(28)
        }
        
        followButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(infoHStackView.snp.bottom).offset(16)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(22)
        }
        
        segmentContainerView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(31)
        }
        segmentControl.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
        }
        segmentUnderLineView.snp.makeConstraints { make in
            make.top.equalTo(segmentControl.snp.bottom).offset(8)
            make.height.equalTo(4)
            make.width.equalTo(underlineViewWidth)
            make.leading.equalTo(segmentControl.snp.leading)
            make.bottom.equalToSuperview()
        }
        
        pageViewController.view.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(segmentContainerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Functions
    
    private func bind() {
        viewModel.profileDataDidChange = { [weak self] data in
            guard let data = data else { return }
            
            self?.profilePageInfo.isLastPage = data.pageInfo.lastPage
            
            self?.setupData(data)
            self?.vc1.setPostCollectionViewData(data.postList)
        }
        
        viewModel.pochakPostDataDidChange = { [weak self] data in
            guard let data = data else { return }
            
            self?.pochakPostPageInfo.isLastPage = data.pageInfo.lastPage
            
            self?.vc2.setPostCollectionViewData(data.postList)
        }
    }
    
    private func setupData(_ responseData: ProfileRetrievalResult) {
        print("[OtherUserPRofileViewController] setupData")
        print(">> \(receivedHandle!)")
        self.navigationItem.title = "@" + (receivedHandle ?? "handle not found")
        
        if let receivedHandle = self.receivedHandle, let url = URL(string: "https://storage.googleapis.com/pochak-image-bucket/member/\(receivedHandle)") {  // TODO: 추후 APIConstants 변수로 수정
            self.profileImageView.load(with: url)
        }
        else {
            self.profileImageView.image = UIImage(named: "pochakIcon")
        }
        
        // 프로필 정보는 페이지 0일 때만 오기 때문에 프로필 정보는 그대로 둠
        if profilePageInfo.currentPage == 0 {
            print(">> profile page info currentpage == 0")
            self.nicknameLabel.text = responseData.name
            self.introLabel.text = responseData.message
            
            self.postCountNumberLabel.text = String(responseData.totalPostNum ?? 0)
            self.followerCountNumberLabel.text = String(responseData.followerCount ?? 0)
            self.followingCountNumberLabel.text = String(responseData.followingCount ?? 0)
                        
            self.memoryButton.isHidden = responseData.isBonded == false
            
            if let isFollow = responseData.isFollow {
                self.isFollowing = isFollow
                self.followButton.isFollowing = isFollow
                
                // TODO: warmGray02가 CECCC8맞는지 확인 필요
                self.profileImageView.layer.borderColor = isFollow ? UIColor(named: "yellow00")?.cgColor : UIColor(named: "warmGray02")?.cgColor
            }
            else {  // 내 프로필 조회한 경우
                self.followButton.isHidden = true
                //self.memoryButton.isHidden = true
                self.moreButtonBarItem.isHidden = true
                self.profileEditButton.isHidden = false
                
                self.profileImageView.layer.borderColor = UIColor(named: "yellow00")?.cgColor
            }
        }
    }
    
    private func setUpRefreshControl() {
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    private func addFollwerGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followerStackViewDidTap))
        followerCountVStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func addFollowingGestuerRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(followingStackViewDidTap))
        followingCountVStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// segment 변경이 있을 경우 밑의 under line의 위치 변경해주는 메소드
    private func changeSelectedSegmentLinePosition() {
        lazy var leadingValue: CGFloat = (showStickyViews ? CGFloat(stickySegmentControl.selectedSegmentIndex) : CGFloat(segmentControl.selectedSegmentIndex)) * underlineViewWidth
        UIView.animate(withDuration: 0.3, animations: {
            self.stickySegmentUnderLineView.snp.updateConstraints { $0.leading.equalTo(self.stickySegmentControl.snp.leading).offset(leadingValue) }
            self.segmentUnderLineView.snp.updateConstraints { $0.leading.equalTo(self.segmentControl.snp.leading).offset(leadingValue) }
            self.view.layoutIfNeeded()
        })
    }
    
    func updateScrollViewContentSize() {
        print("[OtherUserProfileViewController] updateScrollViewContentSize =============")
        print(">> currentPage: \(currentPage)")
        let vc = self.pageViewControllerList[currentPage] as? PostListPageViewController
        let newHeight = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + (vc?.collectionView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height ?? 0) + 20 * 2
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: newHeight)
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: newHeight)
        print(">> Updated scrollView.contentSize: \(scrollView.contentSize)")
    }
    
    private func setUpNavigationBar() {
        navigationItem.title = "@" + (receivedHandle ?? "handle not found")
        navigationItem.rightBarButtonItem = moreButtonBarItem
    }
}

// MARK: - Extension: CustomAlertDelegate, SecondViewControllerDelegate

extension OtherUserProfileViewController: CustomAlertDelegate {
    
    func confirmAction() {
        if searchBlockedUser {
            self.navigationController?.popViewController(animated: true)
        }
        else {
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
                    self?.isFollowing = false
                    self?.followButton.isFollowing = false
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

// MARK: - Extension: UIPageViewController

extension OtherUserProfileViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // 이전 뷰를 설정
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.pageViewControllerList.firstIndex(of: viewController), index - 1 >= 0
        else { return nil }
        return self.pageViewControllerList[index - 1]
    }
    
    // 다음 뷰를 설정
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.pageViewControllerList.firstIndex(of: viewController), index + 1 < self.pageViewControllerList.count
        else { return nil }
        
        return self.pageViewControllerList[index + 1]
    }
    
    // 몇 번째 페이지가 로드되었는지 (-> segment control도 이동)
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool
    ) {
        guard let viewController = pageViewController.viewControllers?[0],
                let index = self.pageViewControllerList.firstIndex(of: viewController)
        else { return }
        
        self.currentPage = index
        self.stickySegmentControl.selectedSegmentIndex = index
        self.segmentControl.selectedSegmentIndex = index
        changeSelectedSegmentLinePosition()
    }
}

// MARK: - Extension; UIScrollView

extension OtherUserProfileViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 초기 offset이 설정된 후에만 처리하도록 조건 추가
        if !hasScrolled && scrollView.contentOffset.y == 0 {
            return // 초기 설정이 끝난 후 스크롤이 시작되었을 때만 처리
        }

        let shouldCurrentlyShowStickyViews = scrollView.contentOffset.y >= segmentContainerView.frame.minY
        if shouldCurrentlyShowStickyViews != showStickyViews {  //  불필요한 변경 방지
            showStickyViews = shouldCurrentlyShowStickyViews
            print("[OtherUserProfileViewController] showStickyViews: \(showStickyViews)")
            stickySegmentContainerView.isHidden = !showStickyViews
            stickySegmentControl.isHidden = !showStickyViews
            stickySegmentUnderLineView.isHidden = !showStickyViews
        }
        
        if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) {
            guard let receivedHandle = self.receivedHandle else { fatalError() }
            switch currentPage {
            case 0:
                if !profilePageInfo.isLastPage && !isCurrentlyFetching {
                    print("[!] OtherUserProfileViewController - NEEDS TO RE-FETCH DATA")
                    profilePageInfo.currentPage += 1
                    self.isCurrentlyFetching = true
                    viewModel.fetchProfile(isMyProfile: false, handle: receivedHandle, request: .init(page: profilePageInfo.currentPage), fromCurrentVC: self)
                }
                return
            case 1:
                if !pochakPostPageInfo.isLastPage && !isCurrentlyFetching {
                    print("[!] OtherUserProfileViewController - NEEDS TO RE-FETCH DATA")
                    pochakPostPageInfo.currentPage += 1
                    self.isCurrentlyFetching = true
                    viewModel.fetchPochakPosts(isMyProfile: true, handle: receivedHandle, request: .init(page: pochakPostPageInfo.currentPage), fromCurrentVC: self)
                }
                return
            default:
                return
            }
        }
    }
}

