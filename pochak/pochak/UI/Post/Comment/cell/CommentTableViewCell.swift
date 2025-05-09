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
    
    private let currentUserHandle = UserDefaultsManager.getData(type: String.self, forKey: .handle) ?? ""

    // MARK: - Views
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 40 / 2
        return view
    }()
    
    private let commentUserHandleLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3_1)
        return label
    }()
    
    private let timePassedLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body4)
        label.textColor = UIColor(named: "gray04")
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.applyPochakFont(.body3)
        label.numberOfLines = 0
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16
        view.alignment = .fill
        view.distribution = .fillProportionally
        return view
    }()
    
    private let childCommentButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("답글 달기")
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 16

        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font: UIFont.Pretendard(size: 12, family: .Medium),
                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: "gray05"),
                                                                  NSAttributedString.Key.paragraphStyle: style]))
        config.contentInsets = .zero
        button.configuration = config
        button.addTarget(self, action: #selector(childCommentButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("삭제")
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 16

        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font: UIFont.Pretendard(size: 12, family: .Medium),
                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: "gray05"),
                                                                  NSAttributedString.Key.paragraphStyle: style]))
        config.contentInsets = .zero
        button.configuration = config
        button.addTarget(self, action: #selector(deleteButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        
        addViews()
        setupConstraints()
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        
        commentUserHandleLabel.isUserInteractionEnabled = true
        commentUserHandleLabel.addGestureRecognizer(setGestureRecognizer())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        // Configure the view for the selected state
//    }
    
    // MARK: - Actions
    
    @objc private func childCommentButtonDidTap(_ sender: UIButton) {
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
    
    @objc private func deleteButtonDidTap() {
        // FIXME: 페이징 처리랑 같이...
//        CommentService.deleteComment(postId: postId, commentId: commentId) { [weak self] data, failed in
//            guard let data = data else {
//                // 에러가 난 경우, alert 창 present
//                switch failed {
//                case .disconnected:
//                    self?.commentVC?.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription),
//                                             animated: true)
//                default:
//                    self?.commentVC?.present(UIAlertController.networkErrorAlert(title: "댓글 삭제에 실패하였습니다."),
//                                             animated: true)
//                }
//                return
//            }
//            
//            print("=== CommentTableViewCell, deleteButtonDidTap succeeded ===")
//            print("== data: \(data)")
//            
//            if data.isSuccess == true {
//                self?.commentVC?.loadCommentData()
//            }
//            else {
//                self?.commentVC?.present(UIAlertController.networkErrorAlert(title: "댓글 삭제에 실패하였습니다."), 
//                                         animated: true)
//            }
//        }
    }
    
    @objc private func moveToOthersProfile(sender: UITapGestureRecognizer) {
        let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
        
        guard let otherUserProfileVC = profileTabSb.instantiateViewController(withIdentifier: "OtherUserProfileVC") as? OtherUserProfileViewController else { return }
        
        // 댓글 작성자가 현재 유저라면
        if commentUserHandleLabel.text == currentUserHandle {
            otherUserProfileVC.receivedHandle = currentUserHandle
        }
        else {
            otherUserProfileVC.receivedHandle = commentUserHandleLabel.text
        }
        print("post vc의 nav controller: \(self.postVC?.navigationController)")
        self.commentVC?.dismiss(animated: true)
        self.postVC?.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    // MARK: - Functions
    
    private func addViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(commentUserHandleLabel)
        contentView.addSubview(timePassedLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(buttonStackView)
        
        [childCommentButton, deleteButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.top.equalToSuperview().inset(20)
        }
        
        commentUserHandleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.top.equalTo(profileImageView.snp.top)
        }
        
        timePassedLabel.snp.makeConstraints { make in
            make.leading.equalTo(commentUserHandleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(commentUserHandleLabel.snp.centerY)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(commentUserHandleLabel.snp.leading)
            make.top.equalTo(commentUserHandleLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.equalTo(contentLabel.snp.leading)
            make.bottom.equalToSuperview().inset(13)
        }
    }
    
    func setupData(_ comment: UICommentData) {
        // 현재 댓글 아이디 저장
        self.commentId = comment.commentId
        
        // 프로필 이미지
        if let url = URL(string: comment.profileImage) {
            profileImageView.load(with: url)
        }
        
        self.commentUserHandleLabel.text = comment.handle
        self.contentLabel.text = comment.content
        
        /* 게시글의 주인(찍은 사람 + 찍힌 사람들) 혹은 댓글을 작성한 사람이 아닌 경우 삭제 버튼 hide */
        print("댓글 핸들: \(comment.handle), 로그인 유저 핸들: \(currentUserHandle)")

        if(comment.handle == currentUserHandle
           || (postOwnerHandle == currentUserHandle)
           || (taggedUserList?.contains(currentUserHandle))!) {
            print("이 유저는 댓글 삭제가 가능함")
            deleteButton.isHidden = false
        }
        
        // comment.uploadedTime 값: 2023-12-27T19:03:32.701
        // 시간 계산
        self.timePassedLabel.text = comment.createdDate.getTimeIntervalOfDateAndNow()
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
}
