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
    //var postOwnerHandle: String = ""  // 게시글 주인 핸들 저장
    
    private let postStoryBoard = UIStoryboard(name: "ExploreTab", bundle: nil)
    private let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
    private let refreshControl = UIRefreshControl()
        
    private var postDataResult: PostDetailResponseResult?
        
    private var deletePostResponse: PostDeleteResponse!
        
    // MARK: - Views
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postOwnerHandleLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var taggedUsersLabel: UILabel!
    @IBOutlet weak var pochakUserLabel: UILabel!
    
    @IBOutlet weak var borderLineView: UIView!
    @IBOutlet weak var commentUserHandleLabel: UILabel!
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var moreCommentButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        self.navigationController?.isNavigationBarHidden = false
        
        initUI()
        
        /*postId 전달 - 실시간인기포스트에서 전달하는 postId 입니다
        전달되는 id 없으면 위에서 설정된 id로 될거에요..
        나중에 홈에서도 id 이렇게 전달해서 쓰면 될 것 같습니다 ㅎㅎ */
        if let data = receivedPostId {
            print("Received Data: \(data)")
        } else {
            print("No data received.")
        }
        
        loadPostDetailData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Actions
    
    @IBAction func followingBtnTapped(_ sender: Any) {
        if let isFollow = postDataResult?.isFollow! {
            if isFollow {
                showAlert(alertType: .confirmAndCancel,
                          titleText: "팔로우를 취소할까요?",
                          cancelButtonText: "취소",
                          confirmButtonText: "확인")
            }
            else {
                postFollowRequest()
            }
        }
    }

    @IBAction func likeBtnTapped(_ sender: Any) {
        PostService.postLikePost(postId: receivedPostId!) { [weak self] data, failed in
            guard let data = data else {
                // 에러가 난 경우, alert 창 present
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), 
                                  animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "좋아요에 실패하였습니다."), animated: true)
                }
                return
            }
            
            print("=== PostDetail, likeBtnTapped succeeded ===")
            print("== data: \(data)")
            
            if(!data.isSuccess) {
                self?.present(UIAlertController.networkErrorAlert(title: "좋아요에 실패하였습니다."), animated: true)
                return
            }
            self?.loadPostDetailData()
        }
    }
    
    // 프로필 이미지나 아이디 클릭 시 해당 사용자 프로필로 이동
    @objc func moveToOthersProfile(sender: UITapGestureRecognizer) {
        guard let otherUserProfileVC = profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
        
        if sender.view == profileImageView || sender.view == pochakUserLabel || sender.view == postOwnerHandleLabel {
            otherUserProfileVC.receivedHandle = postDataResult?.ownerHandle
        }
        
        else if sender.view == commentUserHandleLabel {
            otherUserProfileVC.receivedHandle = commentUserHandleLabel.text
        }
        
        self.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    @objc func showTaggedUsersVC() {
        let taggedUserDetailVC = postStoryBoard.instantiateViewController(withIdentifier: "TaggedUsersDetailVC") as! TaggedUsersDetailViewController
        taggedUserDetailVC.tagList = postDataResult?.tagList
        
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
    
    @objc func moreActionButtonDidTap() {
        let postMenuVC = postStoryBoard.instantiateViewController(withIdentifier: "PostMenuVC") as! PostMenuViewController
        postMenuVC.setPostData(postId: receivedPostId!, 
                               postOwner: postDataResult!.ownerHandle,
                               taggedMemberList: postDataResult!.tagList.map({ $0.handle }))
        let sheet = postMenuVC.sheetPresentationController
        
        /* 메뉴 개수에 맞도록 sheet 높이 설정 */
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.text = "더보기"
        label.sizeToFit()
        
        let currentLogInUser = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
        
        let cellCount = (postDataResult?.ownerHandle == currentLogInUser || postDataResult!.tagList.contains(where: { $0.handle == currentLogInUser })) ? 3 : 2
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
    @IBAction func commentButtonDidTap(_ sender: Any) {
        showCommentVC()
    }
    
    /// 더보기 버튼을 눌렀을 때
    @IBAction func moreCommentButtonDidTap(_ sender: Any) {
        showCommentVC()
    }
    
    @objc func refreshPostDetail() {
        loadPostDetailData()
    }
    
    // MARK: - Functions
    
    private func setupNavigationBar() {
        // bar button item 추가 (신고하기 메뉴 등)
        let barButton = UIBarButtonItem(image: UIImage(named: "MoreIcon"), style: .plain, target: self, action: #selector(moreActionButtonDidTap))
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    /// ui 요소들 속성 초기화
    private func initUI() {
        scrollView.updateContentSize()
        
        scrollView.delegate = self
        scrollView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshPostDetail), for: .valueChanged)
        refreshControl.tintColor = UIColor(named: "navy02")
        
        profileImageView.layer.cornerRadius = 25
        
        // 다른 프로필로 이동하는 제스쳐 등록
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        
        postOwnerHandleLabel.isUserInteractionEnabled = true
        postOwnerHandleLabel.addGestureRecognizer(setGestureRecognizer())
        
        pochakUserLabel.isUserInteractionEnabled = true
        pochakUserLabel.addGestureRecognizer(setGestureRecognizer())
        
        commentUserHandleLabel.isUserInteractionEnabled = true
        commentUserHandleLabel.addGestureRecognizer(setGestureRecognizer())
        
        // 태그된 유저 띄우기 위한 제스쳐
        taggedUsersLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTaggedUsersVC)))
        
        followingButton.setTitleColor(UIColor.white, for: [.normal, .selected])
        followingButton.setTitle("팔로우", for: .normal)
        followingButton.setTitle("팔로잉", for: .selected)
        followingButton.layer.cornerRadius = 4.97
    }
    
    private func setupData() {
        if let url = URL(string: postDataResult!.postImage) {
            postImageView.load(with: url)
        }
        
        if let profileUrl = URL(string: postDataResult!.ownerProfileImage) {
            profileImageView.load(with: profileUrl)
        }
        
        self.navigationItem.title = postDataResult!.ownerHandle + " 님의 게시물"
        
        // 태그된 사용자, 포착한 사용자
        self.taggedUsersLabel.text = ""
        
        for taggedUser in postDataResult!.tagList {
            if(taggedUser.handle == postDataResult?.tagList.last?.handle) {
                self.taggedUsersLabel.text! += taggedUser.handle + " 님"
            }
            else {
                self.taggedUsersLabel.text! += taggedUser.handle + " 님 • "
            }
        }
        
        if let ownerHandle = postDataResult?.ownerHandle {
            self.pochakUserLabel.text = ownerHandle + "님이 포착"
            self.postOwnerHandleLabel.text = ownerHandle
        }
        
        // 포스트 내용
        if let caption = postDataResult?.caption {
            self.postContentLabel.text = caption
        }
        
        // 댓글 미리보기 -> 있으면 보여주기
        if let recentComment = postDataResult?.recentComment {
            self.hideCommentViews(isHidden: false)
            self.setCommentViewContents()
        }
        else {
            self.hideCommentViews(isHidden: true)
        }
        
        if let isLike = postDataResult?.isLike {
            self.likeButton.isSelected = isLike
        }
        
        // 팔로잉 버튼
        if let isFollow = postDataResult?.isFollow {
            self.followingButton.isHidden = false
            self.followingButton.isSelected = isFollow
            self.followingButton.backgroundColor = isFollow ? UIColor(named: "gray03") : UIColor(named: "yellow00")
        }
        else {
            self.followingButton.isHidden = true
        }
    }
    
    /// 게시글 상세 데이터 조회하기
    func loadPostDetailData() {
        PostService.getPostDetail(postId: receivedPostId!) { [weak self] data, failed in
            guard let data = data else {
                // 에러가 난 경우, alert 창 present
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription),
                                  animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "게시글 조회에 실패하였습니다."), animated: true)
                }
                return
            }
            
            print("=== PostDetail, loadPostDetailData succeeded ===")
            print("== data: \(data)")
            
            self?.postDataResult = data.result
            self?.setupData()
        }
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
    
    private func showCommentVC() {
        let commentVC = postStoryBoard.instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        
        commentVC.modalPresentationStyle = .pageSheet
        commentVC.postId = receivedPostId
        commentVC.postOwnerHandle = postDataResult?.ownerHandle
        commentVC.taggedUserList = postDataResult!.tagList.map({ taggedUser in
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
        commentUserHandleLabel.isHidden = isHidden
        commentContentLabel.isHidden = isHidden
        moreCommentButton.isHidden = isHidden
        moreCommentButton.isUserInteractionEnabled = !isHidden
        
        // 댓글이 있으면 -> 댓글 버튼 활성화 이미지로 변경
        commentButton.isSelected = isHidden ? false : true
    }
    
    private func setCommentViewContents() {
        commentUserHandleLabel.text = postDataResult?.recentComment?.handle
        commentContentLabel.text = postDataResult?.recentComment?.content
    }
    
    private func postFollowRequest() {
        UserService.postFollowRequest(handle: postDataResult!.ownerHandle) { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    self?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), 
                                  animated: true)
                default:
                    self?.present(UIAlertController.networkErrorAlert(title: "팔로우 요청에 실패하였습니다."), animated: true)
                }
                return
            }
            
            print("=== PostDetail, postFollowRequest succeeded ===")
            print("== data: \(data)")
            
            if(!data.isSuccess) {
                self?.present(UIAlertController.networkErrorAlert(title: "팔로우 요청에 실패하였습니다."), animated: true)
                return
            }
            self?.loadPostDetailData()
        }
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
        postFollowRequest()
    }
    
    func cancel() {
        print("취소")
    }
}
