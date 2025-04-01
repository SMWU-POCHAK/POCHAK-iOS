//
//  PostViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/04.
//

import UIKit

final class PostViewController: UIViewController {
    
    // MARK: - Properties
    
    var receivedPostId: Int?
    
    private let postStoryBoard = UIStoryboard(name: "ExploreTab", bundle: nil)
    private let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
    private let refreshControl = UIRefreshControl()
    private let viewModel = PostDetailViewModel()
    
    // MARK: - Views
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.delegate = self
        return view
    }()
    
    private let contentView = UIView()
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        view.clipsToBounds = true
        view.layer.cornerRadius = 50 / 2
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let usersStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .leading
        return view
    }()
    
    private let taggedUsersLabel: UILabel = {
        let label = UILabel()
        label.text = "pochak"
        label.font = UIFont.Pretendard(size: 16, family: .Bold)
        label.setLineHeightByPx(value: 22)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let usersStackView2: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 7
        return view
    }()
    
    private let pochakUserLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.bodyExtraSmall)
        label.isUserInteractionEnabled = true
        label.text = "pochak"
        label.font = UIFont.Pretendard(size: 13, family: .Regular)
        label.setLineHeightByPx(value: 18)
        return label
    }()
    
    private let pochakedTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "pochaked"
        label.textColor = UIColor(named: "gray04")
        label.font = UIFont.Pretendard(size: 13, family: .Regular)
        label.setLineHeightByPx(value: 18)
        return label
    }()
    
    private let followButton: PostDetailFollowButton = {
        let button = PostDetailFollowButton()
        button.isFollowing = false
        button.addTarget(self, action: #selector(followingButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let postImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .brown
        return view
    }()
    
    private let contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.alignment = .top
        return view
    }()
    
    private let contentUserLabel: UILabel = {
        let label = UILabel()
        label.text = "pochak"
        label.font = UIFont.Pretendard(size: 14, family: .Bold)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "pochak"
        label.numberOfLines = 0
        label.font = UIFont.Pretendard(size: 14, family: .Regular)
        return label
    }()
    
    private let likeAndCmtStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        return view
    }()
    
    private let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "LikeIcon"), for: .normal)
        button.setImage(UIImage(named: "LikeFilledIcon"), for: .selected)
        button.isSelected = false
        button.addTarget(self, action: #selector(likeButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "CommentIcon"), for: .normal)
        button.setImage(UIImage(named: "CommentFilledIcon"), for: .selected)
        button.isSelected = false
        button.addTarget(self, action: #selector(commentButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let borderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "gray01")
        return view
    }()
    
    private let recentCommentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.alignment = .top
        return view
    }()
    
    private let recentCommentHandleLabel: UILabel = {
        let label = UILabel()
        label.text = "pochak"
        label.setLineHeightByPx(value: 20)
        label.font = UIFont.Pretendard(size: 14, family: .Bold)
        
        return label
    }()
    
    private let recentCommentCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "hello"
        label.font = UIFont.Pretendard(size: 14, family: .Regular)
//        label.setLineHeightByPx(value: 20)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let moreCommentButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("더보기")
        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font : UIFont.Pretendard(), NSAttributedString.Key.foregroundColor : UIColor(named: "gray05")]))
        config.contentInsets = .zero
        
        button.configuration = config
        button.addTarget(self, action: #selector(moreCommentButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        bind()
        
        setupNavigationBar()
        self.navigationController?.isNavigationBarHidden = false
        
        addViews()
        setupConstraints()
        
//        initUI()
        
        /*postId 전달 - 실시간인기포스트에서 전달하는 postId 입니다
        전달되는 id 없으면 위에서 설정된 id로 될거에요..
        나중에 홈에서도 id 이렇게 전달해서 쓰면 될 것 같습니다 ㅎㅎ */
        if let data = receivedPostId {
            print("Received Data: \(data)")
            viewModel.fetchPostDetail(postId: data, fromCurrentVC: self)
        } else {
            print("No data received.")
        }
        
        addGestureRecognizers()
        setUpRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Actions
    
    @objc private func followingButtonDidTap(_ sender: Any) {
        if followButton.isFollowing {
            showAlert(alertType: .confirmAndCancel,
                      titleText: "팔로우를 취소할까요?",
                      cancelButtonText: "취소",
                      confirmButtonText: "확인")
        }
        else {
            viewModel.requestUserFollow(handle: viewModel.getPostDetailOwnerHandle()!, fromCurrentVC: self)
        }
    }

    @objc private func likeButtonDidTap(_ sender: Any) {
        viewModel.postLikeRequest(postId: receivedPostId!, fromCurrentVC: self)
    }
    
    @objc private func moveToOthersProfile(sender: UITapGestureRecognizer) {
        guard let otherUserProfileVC = profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
        
        if sender.view == profileImageView || sender.view == pochakUserLabel || sender.view == contentUserLabel {
            otherUserProfileVC.receivedHandle = viewModel.getPostDetailOwnerHandle()
        }
        
        else if sender.view == recentCommentHandleLabel {
            otherUserProfileVC.receivedHandle = recentCommentHandleLabel.text
        }
        
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    @objc private func showTaggedUsersVC() {
        let taggedUserDetailVC = TaggedUsersDetailViewController()
        taggedUserDetailVC.tagList = viewModel.getPostDetailTaggedUsers()
        
        taggedUserDetailVC.goToOtherProfileVC = { (handle: String) in
            self.dismiss(animated: true)
            guard let otherUserProfileVC = self.profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
            otherUserProfileVC.receivedHandle = handle
            self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        }
        
        let sheet = taggedUserDetailVC.sheetPresentationController
        sheet?.detents = [.medium(), .large()]
        sheet?.prefersGrabberVisible = true
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false

        present(taggedUserDetailVC, animated: true)
    }
    
    @objc private func moreActionButtonDidTap() {
        let postMenuVC = PostMenuViewController()
        postMenuVC.setPostData(postId: receivedPostId!, 
                               postOwner: viewModel.getPostDetailOwnerHandle()!,
                               taggedMemberList: viewModel.getPostDetailTaggedUsers()!.map({ $0.handle }))
        let sheet = postMenuVC.sheetPresentationController
        
        /* 메뉴 개수에 맞도록 sheet 높이 설정 */
        let label = UILabel()
        label.font = UIFont.Pretendard(size: 20, family: .Bold)
        label.text = "더보기"
        label.sizeToFit()
        
        let currentLogInUser = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
        
        let cellCount = (viewModel.getPostDetailOwnerHandle()! == currentLogInUser || viewModel.getPostDetailTaggedUsers()!.contains(where: { $0.handle == currentLogInUser })) ? 3 : 2
        let height = label.frame.height + CGFloat(36 + 16 + 48 * cellCount)
        let fraction = UISheetPresentationController.Detent.custom { context in
            height
        }
        sheet?.detents = [fraction]
        sheet?.prefersGrabberVisible = true
        sheet?.prefersScrollingExpandsWhenScrolledToEdge = false

        present(postMenuVC, animated: true)
    }
    
    /// 댓글 버튼을 눌렀을 때
    @objc private func commentButtonDidTap(_ sender: Any) {
        showCommentVC()
    }
    
    /// 더보기 버튼을 눌렀을 때
    @objc private func moreCommentButtonDidTap(_ sender: Any) {
        showCommentVC()
    }
    
    @objc private func refreshPostDetail() {
        self.viewModel.fetchPostDetail(postId: receivedPostId!, fromCurrentVC: self)
    }
    
    // MARK: - Functions
    
    private func addViews() {
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(usersStackView)
        contentView.addSubview(followButton)
        
        [taggedUsersLabel, usersStackView2].forEach {
            usersStackView.addArrangedSubview($0)
        }
        
        [pochakUserLabel, pochakedTimeLabel].forEach {
            usersStackView2.addArrangedSubview($0)
        }
        
        contentView.addSubview(postImageView)
        
        contentView.addSubview(contentStackView)
        [contentUserLabel, contentLabel].forEach {
            contentStackView.addArrangedSubview($0)
        }
        
        contentView.addSubview(likeAndCmtStackView)
        [likeButton, commentButton].forEach {
            likeAndCmtStackView.addArrangedSubview($0)
        }
        
        contentView.addSubview(borderLineView)
        
        contentView.addSubview(recentCommentStackView)
        [recentCommentHandleLabel, recentCommentCommentLabel].forEach {
            recentCommentStackView.addArrangedSubview($0)
        }
        
        contentView.addSubview(moreCommentButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(17)
        }
        
        usersStackView.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        followButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        postImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(profileImageView.snp.bottom).offset(14)
            make.height.equalTo(postImageView.snp.width).multipliedBy(4.0 / 3.0)
        }
        
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(postImageView.snp.bottom).offset(22)
        }
        
        [likeButton, commentButton].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(48)
                make.width.equalTo(button.snp.height).multipliedBy(1)
            }
        }
        
        likeAndCmtStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(9)
            make.top.equalTo(postImageView.snp.bottom).offset(8)
        }
        
        borderLineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(contentStackView.snp.bottom).offset(24)
            make.height.equalTo(1)
        }
        
        recentCommentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalTo(borderLineView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(34)
        }
        
        moreCommentButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(recentCommentStackView.snp.top)
            make.leading.greaterThanOrEqualTo(recentCommentStackView.snp.trailing).offset(11)
        }
    }
    
    private func setupNavigationBar() {
        // bar button item 추가 (신고하기 메뉴 등)
        let barButton = UIBarButtonItem(image: UIImage(named: "MoreIcon"), style: .plain, target: self, action: #selector(moreActionButtonDidTap))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    private func bind() {
        viewModel.postDetailDataDidChange = { [weak self] data in
            guard let data = data else { return }
            print("== viewmodel ==")
            print(data)
            self?.setupData(data)
        }
        
        viewModel.likeResponseDataDidChange = { [weak self] data in
            guard let data = data else { return }
            print("=== PostDetail, likeBtnTapped succeeded ===")
            print("== data: \(data)")
            if(!data.isSuccess) {
                self?.present(UIAlertController.networkErrorAlert(title: "좋아요에 실패하였습니다."), animated: true)
                return
            }
            self?.likeButton.isSelected.toggle()
            //self?.viewModel.fetchPostDetail(postId: (self?.receivedPostId)!, fromCurrentVC: self!)  // 필요 이상으로 서버 통신하는 것 같아서 그냥 likeButton 상태 toggle하는 것으로 바꿈..
        }
        
        viewModel.followResponseDataDidChange = { [weak self] data in
            guard let data = data else { return }
            print("=== PostDetail, followButtonDidTap succeeded ===")
            print("== data: \(data)")

            if(!data.isSuccess) {
                self?.present(UIAlertController.networkErrorAlert(title: "팔로우 요청에 실패하였습니다."), animated: true)
                return
            }
//            self.viewModel.fetchPostDetail(postId: self.receivedPostId!, fromCurrentVC: self)
            // 필요 이상으로 서버 통신하는 것 같아서 그냥 followButton 상태 toggle하는 것으로 바꿈..
            self?.followButton.isFollowing.toggle()
        }
    }
    
    private func setupData(_ data: PostDetailResponseResult) {
        if let url = URL(string: data.postImage) {
            postImageView.load(with: url)
        }
        
        if let profileUrl = URL(string: data.ownerProfileImage) {
            profileImageView.load(with: profileUrl)
        }
        
        self.navigationItem.title = data.ownerHandle + " 님의 게시물"
        
        var taggedUserList: String = ""
        for taggedUser in data.tagList {
            if(taggedUser.handle == data.tagList.last?.handle) {
                taggedUserList += taggedUser.handle + " 님"
            }
            else {
                taggedUserList += taggedUser.handle + " 님 • "
            }
        }
        self.taggedUsersLabel.text = taggedUserList
        
        self.pochakUserLabel.text = data.ownerHandle + "님이 포착"
        self.contentUserLabel.text = data.ownerHandle
        self.pochakedTimeLabel.text = data.allowedDate.getTimeIntervalOfDateAndNow() + " 전"
        self.contentLabel.text = data.caption
        
        // 댓글 미리보기 -> 있으면 보여주기
        if let recentComment = data.recentComment {
            self.hideCommentViews(isHidden: false)
            self.setCommentViewContents(with: recentComment)
        }
        else {
            self.hideCommentViews(isHidden: true)
        }
        
        self.likeButton.isSelected = data.isLike
        
        // 팔로잉 버튼
        if let isFollow = data.isFollow {
            self.followButton.isHidden = false
            self.followButton.isFollowing = isFollow
        }
        else {
            self.followButton.isHidden = true
        }
    }
    
    private func addGestureRecognizers() {
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        
        contentUserLabel.isUserInteractionEnabled = true
        contentUserLabel.addGestureRecognizer(setGestureRecognizer())
        
        pochakUserLabel.isUserInteractionEnabled = true
        pochakUserLabel.addGestureRecognizer(setGestureRecognizer())
        
        recentCommentHandleLabel.isUserInteractionEnabled = true
        recentCommentHandleLabel.addGestureRecognizer(setGestureRecognizer())
        
        // 태그된 유저 띄우기 위한 제스쳐
        taggedUsersLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTaggedUsersVC)))
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
    
    private func setUpRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPostDetail), for: .valueChanged)
        refreshControl.tintColor = UIColor(named: "navy02")
    }
    
    private func showCommentVC() {
        let commentVC = postStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        
        commentVC.modalPresentationStyle = .pageSheet
        commentVC.postId = receivedPostId
        commentVC.postOwnerHandle = viewModel.getPostDetailOwnerHandle()
        commentVC.taggedUserList = viewModel.getPostDetailTaggedUsers()!.map({ taggedUser in
            taggedUser.handle
        })
        commentVC.postVC = self
        
        if let sheet = commentVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
                
        present(commentVC, animated: true)
    }
    
    /// 댓글이 없을 때는 댓글 관련 뷰를 보여주면 안되므로 + 댓글 버튼의 이미지는 비활성 이미지로
    private func hideCommentViews(isHidden: Bool) {
        borderLineView.isHidden = isHidden
        recentCommentHandleLabel.isHidden = isHidden
        recentCommentCommentLabel.isHidden = isHidden
        moreCommentButton.isHidden = isHidden
        moreCommentButton.isUserInteractionEnabled = !isHidden
        
        // 댓글이 있으면 -> 댓글 버튼 활성화 이미지로 변경
        commentButton.isSelected = isHidden ? false : true
    }
    
    private func setCommentViewContents(with data: RecentComment) {
        recentCommentHandleLabel.text = data.handle
        recentCommentCommentLabel.text = data.content
    }
}

// MARK: - Extension: UIScrollView

extension PostViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
             refreshControl.endRefreshing()
        }
    }
}

// MARK: - Extension: UIGestureRecognizerDelegate

extension PostViewController: UIGestureRecognizerDelegate {

}

// MARK: - Extension: CustomAlertDelegate

extension PostViewController: CustomAlertDelegate {
    func confirmAction() {
        viewModel.requestUserFollow(handle: viewModel.getPostDetailOwnerHandle()!, fromCurrentVC: self)
    }
    
    func cancel() {
        print("취소")
    }
}
