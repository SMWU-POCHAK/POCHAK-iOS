//
//  CommentTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/10.
//

import UIKit

final class CommentTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "CommentTableViewCell"
    
    weak var postVC: PostViewController?
    weak var commentVC: CommentViewController?
    var commentId: Int!
    var postId: Int!
    var taggedUserList: [String]?
    var postOwnerHandle: String?
    
    // comment view controller에서 받는 댓글 입력창
    var editingCommentTextField: UITextField!
    var tableView: UITableView!
    
    let seeChildCommentBtn = UIButton()
    
    private let currentUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)

    // MARK: - Views
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var commentUserHandleLabel: UILabel!
    @IBOutlet weak var timePassedLabel: UILabel!
    @IBOutlet weak var childCommentBtn: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 크기 반만큼 radius
        profileImageView.layer.cornerRadius = 40 / 2
        
        // TODO: 사용자 프로필로 이동..
        // label이 터치 인식할 수 있도록 gesture recognizer 추가
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        
        commentUserHandleLabel.isUserInteractionEnabled = true
        commentUserHandleLabel.addGestureRecognizer(setGestureRecognizer())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func postChildCmmtBtnDidTap(_ sender: UIButton) {
        // 부모 댓글을 단다는 것을 comment vc에 알려야 함
        commentVC?.isPostingChildComment = true
        commentVC?.parentCommentId = self.commentId
        
        let indexPath = tableView.indexPath(for: self)
        // 답글을 다려는 셀을 맨 위로 이동
        tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
        
        // fade in, fade out 으로 색상 변경 
        let oldColor = self.backgroundColor
        UIView.animate(withDuration: 0.9, 
                       animations: { self.backgroundColor = UIColor(named: "navy03") },
                       completion: { _ in UIView.animate(withDuration: 0.5) { self.backgroundColor = oldColor } }
        )
        editingCommentTextField.becomeFirstResponder()
    }
    
    @IBAction func deleteButtonDidTap() {
        CommentDataService.shared.deleteComment(postId: self.postId, commentId: self.commentId) { [weak self] result in
            switch result {
            case .success(let data):
                print("댓글 삭제 성공, data: \(data as! DeleteCommentResponse)")
                let data = data as! DeleteCommentResponse
                if data.isSuccess == true {
                    self?.commentVC?.loadCommentData()
                }
                else {
                    self?.commentVC?.present(UIAlertController.networkErrorAlert(title: "댓글 삭제에 실패하였습니다."), animated: true)
                }
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
                self?.commentVC?.present(UIAlertController.networkErrorAlert(title: "서버에 문제가 있습니다."), animated: true)
            case .networkFail:
                print("networkFail")
                self?.commentVC?.present(UIAlertController.networkErrorAlert(title: "네트워크 연결에 문제가 있습니다."), animated: true)
            }
        }
    }
    
    @objc private func moveToOthersProfile(sender: UITapGestureRecognizer) {
        print("move to other's profile")
        print(sender.view)
        
        let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
        
        // 댓글 작성자가 현재 유저라면
        if commentUserHandleLabel.text == currentUserHandle {
            self.commentVC?.tabBarController?.selectedIndex = 4
        }
        else {
            guard let otherUserProfileVC = profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
            otherUserProfileVC.recievedHandle = commentUserHandleLabel.text
            print("post vc의 nav controller: \(self.postVC?.navigationController)")
            self.commentVC?.dismiss(animated: true)
            self.postVC?.navigationController?.pushViewController(otherUserProfileVC, animated: true)
        }
    }
    
    // MARK: - Functions
    
    func setupData(_ comment: UICommentData) {
        // 현재 댓글 아이디 저장
        self.commentId = comment.commentId
        
        // 프로필 이미지
        if let url = URL(string: comment.profileImage) {
            profileImageView.load(with: url)
        }
        
        self.commentUserHandleLabel.text = comment.handle
        self.commentLabel.text = comment.content
        
        /* 게시글의 주인(찍은 사람 + 찍힌 사람들) 혹은 댓글을 작성한 사람이 아닌 경우 삭제 버튼 hide */
        print("댓글 핸들: \(comment.handle), 로그인 유저 핸들: \(currentUserHandle)")

        if(comment.handle == currentUserHandle
           || (postOwnerHandle == currentUserHandle)
           || (taggedUserList?.contains(currentUserHandle!))!) {
            print("이 유저는 댓글 삭제가 가능함")
            deleteButton.isHidden = false
        }
        
        // comment.uploadedTime 값: 2023-12-27T19:03:32.701
        // 시간 계산
        let arr = comment.createdDate.split(separator: "T")  // T를 기준으로 자름, ["2023-12-27", "19:03:32.701"]
        let timeArr = arr[arr.endIndex - 1].split(separator: ".")  // ["19:03:32", "701"]
        
        let uploadedTime = arr[arr.startIndex] + " " + timeArr[timeArr.startIndex]
        
        // 현재 시간
        let currentTime = Date()
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startTime = format.date(from: String(uploadedTime))!
        let endStr = format.string(from: currentTime)
        let endTime = format.date(from: endStr)
        
        let timePassed = Int(endTime!.timeIntervalSince(startTime))  // 초단위 리턴
        // 초
        if(timePassed >= 0 && timePassed < 60) {
            self.timePassedLabel.text = String(timePassed) + "초"
        }
        // 분
        else if(timePassed >= 60 && timePassed < 3600) {
            self.timePassedLabel.text = String(timePassed / 60) + "분"
        }
        // 시
        else if(timePassed >= 3600 && timePassed < 24 * 60 * 60) {
            self.timePassedLabel.text = String(timePassed / 3600) + "시간"
        }
        
        // 일
        else if(timePassed >= 24 * 60 * 60 && timePassed < 7 * 24 * 60 * 60) {
            self.timePassedLabel.text = String(timePassed/(24 * 60 * 60)) + "일"
        }
        
        // 주
        else {
            self.timePassedLabel.text = String(timePassed / (7 * 24 * 60 * 60)) + "주"
        }
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
}
