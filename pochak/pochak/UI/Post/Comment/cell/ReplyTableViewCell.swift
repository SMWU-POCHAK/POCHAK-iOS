//
//  ReplyTableViewCell.swift
//  pochak
//
//  Created by Suyeon Hwang on 2023/07/16.
//

import UIKit

final class ReplyTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let identifier = "ReplyTableViewCell"
    
    private let loggedinUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""
    var parentCommentId: Int!
    
    // comment view controller에서 받는 댓글 입력창
    var editingCommentTextField: UITextField!
    var tableView: UITableView!
    var commentVC: CommentViewController!
    var postVC: PostViewController!
    
    // MARK: - Views
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userHandleLabel: UILabel!
    @IBOutlet weak var timePassedLabel: UILabel!
    @IBOutlet weak var replyLabel: UILabel!
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        UIView.animate(withDuration: 0.8, 
                       animations: { self.backgroundColor = UIColor(named: "navy03") },
                       completion: { _ in UIView.animate(withDuration: 0.5) { self.backgroundColor = oldColor }
        })
        editingCommentTextField.becomeFirstResponder()
    }
    
    @objc private func moveToOthersProfile(sender: UITapGestureRecognizer) {
        let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
        
        guard let otherUserProfileVC = profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
        otherUserProfileVC.receivedHandle = userHandleLabel.text
        print("post vc의 nav controller: \(self.postVC?.navigationController)")
        self.commentVC?.dismiss(animated: true)
        self.postVC?.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    // MARK: - Functions
    
    func setupData(_ commentData: UICommentData) {
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
        self.timePassedLabel.text = commentData.createdDate.getTimeIntervalOfDateAndNow()
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
}
