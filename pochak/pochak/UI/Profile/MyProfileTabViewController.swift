//
//  MyProfileTabViewController.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

import UIKit

final class MyProfileTabViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = ProfileViewModel()
    private let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
    private let handle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
    private let underlineViewWidth: CGFloat = UIScreen.main.bounds.width / 2
    private var pageViewControllerList: [UIViewController] = []
    
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
    
    private var myProfileCurrentPage: Int = 0
    private var pochakPostCurrentPage: Int = 0
    
    // MARK: - Views
    
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
    
    private let headerView: UIView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body0)
        return label
    }()
    
    private let settingButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "settingIcon")
        
        button.configuration = config
        
        button.addTarget(self, action: #selector(settingButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let profileView: UIView = UIView()
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 116 / 2
        view.layer.borderColor = UIColor(named: "yellow00")?.cgColor
        view.layer.borderWidth = 3
        return view
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
        return button
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.bodyMedium)
        return label
    }()
    
    private let introLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3)
        label.numberOfLines = 3
        label.textAlignment = .left
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
        return label
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
            NSAttributedString.Key.foregroundColor: UIColor(hexCode: "CECCC8"),  // TODO: 추후 색상명으로 수정
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
    
    private lazy var vc1 = PostListPageViewController(type: .POCHAKED, parentVC: self)
    private lazy var vc2 = PostListPageViewController(type: .POCHAK, parentVC: self)
    
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
    
    //    // Container View에 데이터 전달(ViewDidLoad보다 먼저 실행)
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        //storyboard에서 설정한 identifier와 동일한 이름
    //        if segue.identifier == "embedContainer" {
    //            let postListVC = segue.destination as! PostListViewController
    //            postListVC.handle = handle
    //        }
    //    }
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        bind()
        
        addViews()
        setupConstraints()
        fetchData()
        addFollwerGestureRecognizer()
        addFollowingGestuerRecognizer()
        
        // 스크롤 충돌 방지 설정
        self.vc1.collectionView.panGestureRecognizer.require(toFail: self.scrollView.panGestureRecognizer)
        self.vc2.collectionView.panGestureRecognizer.require(toFail: self.scrollView.panGestureRecognizer)
        
        print("페이지 개수: \(pageViewController.viewControllers?.count ?? 0)")
        
        viewModel.fetchMyProfile(handle: handle, request: .init(page: myProfileCurrentPage), fromCurrentVC: self)
        viewModel.fetchPochakPosts(handle: handle, request: .init(page: pochakPostCurrentPage), fromCurrentVC: self)
        
        //        addSubview()
        //        setUpUIConstraints()
        //        setUpRefreshControl()
        //        setUpViewController()
        //        setUpData()
        //        initializeSingleton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 스크롤뷰 기본 설정 - 충분한 높이로 임의로 설정
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 1200)
        print("scrollView.contentSize: \(scrollView.contentSize)")
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: 1200)
        print("contentView.frame: \(contentView.frame)")
        
        updateScrollViewContentSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Actions
    
    @objc private func settingButtonDidTap() {
        guard let settingsVC = profileTabSb.instantiateViewController(withIdentifier: "SettingsVC") as? SettingsViewController else { return }
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func editProfileButtonDidTap(_ sender: Any) {
        guard let updateProfileVC = profileTabSb.instantiateViewController(withIdentifier: "UpdateProfileVC") as? UpdateProfileViewController else { return }
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    @objc private func followerStackViewDidTap() {
        guard let followListVC = profileTabSb.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else { return }
        followListVC.index = 0
        followListVC.handle = handle
        self.navigationController?.pushViewController(followListVC, animated: true)
    }

    @objc private func followingStackViewDidTap() {
        guard let followListVC = profileTabSb.instantiateViewController(withIdentifier: "FollowListVC") as? FollowListViewController else { return }
        followListVC.index = 1
        followListVC.handle = handle
        self.navigationController?.pushViewController(followListVC, animated: true)
    }
    
    @objc private func segmentIndexDidChange(_ segment: UISegmentedControl) {
        currentPage = segment.selectedSegmentIndex
        changeSelectedSegmentLinePosition()
    }
    
    //    @objc private func refreshData(_ sender: Any) {
    //        setUpData()
    //        DispatchQueue.main.async() {
    //            self.contentScrollView.refreshControl?.endRefreshing()
    //        }
    //    }
    //
    //    @objc private func totalHeightUpdated() {
    //        ProfileDataSingleton.shared.currentTabIndex == 0 ?
    //        (updatePostListTabmanViewHeight(ProfileDataSingleton.shared.firstTabHeight)) :
    //        (updatePostListTabmanViewHeight(ProfileDataSingleton.shared.secondTabHeight))
    //    }
    //
    
    // MARK: - Layout
    
    private func addViews() {
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(settingButton)
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileView)
        
        profileView.addSubview(profileImageView)
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
        
        contentView.addSubview(segmentContainerView)
        segmentContainerView.addSubview(segmentControl)
        segmentContainerView.addSubview(segmentUnderLineView)
        
        contentView.addSubview(pageViewController.view)
    }
    
    private func setupConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        settingButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(6)
            make.centerY.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        profileView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
        }
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(23)
            make.width.height.equalTo(116)
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
            make.bottom.equalToSuperview().inset(46)
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
            DispatchQueue.main.async {
                self?.setupData(data)
                self?.vc1.setPostCollectionViewData(data.postList)
            }
        }
        
        viewModel.pochakPostDataDidChange = { [weak self] data in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.vc2.setPostCollectionViewData(data.postList)
            }
        }
    }
    
    private func setupData(_ responseData: ProfileRetrievalResult) {
        self.titleLabel.text = "@\(handle)"
        
        if let url = URL(string: "https://storage.googleapis.com/pochak-image-bucket/member/\(handle)") {  // TODO: 추후 APIConstants 변수로 수정
            self.profileImageView.load(with: url)
        }
        else {
            self.profileImageView.image = UIImage(named: "pochakIcon")
        }
        
        self.nicknameLabel.text = responseData.name
        self.introLabel.text = responseData.message
        
        self.postCountNumberLabel.text = String(responseData.totalPostNum ?? 0)
        self.followerCountNumberLabel.text = String(responseData.followerCount ?? 0)
        self.followingCountNumberLabel.text = String(responseData.followingCount ?? 0)
        
        //self.vc1.setPostCollectionViewData([])
        //self.vc2.setPostCollectionViewData([])
    }
    
//    private func setUpRefreshControl() {
//        contentScrollView.refreshControl = UIRefreshControl()
//        contentScrollView.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
//    }
//    
//    private func setUpViewController() {
//        self.navigationController?.isNavigationBarHidden = true
//        profileBackground.layer.cornerRadius = 58
//        profileImage.layer.cornerRadius = 55
//        whiteBackground1.layer.cornerRadius = 8
//        viewFollowerList()
//        viewFollowingList()
//        userHandle.text = "@\(handle)"
//        let backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
//        backBarButtonItem.tintColor = .black
//        self.navigationItem.backBarButtonItem = backBarButtonItem
//        NotificationCenter.default.addObserver(self, selector: #selector(totalHeightUpdated), name: .didUpdateTotalHeight, object: nil)
//    }
//    
    private func fetchData() {
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
            
            // 필요한 데이터 뷰에 반영
            self.setupData(data.result)
            
            // UserDefaultsManager에 데이터 저장 후 관리
//            self.setUpUserDefaults(data.result)
        }
    }
    
//    private func initializeSingleton() {
//        ProfileDataSingleton.shared.currentTabIndex = 0
//        ProfileDataSingleton.shared.firstTabHeight = 0.0
//        ProfileDataSingleton.shared.secondTabHeight = 0.0
//        ProfileDataSingleton.shared.firstTabIsCurrentlyFetching = false
//        ProfileDataSingleton.shared.secondTabIsCurrentlyFetching = false
//        ProfileDataSingleton.shared.firstTabIsLastPage = false
//        ProfileDataSingleton.shared.secondTabIsLastPage = false
//    }
//    
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
        lazy var leadingValue: CGFloat = CGFloat(segmentControl.selectedSegmentIndex) * underlineViewWidth
        UIView.animate(withDuration: 0.3, animations: {
            self.segmentUnderLineView.snp.updateConstraints { $0.leading.equalTo(self.segmentControl.snp.leading).offset(leadingValue)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    func updateScrollViewContentSize() {
        print("[MyProfileTabViewController] updateScrollViewContentSize =============")
        print(">> self.pageViewController: \(self.pageViewController)")
        print(">> self.pageViewController.viewControllers: \(self.pageViewController.viewControllers)")
        print(">> currentPage: \(currentPage)")
        let vc = self.pageViewControllerList[currentPage] as? PostListPageViewController
        let newHeight = (vc?.collectionView.collectionViewLayout.collectionViewContentSize.height)! + 20 * 2 + profileView.frame.height + segmentContainerView.frame.height
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: newHeight)
        contentView.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: newHeight)
    }

//    private func setUpResponseData(_ responseData: ProfileRetrievalResult) {
//        self.profileImage.contentMode = .scaleAspectFill
//        self.userName.text = String(responseData.name ?? "")
//        self.userMessage.text = String(responseData.message ?? "")
//        self.postCount.text = String(responseData.totalPostNum ?? 0)
//        self.followerCount.text = String(responseData.followerCount ?? 0)
//        self.followingCount.text = String(responseData.followingCount ?? 0)
//    }
//    
//    private func setUpUserDefaults(_ responseData: ProfileRetrievalResult) {
//        UserDefaultsManager.setData(value: responseData.name, key: .name)
//        UserDefaultsManager.setData(value: responseData.message, key: .message)
//        UserDefaultsManager.setData(value: responseData.profileImage, key: .profileImgUrl)
//    }
//    
//    private func updatePostListTabmanViewHeight(_ height: CGFloat) {
//        postListTabmanView.constraints.forEach { constraint in
//            if constraint.firstAttribute == .height {
//                if height >= constraint.constant && constraint.constant != 0 {
//                    constraint.isActive = false
//                    
//                    // 새로운 높이 제약 조건 추가
//                    postListTabmanView.heightAnchor.constraint(equalToConstant: height).isActive = true
//                    UIView.animate(withDuration: 0.3, animations: {
//                        self.contentScrollView.layoutIfNeeded()
//                    }) { _ in
//                        // ScrollView의 contentSize 업데이트
//                        self.contentScrollView.contentSize = CGSize(
//                            width: self.contentScrollView.frame.width,
//                            height: self.topUIView.frame.height
//                        )
//                    }
//                } else {
//                    print("height : \(height)")
//                    print("constraint.constant : \(constraint.constant)")
//                    print("no posts yet")
//                }
//            }
//        }
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
}
//
//// MARK: - Extension: CustomAlertDelegate, SecondViewControllerDelegate
//
//extension MyProfileTabViewController: UIScrollViewDelegate {
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (contentScrollView.contentOffset.y > (contentScrollView.contentSize.height - contentScrollView.frame.size.height)) {
//            if (ProfileDataSingleton.shared.currentTabIndex == 0 &&
//                !ProfileDataSingleton.shared.firstTabIsCurrentlyFetching &&
//                !ProfileDataSingleton.shared.firstTabIsLastPage) {
//                NotificationCenter.default.post(name: .didHitBottom, object: nil)
//            } else if (ProfileDataSingleton.shared.currentTabIndex == 1 &&
//                       !ProfileDataSingleton.shared.secondTabIsCurrentlyFetching &&
//                       !ProfileDataSingleton.shared.secondTabIsLastPage) {
//                NotificationCenter.default.post(name: .didHitBottom, object: nil)
//            }
//        }
//    }
//}

// MARK: - Extension: UIPageViewController

extension MyProfileTabViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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
        self.segmentControl.selectedSegmentIndex = index
        changeSelectedSegmentLinePosition()
    }
}

// MARK: - Extension; UIScrollView

extension MyProfileTabViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
