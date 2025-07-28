//
//  CommentTableViewFooterView.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/13/24.
//

import UIKit

final class CommentTableViewFooterView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    static let identifier = "CommentTableViewFooterView"
    
    var commentVC: CommentViewController!
    var postId: Int!
    var curCommentId: Int!
        
    // MARK: - Views
    
    private let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "gray05")
        return view
    }()
    
    private let getChildCommentsButton: UIButton = {
        let button = UIButton()
        
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("이전 답글 보기")
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 16.adjustedH

        config.attributedTitle?.setAttributes(AttributeContainer([NSAttributedString.Key.font: UIFont.Pretendard(size: 12, family: .Medium),
                                                                  NSAttributedString.Key.foregroundColor: UIColor(named: "gray05"),
                                                                  NSAttributedString.Key.paragraphStyle: style]))
        
        button.configuration = config
        button.addTarget(self, action: #selector(getChildCommentsButtonDidTap(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc private func getChildCommentsButtonDidTap(_ sender: UIButton) {
        // 이 액션 함수를 호출한 버튼이 테이블 뷰의 어디에 위치했는지 알아내기
        let point = sender.convert(CGPoint.zero, to: commentVC.tableView) // sender의 좌표계 상의 점을 테이블뷰의 bounds로 변환한 것
        
        // point를 가지고 테이블뷰의 indexPath를 찾기, 찾지 못하면 바로 리턴
        guard let indexPath = commentVC.tableView.indexPathForRow(at: point) else { return } // 매개변수로 받은 point와 연관된 행 및 섹션을 나타내는 indexPath를 반환,point가 테이블뷰의 bounds의 범위에서 벗어난다면 nil

        print("더 보려는 댓글의 섹션: \(indexPath.section)")
        loadChildCommentData(indexPath.section)
        print("---대댓글 보기 버튼 삭제---")
    }
    
    // MARK: - Functions
    
    private func addViews() {
        contentView.addSubview(lineView)
        contentView.addSubview(getChildCommentsButton)
    }
    
    private func setupConstraints() {
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.leading.equalToSuperview().inset(75.adjusted)
            make.width.equalTo(35.adjusted)
            make.centerY.equalToSuperview()
        }
        
        getChildCommentsButton.snp.makeConstraints { make in
            make.centerY.equalTo(lineView.snp.centerY)
            make.leading.equalTo(lineView.snp.trailing).offset(3.adjusted)
        }
    }
    
    // section은 대댓글을 조회하고자 하는 댓글의 섹션 번호
    private func loadChildCommentData(_ section: Int) {
        print("=== load child comment data ===")

        var currentChildCommentFetchingPage = self.commentVC.commentModel.commentDataModelList[section].childCommentPageModel.currentFetchingPage
        print("=====================")
        print("about to getting child comment, page: \(currentChildCommentFetchingPage)")
        print("=====================")
        CommentService.getChildComments(postId: postId, commentId: curCommentId, page: currentChildCommentFetchingPage) { [weak self] data, failed in
            guard let data = data else {
                // 에러가 난 경우, alert 창 present
                switch failed {
                case .disconnected:
                    self?.commentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    self?.commentVC.present(UIAlertController.networkErrorAlert(title: "대댓글 더 불러오기를 실패하였습니다."), animated: true)
                }
                return
            }
            
            guard let self = self else { return }
            
            print("=== CommentTableViewFooterView, loadChildCommentData succeeded ===")
            print("== data: \(data)")
            
            if data.isSuccess == true {
                // 제대로 된 자리에 대댓글 리스트를 삽입하기 위해서 지금까지 있는 대댓글 개수 세야 함
                var childCommentsSoFar = 0
                if(section != 0) {
                    for index in 0...section - 1 {
                        childCommentsSoFar += self.commentVC.commentModel.commentDataModelList[section].childCommentCnt
                    }
                }
                // 대댓글 마지막 페이지 bool값 갱신 -> footer 생성에 관여함
                self.commentVC.commentModel.commentDataModelList[section].childCommentPageModel.isLastPage = data.result.childCommentPageInfo.lastPage
                self.commentVC.commentModel.commentDataModelList[section].childCommentPageModel.currentFetchingPage += 1
                
                // 대댓글 리스트에 새로 받아온 대댓글 추가하기
                print("===========================")
                // 1. 현재 0번째 페이지 가져왔을 경우 현재 자식 댓글 리스트를 removeAll, childCnt도 0으로 세팅한 후
                if self.commentVC.commentModel.commentDataModelList[section].childCommentPageModel.currentFetchingPage - 1 == 0 {
                    self.commentVC.commentModel.commentDataModelList[section].childCommentModelList.removeAll()
                    self.commentVC.commentModel.commentDataModelList[section].childCommentCnt = 0
                    print(">> 현재 page = 0")
                }
                self.commentVC.commentModel.commentDataModelList[section].childCommentCnt += data.result.childCommentList.count
                print("\(section)번째 부모의 자식 댓글 개수: \(self.commentVC.commentModel.commentDataModelList[section].childCommentCnt)")
                // 2. 지금 가져온 자식 댓글을 추가
                self.commentVC.commentModel.commentDataModelList[section].childCommentModelList.append(contentsOf: data.result.childCommentList.map({ data in
                    ChildCommentModel(commentId: data.commentId,
                                      profileImage: data.profileImage,
                                      handle: data.handle,
                                      createdDate: data.createdDate,
                                      content: data.content)
                }))
                
                self.commentVC.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
            }
            else {
                self.commentVC.present(UIAlertController.networkErrorAlert(title: "대댓글 더 불러오기를 실패하였습니다."), animated: true)
            }
        }
    }
}
