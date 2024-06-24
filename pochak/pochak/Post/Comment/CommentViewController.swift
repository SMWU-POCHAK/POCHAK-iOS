//
//  CommentViewController.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/08.
//

import UIKit
import Kingfisher

class CommentViewController: UIViewController {

    // MARK: - Properties
    
    let textViewPlaceHolder = "이 게시물에 댓글을 달아보세요"
    //var loggedinUserHandle: String!  // 현재 로그인된 유저의 아이디
    
    // postVC에서 넘겨주는 값
    var postId: Int?
    var postUserHandle: String?
    
    // 댓글 셀에서 받을 정보
    var isPostingChildComment: Bool = false
    var parentCommentId: Int?
    
    public var childCommentCntList = [Int]()  // 섹션 당 셀 개수 따로 저장해둘 리스트 필요함 (부모 댓글의 자식 댓글 개수 저장)
    
    private var commentDataResponse: CommentDataResponse?
    public var commentDataResult: CommentDataResult?
    private var parentCommentList: [ParentCommentData]?  // 부모댓글 + 자식댓글 있는 list
    
    var uiCommentList = [UICommentData]()  // 셀에 뿌릴 때 사용할 실제 데이터들
    private var tempChildCommentList = [UICommentData]()
    
    private var postCommentResponse: PostCommentResponse?
    
    // MARK: - Views
    
    private var noComment: Bool = true
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
        
        // TODO: UserDefaults에서 현재 로그인된 유저 핸들 가져오기
//        loggedinUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
//        print("current logged in user handle is : \(loggedinUserHandle)")
        
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
    
    // MARK: - Functions
    
    // TODO: 바깥 영역 터치 시 키보드 안 내려가는 문제 해결 필요
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        self.tableView.endEditing(true)
        self.commentView.endEditing(true)
        self.noCommentView.endEditing(true)
        self.commentTextField.endEditing(true)
//        view.resignFirstResponder()
        tableView.keyboardDismissMode = .onDrag
    }
    
    private func loadCommentData(){
        print("postid: \(postId)")
        CommentDataService.shared.getComments(postId!, page: 0) { [weak self] (response) in
            // NetworkResult형 enum으로 분기 처리
            switch(response){
            case .success(let commentDataResponse):
                self?.commentDataResponse = commentDataResponse as? CommentDataResponse
                self?.commentDataResult = (self?.commentDataResponse?.result)!
                self?.parentCommentList = self?.commentDataResult?.parentCommentList  // 데이터로 넘어온 부모 댓글(+자식댓글)리스트

                self?.noComment = true
                self?.uiCommentList.removeAll()
                //self.childCommentCntList.removeAll()
                
                // 댓글 존재할 때만
                if(self?.parentCommentList?.count != 0){
                    self?.noComment = false
                    // 부모 댓글 자체를 부모 댓글인지의 여부가 있는 UICommentData형으로 만들어서 추가
                    for parentData in self?.parentCommentList ?? [] {
                        self?.uiCommentList.append(UICommentData(commentId: parentData.commentId, profileImage: parentData.profileImage, handle: parentData.handle, createdDate: parentData.createdDate, content: parentData.content, isParent: true, parentId: nil))
                        
                        // 부모 댓글의 자식 댓글을 리스트에 추가
                        for childData in parentData.childCommentList {
                            self?.uiCommentList.append(UICommentData(commentId: childData.commentId, profileImage: childData.profileImage, handle: childData.handle, createdDate: childData.createdDate, content: childData.content, isParent: false, parentId: parentData.commentId))
                        }
                    }
                }
                print("=== loading comment data ===")
                print(self?.uiCommentList)
                
                print("=== init ui ===")
                self?.initUI()
                
                // title 내용 설정
                self?.titleLabel.text = (self?.postUserHandle ?? "사용자") + " 님의 게시물 댓글"
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serveErr")
            case .networkFail:
                print("networkFail")
            }
        }
        
    }
    
    private func initUI() {
        // 사용자 프로필 이미지
        if let url = URL(string: (commentDataResult?.loginMemberProfileImage)!) {
            self.userProfileImageView.kf.setImage(with: url) { result in
                switch result {
                case .success(let value):
                    print("Image successfully loaded: \(value.image)")
                case .failure(let error):
                    print("Image failed to load with error: \(error.localizedDescription)")
                }
            }
        }
        
        if noComment {
            noCommentView.isHidden = false
        }
        else {
            noCommentView.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    private func setUpTableView(){
        print("=== setting up table view ===")
        // tableView의 프로토콜
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none  // cell 간 구분선 스타일
        
        // tableView가 자동으로 셀 컨텐츠 내용 계산해서 높이 맞추도록
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 90
        
        // 여러 개의 셀 선택 안되도록 설정
        tableView.allowsMultipleSelection = false
        
        // nib은 CommentTableViewCell << 이 파일임
        let commentNib = UINib(nibName: "CommentTableViewCell", bundle: nil)
        tableView.register(commentNib, forCellReuseIdentifier: "CommentTableViewCell")  // tableview에 이 cell을 등록
        
        // 테이블뷰에 ReplyTableViewCell 등록
        let replyNib = UINib(nibName: "ReplyTableViewCell", bundle: nil)
        tableView.register(replyNib, forCellReuseIdentifier: "ReplyTableViewCell")
        
        // 테이블뷰에 footer view nib 등록
        tableView.register(UINib(nibName: "CommentTableViewFooterView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommentTableViewFooterView")
        
        // 댓글이 없을 때의 셀
        tableView.register(UINib(nibName: "NoCommentTableViewCell", bundle: nil), forCellReuseIdentifier: "NoCommentTableViewCell")
        
        print("=== tableview setup done ===")
    }
    
    public func toUICommentData(){
        self.uiCommentList.removeAll()
        
        for parentData in self.parentCommentList ?? [] {
            self.uiCommentList.append(UICommentData(commentId: parentData.commentId, profileImage: parentData.profileImage, handle: parentData.handle, createdDate: parentData.createdDate, content: parentData.content, isParent: true, parentId: nil))
            
            // 부모 댓글의 자식 댓글을 리스트에 추가
            for childData in parentData.childCommentList {
                self.uiCommentList.append(UICommentData(commentId: childData.commentId, profileImage: childData.profileImage, handle: childData.handle, createdDate: childData.createdDate, content: childData.content, isParent: false, parentId: parentData.commentId))
            }
        }
    }
    
    // 키보드 보여질 때
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo as NSDictionary?,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
            }
        // 키보드의 높이
        // let keyboardHeight = keyboardFrame.size.height
        // 댓글 입력 View 높이
        // let commentViewHeight = commentView.frame.height

        // 댓글입력view의 bottom constraint를 키보드 높이만큼 (홈버튼 없는 아이폰?)
        //CommentInputViewBottomConstraint.constant = keyboardHeight - self.view.safeAreaInsets.bottom
        // 스크롤뷰 오프셋을 키보드높이+댓글입력view 로 설정해서 스크롤뷰 내용이 다 보일 수 있도록
        //tableView.contentOffset.y = keyboardHeight + commentViewHeight
        
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
    
    // MARK: - Actions
    
    @IBAction func postNewCommentBtnTapped(_ sender: UIButton) {
        let commentContent = commentTextField.text ?? ""
        
        // 대댓글인지 댓글인지 확인해야 함
        print(commentContent)
        
        // 댓글 내용이 있는 경우에만 POST 요청
        if commentContent != "" {
            // 임시로 parentCommentSK는 nil로 지정
            CommentDataService.shared.postComment(postId!, commentContent, self.isPostingChildComment ? self.parentCommentId : nil) { (response) in
                switch(response){
                case .success(let data):
                    self.postCommentResponse = (data as! PostCommentResponse)
                    // 만약 실패한 경우 실패했다고 알림창
                    if(self.postCommentResponse?.isSuccess == false){
                        let alert = UIAlertController(title: "댓글 등록에 실패하였습니다.", message: "다시 시도해주세요.", preferredStyle: UIAlertController.Style.alert)
                        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
                        alert.addAction(action)
                        self.present(alert, animated: true)
                    }
                    print("=== 새 댓글 등록, 데이터 업데이트 ===")
                    self.loadCommentData()
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
        else{
            print("textview is empty")
        }
        
        // 댓글창 비우기
        commentTextField.text = ""
        
        // 키보드 내리기
        commentTextField.endEditing(true)
        
        // 댓글 종류 초기화
        self.isPostingChildComment = false
    }
}

// MARK: - Extensions (TableView)

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    // 마지막 섹션은 인디케이터로 해야하는디..
    // 일단 부모 댓글의 개수만큼 섹션 생성
    func numberOfSections(in tableView: UITableView) -> Int {
        return noComment ? 0 : parentCommentList!.count
    }
    
    // 한 섹션에 몇 개의 셀을 넣을지 -> 각 부모댓글의 자식댓글 개수 + 1(부모댓글 자신)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noComment ? 0 : parentCommentList![section].childCommentList.count + 1
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
                //childCommentsSoFar += self.childCommentCntList[index]
                childCommentsSoFar += self.parentCommentList![index].childCommentList.count
            }
        }
            
        var finalIndex = section + indexPath.row + childCommentsSoFar
        print("=== finalIndex: \(finalIndex)")
        print("=== 현재 셀에 그리는 데이터 ===")
        print(cellData[finalIndex])
        
        // 부모 댓글인 경우
        if cellData[finalIndex].isParent {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell else{
                return UITableViewCell()
            }
            cell.editingCommentTextField = self.commentTextField
            cell.tableView = self.tableView
            cell.commentVC = self
            cell.setupData(cellData[finalIndex])
            return cell
        }
        // 자식 댓글인 경우
        else{
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyTableViewCell", for: indexPath)
                    as? ReplyTableViewCell else{
                return UITableViewCell()
            }
            cell.editingCommentTextField = self.commentTextField
            cell.tableView = self.tableView
            cell.commentVC = self
            cell.setupData(cellData[finalIndex])
            return cell
        }
    }
    
    // 더 보여줄 대댓글이 있을 때 대댓글 더보기 버튼이 있는 footer
    // footer cell 등록, 보여주기
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                      "CommentTableViewFooterView") as! CommentTableViewFooterView
        // footer에게 CommentViewController 전달
        footerView.commentVC = self
        footerView.postId = self.postId


        if let cellData = self.parentCommentList {
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
        else{
            return nil
        }
    }
    
    // TableView의 rowHeight속성에 AutometicDimension을 통해 테이블의 row가 유동적이라는 것을 선언
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // 현재는 cell의 높이가 고정되어 있기 때문에 제대로 안 보임 -> height 다시 설정
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        // 스토리 테이블뷰 셀의 높이
//        if indexPath.row == 0 {
//            return 80
//        }
//        // 피드 테이블뷰 셀의 높이
//        else{
//            return 600
//        }
//    }
    
    // 이상한 여백 제거?
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let cellData = self.parentCommentList {
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
