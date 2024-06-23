//
//  PostViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/04.
//

import UIKit

class PostViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postOwnerHandleLabel: UILabel!
    @IBOutlet weak var postContent: UILabel!
    @IBOutlet weak var taggedUsers: UILabel!
    @IBOutlet weak var pochakUser: UILabel!
    
    @IBOutlet weak var borderLineView: UIView!
    @IBOutlet weak var commentUserHandleLabel: UILabel!
    @IBOutlet weak var commentContentLabel: UILabel!
    @IBOutlet weak var moreCommentButton: UIButton!
    
    var receivedPostId: Int?
    //var currentPostId: Int!//= "POST%23eb472472-97ea-40ab-97e7-c5fdf57136a0"
    var postOwnerHandle: String = ""  // 나중에 여기저기에서 사용할 수 있도록.. 미리 게시자 아이디 저장
    
    let pullDownMenuBtn = UIButton()
    
    private var isFollowingColor: UIColor = UIColor(named: "gray03") ?? UIColor(hexCode: "FFB83A")
    private var isNotFollowingColor: UIColor = UIColor(named: "yellow00") ?? UIColor(hexCode: "C6CDD2")
    
    private var postDataResponse: PostDataResponse!
    private var postDataResult: PostDataResponseResult!
    
    private var likePostResponse: LikePostDataResponse!
    
    private var followPostResponse: FollowDataResponse!
    
    private var deletePostResponse: PostDeleteResponse!
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: 로그인된 유저가 게시글의 소유자인 경우에만 실행하도록 고치기
        //let loggedinUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
        //if(loggedinUserHandle == postOwnerHandle){
//            setupPullDownMenu()
        // 내비게이션 바에 오른쪽 아이템 추가 (ellipsis)
        
        
        /* 1번만 해도 되는 초기화들.. */
        // 크기에 맞게
        scrollView.updateContentSize()
        
        // 네비게이션 바 밑줄 없애기
        self.navigationController?.navigationBar.standardAppearance.shadowColor = .white  // 스크롤하지 않는 상태
        self.navigationController?.navigationBar.scrollEdgeAppearance?.shadowColor = .white  // 스크롤하고 있는 상태

        // back button 커스텀
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        let backbutton = UIBarButtonItem(image: UIImage(named: "ChevronLeft"), style: .done, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backbutton

        // left bar button을 추가하면 기존에 되던 스와이프 pop 기능이 해제됨
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // bar button item 추가 (신고하기 메뉴 등)
        let barButton = UIBarButtonItem(image: UIImage(named: "MoreIcon"), style: .plain, target: self, action: #selector(moreActionButtonDidTap))
        self.navigationItem.rightBarButtonItem = barButton
        
        // 프로필 사진 동그랗게 -> 크기 반만큼 radius
        profileImageView.layer.cornerRadius = 25
        
//        // 좋아요 누른 사람 수 라벨에 대한 제스쳐 등록 -> 액션 연결
//        let howManyLikesLabelGesture = UITapGestureRecognizer(target: self, action: #selector(showPeopleWhoLiked))
//        labelHowManyLikes.addGestureRecognizer(howManyLikesLabelGesture)
        
        // 다른 프로필로 이동하는 제스쳐 등록 -> 액션 연결
        // 프로필 사진, 유저 핸들 모두에 등록
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        postOwnerHandleLabel.isUserInteractionEnabled = true
        postOwnerHandleLabel.addGestureRecognizer(setGestureRecognizer())
        pochakUser.isUserInteractionEnabled = true
        pochakUser.addGestureRecognizer(setGestureRecognizer())
        
        self.followingBtn.setTitleColor(UIColor.white, for: [.normal, .selected])
        self.followingBtn.setTitle("팔로우", for: .normal)
        self.followingBtn.setTitle("팔로잉", for: .selected)
        followingBtn.layer.cornerRadius = 4.97
        
        /*postId 전달 - 실시간인기포스트에서 전달하는 postId 입니다
        전달되는 id 없으면 위에서 설정된 id로 될거에요..
        나중에 홈에서도 id 이렇게 전달해서 쓰면 될 것 같습니다 ㅎㅎ */
        if let data = receivedPostId {
            // receivedData를 사용하여 원하는 작업을 수행합니다.
            // 예를 들어, 데이터를 표시하거나 다른 로직에 활용할 수 있습니다.
            print("Received Data: \(data)")
            //currentPostId = data
            //currentPostId = 2  // 임시로 2로 저장
        } else {
            print("No data received.")
        }
        
        loadPostDetailData()
    }
    
    // MARK: - Helpers
    
    private func initUI(){
        // 크키에 맞게
//        scrollView.updateContentSize()
        
        // 포스트 이미지
        let url = URL(string: postDataResult.postImage)
        // main thread에서 load할 경우 URL 로딩이 길면 화면이 멈춘다.
        // 이를 방지하기 위해 다른 thread에서 처리함.
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url!) {
                if let image = UIImage(data: data) {
                    //UI 변경 작업은 main thread에서 해야함.
                    DispatchQueue.main.async {
                        self?.postImage.image = image
                    }
                }
            }
        }
        
        // 프로필 이미지
        let profileUrl = URL(string: postDataResult.ownerProfileImage)
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: profileUrl!) {
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self?.profileImageView.image = image
                    }
                }
            }
        }
        
        // 내비게이션 바 타이틀 세팅
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Pretendard-bold", size: 20)!]
        self.navigationItem.title = postDataResult.ownerHandle+" 님의 게시물"
        
        // 태그된 사용자, 포착한 사용자
        self.taggedUsers.text = ""
        for handle in postDataResult.taggedMemberHandle {
            if(handle == postDataResult.taggedMemberHandle.last){
                self.taggedUsers.text! += handle + " 님"
            }
            else{
                self.taggedUsers.text! += handle + " 님 • "
            }
        }
        // 태그된 사용자에 프로필 이동 제스쳐 등록하기
    //        let arr = taggedUsers.text?.split(separator: " • ")  // T를 기준으로 자름, ["2023-12-27", "19:03:32.701"]
    //        print(arr)
        self.pochakUser.text = postDataResult.ownerHandle + "님이 포착"
        
        // 포스트 내용
        self.postOwnerHandleLabel.text = postDataResult.ownerHandle
        self.postContent.text = postDataResult.caption
        
        
        // 댓글 미리보기 -> 있으면 보여주기
        if(postDataResult.recentComment == nil){
            self.hideCommentViews(isHidden: true)
        }
        else{
            self.hideCommentViews(isHidden: false)
            self.setCommentViewContents()
        }
        
        // 좋아요 버튼 (내가 눌렀는지 안했는지)
        self.likeButton.isSelected = postDataResult.isLike
        
        // 좋아요 누른 사람 수
//        self.labelHowManyLikes.text = "\(postDataResult.likeCount)명"
        
        // 팔로잉 버튼
        //self.isFollowing = postDataResult.isFollow
        if(self.postDataResult.isFollow == nil){
            self.followingBtn.isHidden = true
        }
        else{
            self.followingBtn.isHidden = false
            self.followingBtn.isSelected = postDataResult.isFollow!
            self.followingBtn.backgroundColor = postDataResult.isFollow! ? self.isFollowingColor : self.isNotFollowingColor
        }
    }
    
    func loadPostDetailData(){
        PostDataService.shared.getPostDetail(receivedPostId!) { (response) in
            // NetworkResult형 enum으로 분기 처리
            switch(response){
            case .success(let postData):
                self.postDataResponse = postData as? PostDataResponse
                self.postDataResult = self.postDataResponse.result
                self.postOwnerHandle = self.postDataResult.ownerHandle
                self.initUI()
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        
        return moveToOthersProfile
    }
    
    private func showCommentVC() {
        let storyboard = UIStoryboard(name: "PostTab", bundle: nil)
        let commentVC = storyboard.instantiateViewController(withIdentifier: "CommentVC") as! CommentViewController
        
        commentVC.modalPresentationStyle = .pageSheet
        commentVC.postId = receivedPostId
        commentVC.postUserHandle = postDataResult.ownerHandle
        
        // half sheet
        if let sheet = commentVC.sheetPresentationController {
            //지원할 크기 지정
            sheet.detents = [.medium(), .large()]
            //크기 변하는거 감지
            sheet.delegate = self
                   
            //시트 상단에 그래버 표시 (기본 값은 false)
            sheet.prefersGrabberVisible = true
                    
            //처음 크기 지정 (기본 값은 가장 작은 크기)
            //sheet.selectedDetentIdentifier = .large
                    
            //뒤 배경 흐리게 제거 (기본 값은 모든 크기에서 배경 흐리게 됨)
            //sheet.largestUndimmedDetentIdentifier = .medium
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
        if !isHidden {
            commentButton.setImage(UIImage(named: "CommentFilledIcon"), for: .normal)
        }
    }
    
    private func setCommentViewContents() {
        commentUserHandleLabel.text = postDataResult.recentComment?.handle
        commentContentLabel.text = postDataResult.recentComment?.content
    }
       
    // MARK: - Actions
    
    @IBAction func followingBtnTapped(_ sender: Any) {
        FollowDataService.shared.postFollow(postOwnerHandle) { response in
            switch(response) {
            case .success(let followData):
                self.followPostResponse = followData as? FollowDataResponse
                if(!self.followPostResponse.isSuccess){
                    let alert = UIAlertController(title: "요청에 실패하였습니다.", message: "다시 시도해주세요.", preferredStyle: UIAlertController.Style.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                }
                // 바뀐 데이터 반영 위해 다시 포스트 상세 데이터 로드
                self.loadPostDetailData()
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
//    @objc func showPeopleWhoLiked(sender: UITapGestureRecognizer){
//        let storyboard = UIStoryboard(name: "PostTab", bundle: nil)
//        let postLikesVC = storyboard.instantiateViewController(withIdentifier: "PostLikesVC") as! PostLikesViewController
//        
//        postLikesVC.postId = self.receivedPostId
//        postLikesVC.postOwnerHandle = self.postDataResult.ownerHandle
//        postLikesVC.modalPresentationStyle = .pageSheet
//        // 좋아요 누른 사람 페이지에 포스트 아이디, 포스트 게시자 아이디 전달
//        
//        
//        // half sheet
//        if let sheet = postLikesVC.sheetPresentationController {
//            //지원할 크기 지정
//            sheet.detents = [.medium(), .large()]
//            //크기 변하는거 감지
//            sheet.delegate = self
//            //시트 상단에 그래버 표시 (기본 값은 false)
//            sheet.prefersGrabberVisible = true
//        }
//        
//        present(postLikesVC, animated: true)
//    }

    @IBAction func likeBtnTapped(_ sender: Any) {
        LikedUsersDataService.shared.postLikeRequest(receivedPostId!){(response) in
            switch(response){
            case .success(let likePostResponse):
                self.likePostResponse = likePostResponse as? LikePostDataResponse
                if(!self.likePostResponse.isSuccess!){
                    // 인스턴스 생성
                    let alert = UIAlertController(title: "알림", message: "좋아요가 반영되지 못했습니다.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    print(self.likePostResponse.message)
                    return
                }
                print(self.likePostResponse.message)
                //self.btnLike.isSelected.toggle()
                self.loadPostDetailData()
                
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
            case .networkFail:
                print("networkFail")
            }
        }
    }
    
    // 프로필 이미지나 아이디 클릭 시 해당 사용자 프로필로 이동
    @objc func moveToOthersProfile(sender: UITapGestureRecognizer){
        print("move to other's profile")
//        let storyboard = UIStoryboard(name: "ProfileTab", bundle: nil)
//        let profileTabVC = storyboard.instantiateViewController(withIdentifier: "ProfileTabVC") as! ProfileTabViewController
//        
//        self.navigationController?.pushViewController(profileTabVC, animated: true)
        //commentVC.postId = tempPostId
        //commentVC.postUserHandle = postDataResult.postOwnerHandle
        
        
        //postVC.receivedData = imageArray[indexPath.item].partitionKey!.replacingOccurrences(of: "#", with: "%23")
        
        //present(profileTabVC, animated: true)
    }
    
    @objc func moreActionButtonDidTap(){
        let storyboard = UIStoryboard(name: "PostTab", bundle: nil)
        let postMenuVC = storyboard.instantiateViewController(withIdentifier: "PostMenuVC") as! PostMenuViewController
        postMenuVC.setPostIdAndOwner(postId: receivedPostId!, postOwner: postOwnerHandle)
        let sheet = postMenuVC.sheetPresentationController
        //postMenuVC.modalPresentationStyle = .pageSheet
        
        /* 메뉴 개수에 맞도록 sheet 높이 설정 */
        let label = UILabel()
        label.font = UIFont(name: "Pretendard-Bold", size: 20)
        label.text = "더보기"
        label.sizeToFit()
        
        let cellCount = (postOwnerHandle == APIConstants.dayeonHandle) ? 3 : 2
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
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
}


// MARK: - Extensions

extension ViewController: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        //크기 변경 됐을 경우
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}

extension UIScrollView {
    func updateContentSize() {
        let unionCalculatedTotalRect = recursiveUnionInDepthFor(view: self)
        
        // 계산된 크기로 컨텐츠 사이즈 설정
        self.contentSize = CGSize(width: self.frame.width, height: unionCalculatedTotalRect.height+50)
    }
    
    private func recursiveUnionInDepthFor(view: UIView) -> CGRect {
        var totalRect: CGRect = .zero
        
        // 모든 자식 View의 컨트롤의 크기를 재귀적으로 호출하며 최종 영역의 크기를 설정
        for subView in view.subviews {
            totalRect = totalRect.union(recursiveUnionInDepthFor(view: subView))
        }
        
        // 최종 계산 영역의 크기를 반환
        return totalRect.union(view.frame)
    }
}

extension PostViewController: UIGestureRecognizerDelegate {

}
