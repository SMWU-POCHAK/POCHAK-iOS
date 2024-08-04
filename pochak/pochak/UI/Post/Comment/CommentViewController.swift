//
//  CommentViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/08.
//

import UIKit
import Kingfisher

final class CommentViewController: UIViewController {

    // MARK: - Properties
    
    let textViewPlaceHolder = "이 게시물에 댓글을 달아보세요"
    
    // postVC에서 넘겨주는 값
    var postId: Int?
    var postOwnerHandle: String?
    var taggedUserList: [String]?
    weak var postVC: PostViewController?
    
    // 댓글 셀에서 받을 정보
    var isPostingChildComment: Bool = false
    var parentCommentId: Int?
    
    public var childCommentCntList = [Int]()  // 섹션 당 셀 개수 따로 저장해둘 리스트 필요함 (부모 댓글의 자식 댓글 개수 저장)
    public var parentAndChildCommentList: [ParentCommentData]?  // 부모댓글 + 자식댓글 있는 list
    public var uiCommentList = [UICommentData]()  // 셀에 뿌릴 때 사용할 실제 데이터들
    
    private var postCommentResponse: PostCommentResponse?
    private var profileImageUrl: String = ""
    private var noComment: Bool = true
    
    // MARK: - Views

    @IBOutlet weak var CommentInputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var noCommentView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 테이블 뷰 세팅
        setUpTableView()
        
        /* Keyboard 보여지고 숨겨질 때 발생되는 이벤트 등록 */
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
        
        // 사용자 프로필 사진 크기 반만큼 radius
        userProfileImageView.layer.cornerRadius = 40 / 2
        
        // 댓글 데이터 조회
        loadCommentData()
    }
    
    // MARK: - Actions
    
    @IBAction func postNewCommentBtnTapped(_ sender: UIButton) {
        let commentContent = commentTextField.text ?? ""
        
        // 대댓글인지 댓글인지 확인해야 함
        print(commentContent)
        
        // 댓글 내용이 있는 경우에만 POST 요청
        if commentContent != "" {
            // 임시로 parentCommentSK는 nil로 지정
            CommentDataService.shared.postComment(postId!, commentContent, self.isPostingChildComment ? self.parentCommentId : nil) { response in
                switch(response) {
                case .success(let data):
                    self.postCommentResponse = (data as! PostCommentResponse)
                    // 만약 실패한 경우 실패했다고 알림창
                    if(self.postCommentResponse?.isSuccess == false){
                        self.present(UIAlertController.networkErrorAlert(title: "댓글 등록에 실패하였습니다."), animated: true)
                        return
                    }
                    else {
                        print("=== 새 댓글 등록, 데이터 업데이트 ===")
                        self.loadCommentData()
                    }
                case .requestErr(let message):
                    print("requestErr", message)
                case .pathErr:
                    print("pathErr")
                case .serverErr:
                    print("serverErr")
                    self.present(UIAlertController.networkErrorAlert(title: "서버에 문제가 있습니다."), animated: true)
                case .networkFail:
                    print("networkFail")
                    self.present(UIAlertController.networkErrorAlert(title: "네트워크 연결에 문제가 있습니다."), animated: true)
                }
            }
        }
        else {
            print("textview is empty")
        }
        
        // 댓글창 비우기
        commentTextField.text = ""
        
        // 키보드 내리기
        commentTextField.endEditing(true)
        
        // 댓글 종류 초기화
        self.isPostingChildComment = false
    }
    
    // MARK: - Functions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.commentTextField.endEditing(true)
    }
    
    func loadCommentData() {
        print("postid: \(postId)")
        CommentDataService.shared.getComments(postId!, page: 0) { [weak self] response in
            // NetworkResult형 enum으로 분기 처리
            switch(response) {
            case .success(let commentDataResponse):
                let response = commentDataResponse as? CommentDataResponse
                if response?.isSuccess == true {
                    let result = response?.result as? CommentDataResult
                    self?.parentAndChildCommentList = result?.parentCommentList  // 데이터로 넘어온 부모 댓글(+자식댓글)리스트
                    self?.profileImageUrl = result!.loginMemberProfileImage
                    self?.noComment = true
                    self?.uiCommentList.removeAll()
                    
                    // 댓글 존재할 때만
                    if(self?.parentAndChildCommentList?.count != 0) {
                        self?.noComment = false
                        // 부모 댓글 자체를 부모 댓글인지의 여부가 있는 UICommentData형으로 만들어서 추가
                        for parentData in self?.parentAndChildCommentList ?? [] {
                            self?.uiCommentList.append(UICommentData(commentId: parentData.commentId, 
                                                                     profileImage: parentData.profileImage,
                                                                     handle: parentData.handle,
                                                                     createdDate: parentData.createdDate,
                                                                     content: parentData.content,
                                                                     isParent: true,
                                                                     parentId: nil))
                            // childCommentCntList[몇번째 부모] = 해당 부모의 자식 댓글 개수
                            self?.childCommentCntList.append(parentData.childCommentList.count)
                            
                            // 부모 댓글의 자식 댓글을 리스트에 추가
                            for childData in parentData.childCommentList {
                                self?.uiCommentList.append(UICommentData(commentId: childData.commentId, 
                                                                         profileImage: childData.profileImage,
                                                                         handle: childData.handle,
                                                                         createdDate: childData.createdDate,
                                                                         content: childData.content,
                                                                         isParent: false,
                                                                         parentId: parentData.commentId))
                            }
                        }
                    }
                    print("=== loading comment data ===")
                    print(self?.uiCommentList)
                    
                    print("=== init ui ===")
                    self?.initUI()
                    
                    // title 내용 설정
                    self?.titleLabel.text = (self?.postOwnerHandle ?? "사용자") + " 님의 게시물 댓글"
                }
                else {
                    self?.present(UIAlertController.networkErrorAlert(title: "요청에 실패했습니다."), animated: true)
                }
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
                self?.present(UIAlertController.networkErrorAlert(title: "서버에 문제가 있습니다."), animated: true)
            case .networkFail:
                print("networkFail")
                self?.present(UIAlertController.networkErrorAlert(title: "네트워크 연결에 문제가 있습니다."), animated: true)
            }
        }
    }
    
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
    }
    
    private func setUpTableView() {
        // tableView의 프로토콜
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none  // cell 간 구분선 스타일
        
        // tableView가 자동으로 셀 컨텐츠 내용 계산해서 높이 맞추도록
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        
        tableView.allowsMultipleSelection = false
        
        // 키보드 내릴 수 있게
        tableView.keyboardDismissMode = .onDrag
        
        // nib은 CommentTableViewCell << 이 파일임
        let commentNib = UINib(nibName: CommentTableViewCell.identifier, bundle: nil)
        tableView.register(commentNib, forCellReuseIdentifier: CommentTableViewCell.identifier)
        
        // 테이블뷰에 ReplyTableViewCell 등록
        let replyNib = UINib(nibName: ReplyTableViewCell.identifier, bundle: nil)
        tableView.register(replyNib, forCellReuseIdentifier: ReplyTableViewCell.identifier)
        
        // 테이블뷰에 footer view nib 등록
        tableView.register(UINib(nibName: CommentTableViewFooterView.identifier, bundle: nil),
                           forHeaderFooterViewReuseIdentifier: CommentTableViewFooterView.identifier)
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
            self.CommentInputViewBottomConstraint.constant = finalHeight
            self.view.layoutIfNeeded()
        }
    }

    // 키보드 숨겨질 때 -> 원래 상태로
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        let animationDuration = notification.userInfo![ UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
                
        UIView.animate(withDuration: animationDuration) {
            self.CommentInputViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Extension: UITableView

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 마지막 섹션은 인디케이터로 해야하는디.. 일단 부모 댓글의 개수만큼 섹션 생성
    func numberOfSections(in tableView: UITableView) -> Int {
        return noComment ? 0 : parentAndChildCommentList!.count
    }
    
    // 한 섹션에 몇 개의 셀을 넣을지 -> 각 부모댓글의 자식댓글 개수 + 1(부모댓글 자신)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noComment ? 0 : parentAndChildCommentList![section].childCommentList.count + 1
    }
    
    // 어떤 셀을 보여줄지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cellData = self.uiCommentList
        
        // 셀을 그리기 위해 인덱스를 계산 해야 함
        var childCommentsSoFar = 0
        if(section != 0){
            for index in 0...section - 1 {
                childCommentsSoFar += self.parentAndChildCommentList![index].childCommentList.count
            }
        }
            
        var finalIndex = section + indexPath.row + childCommentsSoFar
        print("=== finalIndex: \(finalIndex)")
        print("=== 현재 셀에 그리는 데이터 ===")
        print(cellData[finalIndex])
        
        // 부모 댓글인 경우
        if cellData[finalIndex].isParent {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as? CommentTableViewCell else { return UITableViewCell() }
            cell.editingCommentTextField = self.commentTextField
            cell.tableView = self.tableView
            cell.commentVC = self
            cell.postVC = self.postVC
            cell.postId = self.postId
            cell.taggedUserList = self.taggedUserList
            cell.postOwnerHandle = self.postOwnerHandle
            cell.setupData(cellData[finalIndex])
            return cell
        }
        // 자식 댓글인 경우
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReplyTableViewCell.identifier, for: indexPath)
                    as? ReplyTableViewCell else { return UITableViewCell() }
            cell.editingCommentTextField = self.commentTextField
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

        if let cellData = self.parentAndChildCommentList {
            // 현재 부모댓글의 자식 댓글들이 last page가 아니면 footer 추가
            if !cellData[section].childCommentPageInfo.lastPage {
                //footerView.backgroundColor = .blue
                footerView.curCommentId = cellData[section].commentId
                return footerView
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    // TableView의 rowHeight속성에 AutometicDimension을 통해 테이블의 row가 유동적이라는 것을 선언
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 이상한 여백 제거?
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let cellData = self.parentAndChildCommentList {
            // 자식 댓글이 마지막 페이지이면 여백 없애기
            if cellData[section].childCommentPageInfo.lastPage {
                return .leastNonzeroMagnitude
            }
        }
        return UITableView.automaticDimension
    }
    
    // grouped 스타일 테이블뷰이기 때문에 자동 생성되는 헤더 높이를 0으로
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}
