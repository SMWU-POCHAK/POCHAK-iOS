//
//  CommentTableViewFooterView.swift
//  pochak
//
//  Created by Suyeon Hwang on 1/13/24.
//

import UIKit

class CommentTableViewFooterView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    var commentVC: CommentViewController!
    var postId: Int!
    var curCommentId: Int!

    private var childCommentDataResponse: ChildCommentDataResponse!
    private var childCommentDataList: [ChildCommentData]!
    private var tempChildCommentList = [ChildCommentData]()
    
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
        
        // indexPath를 이용해 data[indexPath.row]를 삭제
        //commentVC.commentDataList?[indexPath.section].recentComment = nil
        
        //commentVC.tableView.
        //tableView.footerView(forSection: indexPath.section) = nil
        //tableView.deleteRows(at: [indexPath], with: .automatic) //4
        
        loadChildCommentData(indexPath.section)
        
        //        commentVC.tableView.reloadData()
        print("---대댓글 보기 버튼 삭제---")
    }
    
    // section은 대댓글을 조회하고자 하는 댓글의 섹션 번호
    private func loadChildCommentData(_ section: Int){
        print("=== load child comment data ===")
        
        CommentDataService.shared.getChildComments(self.postId, self.curCommentId, page: 0) { response in
            switch(response) {
            case .success(let childCommentDataResponse):
                self.childCommentDataResponse = childCommentDataResponse as? ChildCommentDataResponse
                if self.childCommentDataResponse.isSuccess == true {
                    self.childCommentDataList = self.childCommentDataResponse?.result.childCommentList
                    
                    self.tempChildCommentList.removeAll()
                    
                    //                for data in self.childCommentDataList!{
                    //                    //print("child comment data:")
                    //                    //print(data)
                    //
                    //                    self.tempChildCommentList.append(UICommentData(commentId: data.commentId, profileImage: data.profileImage, handle: data.handle, createdDate: data.createdDate, content: data.content, isParent: false))
                    //                }
                    
                    self.commentVC.childCommentCntList[section] += self.tempChildCommentList.count
                    
                    // 제대로 된 자리에 대댓글 리스트를 삽입하기 위해서 지금까지 있는 대댓글 개수 세야 함
                    var childCommentsSoFar = 0
                    if(section != 0){
                        for index in 0...section - 1 {
                            childCommentsSoFar += self.commentVC.childCommentCntList[index]
                        }
                    }
                    // 대댓글 마지막 페이지 bool값 갱신 -> footer 생성에 관여함
                    self.commentVC.commentDataResult?.parentCommentList[section].childCommentPageInfo.lastPage =                 self.childCommentDataResponse.result.childCommentPageInfo.lastPage
                    
                    // 대댓글 리스트에 새로 받아온 대댓글 추가하기
                    self.commentVC.commentDataResult?.parentCommentList[section].childCommentList.append(contentsOf: self.childCommentDataList)
                    
                    //self.commentVC.tableView.reloadData()
                    
                    // 여기서 다시 되길...
                    self.commentVC.toUICommentData()
                    
                    self.commentVC.tableView.reloadSections(IndexSet(integer: section), with: .fade)
                    print("==uicommentlist==")
                    print(self.commentVC.uiCommentList)
                }
                else {
                    self.commentVC.present(UIAlertController.networkErrorAlert(title: "대댓글 불러오기에 실패하였습니다."), animated: true)
                }
            case .requestErr(let message):
                print("requestErr", message)
            case .pathErr:
                print("pathErr")
            case .serverErr:
                print("serverErr")
                self.commentVC.present(UIAlertController.networkErrorAlert(title: "서버에 문제가 있습니다."), animated: true)
            case .networkFail:
                print("networkFail")
                self.commentVC.present(UIAlertController.networkErrorAlert(title: "네트워크 연결에 문제가 있습니다."), animated: true)
            }
        }
    }
}
