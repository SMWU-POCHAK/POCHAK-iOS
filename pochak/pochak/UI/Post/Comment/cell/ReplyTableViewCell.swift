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
    
    var parentCommentId: Int!
    
    // comment view controller에서 받는 댓글 입력창
    var editingCommentTextField: UITextField!
    var tableView: UITableView!
    var commentVC: CommentViewController!
    var postVC: PostViewController!
    
    // MARK: - Views
    
    private let profileImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 36 / 2
        return view
    }()
    
    private let userHandleLabel: UILabel = {
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
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addViews()
        setupConstraints()
        
        profileImageView.addGestureRecognizer(setGestureRecognizer())
        userHandleLabel.addGestureRecognizer(setGestureRecognizer())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func moveToOthersProfile(sender: UITapGestureRecognizer) {
        let profileTabSb = UIStoryboard(name: "ProfileTab", bundle: nil)
        
        let otherUserProfileVC = OtherUserProfileViewController()
        otherUserProfileVC.receivedHandle = userHandleLabel.text
        print("post vc의 nav controller: \(self.postVC?.navigationController)")
        self.commentVC?.dismiss(animated: true)
        self.postVC?.navigationController?.pushViewController(otherUserProfileVC, animated: true)
    }
    
    // MARK: - Functions
    
    private func addViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(userHandleLabel)
        contentView.addSubview(timePassedLabel)
        contentView.addSubview(contentLabel)
    }
    
    private func setupConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.leading.equalToSuperview().inset(72)
            make.top.equalToSuperview().inset(13)
        }
        
        userHandleLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.top.equalTo(profileImageView.snp.top)
        }
        
        timePassedLabel.snp.makeConstraints { make in
            make.leading.equalTo(userHandleLabel.snp.trailing).offset(5)
            make.centerY.equalTo(userHandleLabel.snp.centerY)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(userHandleLabel.snp.leading)
            make.top.equalTo(userHandleLabel.snp.bottom).offset(7)
            make.trailing.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(13)
        }
    }
    
    func setupData(data commentData: ChildCommentModel, parent parentId: Int) {
        // 부모 댓글 아이디 저장
        parentCommentId = parentId
        
        // 프로필 이미지
        if let url = URL(string: commentData.profileImage) {
            profileImageView.load(with: url)
        }
        
        // 유저 핸들
        userHandleLabel.text = commentData.handle
        
        contentLabel.text = commentData.content
        
        // comment.uploadedTime 값: 2023-12-27T19:03:32.701
        self.timePassedLabel.text = commentData.createdDate.getTimeIntervalOfDateAndNow()
    }
    
    private func setGestureRecognizer() -> UITapGestureRecognizer {
        let moveToOthersProfile = UITapGestureRecognizer(target: self, action: #selector(moveToOthersProfile))
        return moveToOthersProfile
    }
}
