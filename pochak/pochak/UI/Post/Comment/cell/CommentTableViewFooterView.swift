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
    
    private var currentFetchingPage: Int = 0
    
    // MARK: - Views
    
    @IBOutlet weak var seeChildCommentsBtn: UIButton!
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    // MARK: - Actions
    
    @IBAction func seeChildCommentsBtnDidTap(_ sender: UIButton) {
        print("---대댓글 보기 버튼 눌림---")
        // 이 액션 함수를 호출한 버튼이 테이블 뷰의 어디에 위치했는지 알아내기
        let point = sender.convert(CGPoint.zero, to: commentVC.tableView) // sender의 좌표계 상의 점을 테이블뷰의 bounds로 변환한 것
        
        // point를 가지고 테이블뷰의 indexPath를 찾기, 찾지 못하면 바로 리턴
        guard let indexPath = commentVC.tableView.indexPathForRow(at: point) else { return } // 매개변수로 받은 point와 연관된 행 및 섹션을 나타내는 indexPath를 반환,point가 테이블뷰의 bounds의 범위에서 벗어난다면 nil

        //tableView.deleteRows(at: [indexPath], with: .automatic) //4
        print("더 보려는 댓글의 섹션: \(indexPath.section)")
        loadChildCommentData(indexPath.section)
        print("---대댓글 보기 버튼 삭제---")
    }
    
    // MARK: - Functions
    
    // section은 대댓글을 조회하고자 하는 댓글의 섹션 번호
    private func loadChildCommentData(_ section: Int) {
        print("=== load child comment data ===")
        currentFetchingPage += 1
        
        CommentService.getChildComments(postId: postId, commentId: curCommentId, page: currentFetchingPage) { [weak self] data, failed in
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
            
            print("=== CommentTableViewFooterView, loadChildCommentData succeeded ===")
            print("== data: \(data)")
            
            if data.isSuccess == true {
//                childCommentDataList = self.childCommentDataResponse?.result.childCommentList
                
//                data.result.childCommentList.map({ data in
//                    self.childCommentDataList.append(data)
//                })
                
                self?.commentVC.childCommentCntList[section] += data.result.childCommentList.count
                print("\(section)번째 부모의 자식 댓글 개수: \(self?.commentVC.childCommentCntList[section])")
                
                // 제대로 된 자리에 대댓글 리스트를 삽입하기 위해서 지금까지 있는 대댓글 개수 세야 함
                var childCommentsSoFar = 0
                if(section != 0) {
                    for index in 0...section - 1 {
                        childCommentsSoFar += self!.commentVC.childCommentCntList[index]
                    }
                }
                // 대댓글 마지막 페이지 bool값 갱신 -> footer 생성에 관여함
                self?.commentVC.parentAndChildCommentList?[section].childCommentPageInfo.lastPage =                 data.result.childCommentPageInfo.lastPage
                
                // 대댓글 리스트에 새로 받아온 대댓글 추가하기
                self?.commentVC.parentAndChildCommentList?[section].childCommentList.append(contentsOf: data.result.childCommentList)
                
                // 여기서 다시 되길...
                self?.commentVC.toUICommentData()
                
                self?.commentVC.tableView.reloadSections(IndexSet(integer: section), with: .fade)
                print("==uicommentlist==")
                print(self?.commentVC.uiCommentList)
            }
            else {
                self?.commentVC.present(UIAlertController.networkErrorAlert(title: "대댓글 더 불러오기를 실패하였습니다."), animated: true)
            }
        }
    }
}
