//
//  CommentViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/08.
//

import UIKit
import Kingfisher

struct CommentVCPageInfo {
    var isLastPage: Bool
    var isFetchingFirstPage: Bool
    var currentFetchingPage: Int
}

final class CommentViewController: UIViewController {
    
    // MARK: - Properties
    
    let textViewPlaceHolder = "이 게시물에 댓글을 달아보세요"
    
    // postVC에서 넘겨주는 값
    var postId: Int?
    var postOwnerHandle: String?
    var taggedUserList: [String]?
    weak var postVC: PostViewController?
    
    // 댓글 셀에서 받을 정보
    var isPostingChildComment: Bool = false {
        didSet {
            configureCommentWritingStatusView()
        }
    }
    var parentCommentId: Int?
    
    var commentPageInfo: CommentVCPageInfo = .init(isLastPage: false, isFetchingFirstPage: true, currentFetchingPage: 0)  // 부모댓글 페이징 정보
    public var childCommentCntList = [Int]()  // 섹션 당 셀 개수 따로 저장해둘 리스트 필요함 (부모 댓글의 자식 댓글 개수 저장)
    public var childCommentPageInfo: [CommentVCPageInfo] = []  // 각 부모댓글의 자식댓글들의 page에 대한 정보를 담는 배열
    public var parentAndChildCommentList: [ParentCommentData] = []  // 부모댓글 + 자식댓글 있는 list
    public var uiCommentList = [UICommentData]()  // 셀에 뿌릴 때 사용할 실제 데이터들
    
    private var profileImageUrl: String = ""
    private var noComment: Bool = true
    private var hasScrolled: Bool = false
    private var isCurrentlyFetching: Bool = false
    private var selectedCommentCellIndexPath: IndexPath = .init(row: 0, section: 0)
    private let commentWritingStatusViewHeight: CGFloat = 21
    
    let viewModel = CommentViewModel()
    
    // MARK: - Views
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "POCHAK 님의 게시물 댓글"
        label.applyPochakFont(.body0)
        return label
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none  // cell 간 구분선 스타일
        
        // tableView가 자동으로 셀 컨텐츠 내용 계산해서 높이 맞추도록
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 90
        
        view.allowsMultipleSelection = false
        view.allowsSelectionDuringEditing = false
        
        // 키보드 내릴 수 있게
        view.keyboardDismissMode = .onDrag
        
        view.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        view.register(ReplyTableViewCell.self, forCellReuseIdentifier: ReplyTableViewCell.identifier)
        view.register(CommentTableViewFooterView.self, forHeaderFooterViewReuseIdentifier: CommentTableViewFooterView.identifier)
        return view
    }()
    
    private let noCommentView: UIView = UIView()
    
    private let noCommentImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "NoCommentIcon")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let noCommentLabel: UILabel = {
        let label = UILabel()
        label.text = "게시물 댓글이 없습니다."
        label.applyPochakFont(.body3)
        label.textColor = UIColor(named: "gray04")
        return label
    }()
    
    private let commentInputView: UIView = UIView()
    
    private let userProfileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 40 / 2
        return view
    }()
    
    private let inputInnerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(named: "gray03")?.cgColor
        return view
    }()
    
    private let commentWritingStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "yellow01")
        return view
    }()
    
    private let commentWritingStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "@Float2_y님에게 답글 남기는 중"
        label.font = .Pretendard(size: 10, family: .Regular)
        return label
    }()
    
    private let stopChildCommentModeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ExtraSmallXIcon"), for: .normal)
        button.addTarget(self, action: #selector(stopChildCommentModeButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "이 게시물에 댓글을 달아보세요."
        tf.clearButtonMode = .never
        tf.borderStyle = .none
        tf.contentHorizontalAlignment = .left
        tf.contentVerticalAlignment = .center
        tf.font = UIFont.Pretendard(size: 14, family: .Regular)
        return tf
    }()
    
    private let uploadButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "CommentUploadIcon")
        config.baseBackgroundColor = UIColor(named: "yellow00")
        config.contentInsets = .init(top: 4, leading: 10, bottom: 4, trailing: 10)
        config.background.cornerRadius = 18
        
        button.configuration = config
        button.addTarget(self, action: #selector(uploadCommentButtonDidTap), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        bind()
        
        addViews()
        setupConstraints()
        addTapGestureTableView()
        addKeyboardObserver()
        
        commentWritingStatusView.isHidden = true
        configureCommentWritingStatusView()
        
        // 댓글 데이터 조회
        guard let postId = postId else { return }
        isCurrentlyFetching = true
        viewModel.fetchCommentData(postId: postId, page: commentPageInfo.currentFetchingPage, fromCurrentVC: self)
    }
    
    // MARK: - Actions
    
    @objc private func tableViewDidTap() {
        print("==== \(#function) ====")
        self.isPostingChildComment = false  // 다른 곳을 터치해서 입력창을 내렸을 때 답글 달기 상태 취소
        self.textField.endEditing(true)
        self.tableView.cellForRow(at: selectedCommentCellIndexPath)?.contentView.backgroundColor = .white
    }
    
    // 키보드 보여질 때
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        // 홈 버튼 없는 아이폰들은 다 빼줘야함. (키보드 높이 - ....?)
        let finalHeight = keyboardFrame.size.height - self.view.safeAreaInsets.bottom

        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        // 키보드 올라오는 애니메이션이랑 동일하게 텍스트뷰 올라가게 만들기.
        UIView.animate(withDuration: animationDuration) {
            self.commentInputView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(finalHeight)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드 숨겨질 때 -> 원래 상태로
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        let animationDuration = notification.userInfo![ UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval

        UIView.animate(withDuration: animationDuration) {
            self.commentInputView.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func stopChildCommentModeButtonDidTap() {
        print("[CommentVC] 답글 남기기 취소")
        self.isPostingChildComment = false
    }
    
    @objc private func uploadCommentButtonDidTap() {
        let commentContent = textField.text ?? ""
        guard let postId = postId else { return }

        // 대댓글인지 댓글인지 확인해야 함
        print(commentContent)

        if commentContent != "" {
            viewModel.uploadNewComment(postId: postId, content: commentContent, parentCommentId: self.isPostingChildComment ? self.parentCommentId : nil, fromCurrentVC: self)
        }
        else {
            print("textview is empty")
        }

        // 댓글창 비우기
        textField.text = ""

        // 키보드 내리기
        textField.endEditing(true)

        // 댓글 종류 초기화
        self.isPostingChildComment = false
    }
    
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("======= \(#function) ========")
        self.isPostingChildComment = false
        self.view.endEditing(true)
        self.textField.endEditing(true)
        self.tableView.cellForRow(at: selectedCommentCellIndexPath)?.contentView.backgroundColor = .white
    }
    
    private func bind() {
        viewModel.commentDataDidChange = { [weak self] data in
            guard let data = data else { return }
            guard let self = self else { return }
            self.commentPageInfo.isLastPage = data.parentCommentPageInfo.lastPage
            self.setupData(data, fetchedMoreComments: !self.commentPageInfo.isFetchingFirstPage)
        }
        
        viewModel.uploadCommentResponseDataDidChange = { [weak self] data in
            guard let self = self else { return }
            self.commentPageInfo.currentFetchingPage = 0
            self.commentPageInfo.isFetchingFirstPage = true
            self.viewModel.fetchCommentData(postId: postId!, page: 0, fromCurrentVC: self)
        }
    }
    
    private func addViews() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(noCommentView)
        noCommentView.addSubview(noCommentImageView)
        noCommentView.addSubview(noCommentLabel)
        
        view.addSubview(commentInputView)
        commentInputView.addSubview(userProfileImageView)
        commentInputView.addSubview(inputInnerView)
        inputInnerView.addSubview(commentWritingStatusView)
        inputInnerView.addSubview(textField)
        inputInnerView.addSubview(uploadButton)
        commentWritingStatusView.addSubview(commentWritingStatusLabel)
        commentWritingStatusView.addSubview(stopChildCommentModeButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(38)
            make.centerX.equalToSuperview()
        }
        
        noCommentView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        noCommentImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        noCommentLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(noCommentImageView.snp.bottom).offset(24)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
        }
        
        // - commentInputView
        // -- user profile image view
        // -- inputInnerView
        // --- commentwritingstatus view
        // ---- comment writing status label
        // ---- x button
        // --- textfield
        // --- upload button
        commentInputView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        userProfileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(40)
        }
        
        inputInnerView.snp.makeConstraints { make in
            make.leading.equalTo(userProfileImageView.snp.trailing).offset(9)
            make.trailing.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        commentWritingStatusView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(commentWritingStatusViewHeight)
        }
        commentWritingStatusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(5)
            make.bottom.equalToSuperview().inset(4)
        }
        stopChildCommentModeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(13)
            make.centerY.equalTo(commentWritingStatusLabel.snp.centerY)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(11)
            make.bottom.equalToSuperview().inset(9)
            make.height.equalTo(22)
            make.trailing.equalTo(uploadButton.snp.leading).offset(-9)
        }
        uploadButton.snp.makeConstraints { make in
            make.top.equalTo(commentWritingStatusView.snp.bottom).offset(7)
            make.bottom.equalToSuperview().inset(7)
            make.width.equalTo(36)
            make.height.equalTo(24)
            make.trailing.equalToSuperview().inset(7)
        }
        uploadButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func addTapGestureTableView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewDidTap))
        tapGesture.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGesture)
    }
    
    /// 키보드 관련된 이벤트 등록
    private func addKeyboardObserver() {
        NotificationCenter.default.addObserver(  // 키보드 보여질 때
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(  // 키보드 숨겨질 때
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    // fetchedMoreComments는 0페이지 다음을 조회했는지 여부를 담은 bool 변수
    func setupData(_ data: CommentDataResult, fetchedMoreComments: Bool) {
        // page = 0 조회했을 때 - 댓글입력창의 프로필 이미지 세팅, 지금껏 쌓아온 uiCommentList 모두 초기화해야 함
        if !fetchedMoreComments {
            self.profileImageUrl = data.loginMemberProfileImage
            self.noComment = true
            self.parentAndChildCommentList.removeAll()
            self.uiCommentList.removeAll()
        }
        self.parentAndChildCommentList.append(contentsOf: data.parentCommentList)  // 데이터로 넘어온 부모 댓글(+자식댓글)리스트
        
        // 댓글 존재할 때만
        if self.parentAndChildCommentList.count != 0 {
            self.noComment = false
            // 부모 댓글을 부모 댓글인지의 여부를 담는 변수가 있는 UICommentData형으로 만들어서 추가
            for newParentData in data.parentCommentList {
                self.uiCommentList.append(UICommentData(commentId: newParentData.commentId,
                                                         profileImage: newParentData.profileImage,
                                                         handle: newParentData.handle,
                                                         createdDate: newParentData.createdDate,
                                                         content: newParentData.content,
                                                         isParent: true,
                                                         parentId: nil))
                // childCommentCntList[몇번째 부모] = 해당 부모의 자식 댓글 개수
                self.childCommentCntList.append(newParentData.childCommentList.count)
                
                // 부모 댓글의 자식 댓글을 리스트에 추가
                for childData in newParentData.childCommentList {
                    self.uiCommentList.append(UICommentData(commentId: childData.commentId,
                                                             profileImage: childData.profileImage,
                                                             handle: childData.handle,
                                                             createdDate: childData.createdDate,
                                                             content: childData.content,
                                                             isParent: false,
                                                             parentId: newParentData.commentId))
                }
            }
        }
        
        self.initUI()
        
        self.titleLabel.text = (self.postOwnerHandle ?? "사용자") + " 님의 게시물 댓글"
    }
    
    func configureCommentWritingStatusView() {
        self.commentWritingStatusView.isHidden = !isPostingChildComment
        self.commentWritingStatusView.snp.updateConstraints { make in
            make.height.equalTo(isPostingChildComment ? commentWritingStatusViewHeight : 0)
        }
    }
    
    // MARK: - Functions
    
    private func initUI() {
        if let url = URL(string: profileImageUrl) {
            userProfileImageView.load(with: url)
        }
        
        if noComment {
            noCommentView.isHidden = false
        }
        else {
            noCommentView.isHidden = true
        }
        self.tableView.reloadData()
        self.isCurrentlyFetching = false
    }
    
    public func toUICommentData() {
        self.uiCommentList.removeAll()
        
        for parentData in self.parentAndChildCommentList ?? [] {
            self.uiCommentList.append(UICommentData(commentId: parentData.commentId,
                                                    profileImage: parentData.profileImage,
                                                    handle: parentData.handle,
                                                    createdDate: parentData.createdDate,
                                                    content: parentData.content,
                                                    isParent: true,
                                                    parentId: nil))
            
            // 부모 댓글의 자식 댓글을 리스트에 추가
            for childData in parentData.childCommentList {
                self.uiCommentList.append(UICommentData(commentId: childData.commentId,
                                                        profileImage: childData.profileImage,
                                                        handle: childData.handle,
                                                        createdDate: childData.createdDate,
                                                        content: childData.content,
                                                        isParent: false,
                                                        parentId: parentData.commentId))
            }
        }
    }
}
    
// MARK: - Extension: UITableView

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 섹션의 개수 = 부모 댓글 개수
    func numberOfSections(in tableView: UITableView) -> Int {
        return noComment ? 0 : parentAndChildCommentList.count
    }
    
    // 한 섹션 당 셀의 개수 = 1(부모댓글 자기 자신) + 그 부모댓글의 자식댓글 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noComment ? 0 : parentAndChildCommentList[section].childCommentList.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cellData = self.uiCommentList
        
        // 셀을 그리기 위해 인덱스를 계산 해야 함
        var childCommentsSoFar = 0
        if(section != 0) {
            for index in 0...section - 1 {
                childCommentsSoFar += self.parentAndChildCommentList[index].childCommentList.count
            }
        }
        
        let finalIndex = section + indexPath.row + childCommentsSoFar
        
        // 부모 댓글인 경우
        if cellData[finalIndex].isParent {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
            cell.editingCommentTextField = self.textField
            cell.tableView = self.tableView
            cell.commentVC = self
            cell.postVC = self.postVC
            cell.postId = self.postId
            cell.taggedUserList = self.taggedUserList
            cell.postOwnerHandle = self.postOwnerHandle
            cell.setupData(cellData[finalIndex])
            cell.childCommentButtonDidTapClosure = { [weak self] in
                self?.selectedCommentCellIndexPath = indexPath
            }
            return cell
        }
        // 자식 댓글인 경우
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReplyTableViewCell.identifier, for: indexPath)
                    as? ReplyTableViewCell else { return UITableViewCell() }
            cell.editingCommentTextField = self.textField
            cell.tableView = self.tableView
            cell.commentVC = self
            cell.postVC = self.postVC
            cell.setupData(cellData[finalIndex])
            return cell
        }
    }
    
    // 더 보여줄 대댓글이 있을 때 대댓글 더보기 버튼이 있는 footer
    // footer cell 등록, 보여주기
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: CommentTableViewFooterView.identifier) as! CommentTableViewFooterView
        // footer에게 CommentViewController 전달
        footerView.commentVC = self
        footerView.postId = self.postId
        
        // 현재 부모댓글의 자식 댓글들이 last page가 아니면 footer 추가
        if !self.parentAndChildCommentList[section].childCommentPageInfo.lastPage {
            //footerView.backgroundColor = .blue
            footerView.curCommentId = self.parentAndChildCommentList[section].commentId
            return footerView
        }
        else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // TableView의 rowHeight속성에 AutometicDimension을 통해 테이블의 row가 유동적이라는 것을 선언
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 이상한 여백 제거?
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.parentAndChildCommentList[section].childCommentPageInfo.lastPage {
            return .leastNonzeroMagnitude
        }
        return UITableView.automaticDimension
    }
    
    // grouped 스타일 테이블뷰이기 때문에 자동 생성되는 헤더 높이를 0으로
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 초기 offset이 설정된 후에만 처리하도록 조건 추가
        if !hasScrolled && scrollView.contentOffset.y == 0 {
            return // 초기 설정이 끝난 후 스크롤이 시작되었을 때만 처리
        }
        
        if scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) {
            if !commentPageInfo.isLastPage && !isCurrentlyFetching {
                print("[!] CommentViewController - NEEDS TO RE-FETCH DATA")
                self.commentPageInfo.currentFetchingPage += 1
                self.commentPageInfo.isFetchingFirstPage = false
                self.isCurrentlyFetching = true
                viewModel.fetchCommentData(postId: self.postId!, page: commentPageInfo.currentFetchingPage, fromCurrentVC: self)
            }
        }
    }
}
