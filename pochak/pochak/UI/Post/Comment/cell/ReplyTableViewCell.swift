//
//  ReplyTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/16.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let identifier = "ReplyTableViewCell"
    
    var loggedinUserHandle: String?
    var deleteButton = UIButton()
    var parentCommentId: Int!
    
    // MARK: - Views
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var timePassedLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!

    // comment view controller에서 받는 댓글 입력창
    var editingCommentTextField: UITextField!
    var tableView: UITableView!
    var commentVC: CommentViewController!
    var postVC: PostViewController!
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 현재 로그인된 유저 핸들 가져오기
        loggedinUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle)
        
        // 이미지뷰 반만큼 radius 적용 -> 동그랗게
        profileImageView.layer.cornerRadius = 36 / 2
        
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        userHandleLabel.addGestureRecognizer(setGestureRecognizer())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func postChildCmmtBtnDidTap(_ sender: UIButton) {
        // 현재 대댓글 등록 중임을 comment view controller에 알려야 함
        commentVC.isPostingChildComment = true
        commentVC.parentCommentId = self.parentCommentId
        
        let indexPath = tableView.indexPath(for: self)
        // 답글을 다려는 셀을 맨 위로 이동
        tableView.scrollToRow(at: indexPath!, at: .top, animated: true)
        
        // fade in, fade out 으로 색상 변경 
        let oldColor = self.backgroundColor
        UIView.animate(withDuration: 0.8, animations: {
            self.backgroundColor = UIColor(named: "navy03")
            }, completion: { _ in
                UIView.animate(withDuration: 0.5) {
                    self.backgroundColor = oldColor
                }
        })
        editingCommentTextField.becomeFirstResponder()
    }
    
    // MARK: - Helpers
    
    func setupData(_ commentData: UICommentData){
        // 부모 댓글 아이디 저장
        parentCommentId = commentData.parentId
        
        // 프로필 이미지
        if let url = URL(string: commentData.profileImage) {
            profileImageView.load(with: url)
        }
        
        // 유저 핸들
        userHandleLabel.text = commentData.handle
        
        replyLabel.text = commentData.content
        
        // comment.uploadedTime 값: 2023-12-27T19:03:32.701
        // 시간 계산
        let arr = commentData.createdDate.split(separator: "T")  // T를 기준으로 자름, ["2023-12-27", "19:03:32.701"]
        let timeArr = arr[arr.endIndex - 1].split(separator: ".")  // ["19:03:32", "701"]
        
        let uploadedTime = arr[arr.startIndex] + " " + timeArr[timeArr.startIndex]
        
        // 현재 시간
        let currentTime = Date()
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startTime = format.date(from: String(uploadedTime))!
        //let startStr = format.string(from: startTime!)
        let endStr = format.string(from: currentTime)
        let endTime = format.date(from: endStr)
        
        let timePassed = Int(endTime!.timeIntervalSince(startTime))  // 초단위 리턴
        // 초
        if(timePassed >= 0 && timePassed < 60){
            self.timePassedLabel.text = String(timePassed) + "초"
        }
        // 분
        else if(timePassed >= 60 && timePassed < 3600){
            self.timePassedLabel.text = String(timePassed / 60) + "분"
        }
        // 시
        else if(timePassed >= 3600 && timePassed < 24*60*60){
            self.timePassedLabel.text = String(timePassed / 3600) + "시간"
        }
        
        // 일
        else if(timePassed >= 24*60*60 && timePassed < 7*24*60*60){
            self.timePassedLabel.text = String(timePassed/(24*60*60)) + "일"
        }
        
        // 주
        else{
            self.timePassedLabel.text = String(timePassed / (7*24*60*60)) + "주"
        }
    }
    
    @objc private func moveToOthersProfile(sender: UITapGestureRecognizer) {
        print("move to other's profile")
        print(sender.view)
        
        let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
        
        guard let otherUserProfileVC = profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
        otherUserProfileVC.recievedHandle = userHandleLabel.text
        print("post vc의 nav controller: \(self.postVC?.navigationController)")
        self.commentVC?.dismiss(animated: true)
        self.postVC?.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
}
