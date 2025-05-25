//
//  CommentViewModel.swift
//  pochak
//
//  Created by Suyeon Hwang on 5/7/25.
//

import UIKit

final class CommentViewModel {
    
    // MARK: - Properties
    
    private var commentData: CommentDataResult? {
        didSet {
            commentDataDidChange?(commentData)
        }
    }
    
    private var uploadCommentResponseData: CommentPostResponse? {
        didSet {
            uploadCommentResponseDataDidChange?(uploadCommentResponseData)
        }
    }
        
    private var deleteCommentResponseData: CommentDeleteResponse? {
        didSet {
            deleteCommentResponseDataDidChange?(deleteCommentResponseData)
        }
    }
    
    var commentDataDidChange: ((CommentDataResult?) -> Void)?
    var uploadCommentResponseDataDidChange: ((CommentPostResponse?) -> Void)?
    var deleteCommentResponseDataDidChange: ((CommentDeleteResponse?) -> Void)?
    
    // MARK: - Functions
    
    /// CommentService를 통해 postId 게시물의 page번째 페이지 댓글을 조회하는 메소드입니다.
    /// - Parameters:
    ///   - postId: 조회하고자 하는 댓글리스트가 속한 게시물 아이디
    ///   - page: 조회하고자 하는 댓글 리스트 페이지
    ///   - fromCurrentVC: 현재 요청을 보내는 뷰컨트롤러
    func fetchCommentData(postId: Int, page: Int, fromCurrentVC: UIViewController) {
        CommentService.getComments(postId: postId, page: page, sort: .createDateAsc) { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "댓글 조회에 실패하였습니다."), animated: true)
                }
                return
            }
            
            if !data.isSuccess {
                fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "댓글 조회에 실패하였습니다."), animated: true)
                return
            }
            
            print("=== [CommentViewModel] fetchCommentData succeeded ===")
            print("== data: \(data)")
            
            self?.commentData = data.result
        }
    }
    
    /// CommentService를 통해 postId 게시물에 댓글 혹은 대댓글을 업로드하는 메소드입니다.
    /// - Parameters:
    ///   - postId: 댓글 혹은 대댓글을 달고자 하는 게시물의 postId
    ///   - content: 댓글 혹은 대댓글 내용
    ///   - parentCommentId: 대댓글인 경우 부모댓글 id, 댓글인 경우에는 nil값을 전달합니다
    ///   - fromCurrentVC: 현재 요청을 보내는 뷰컨트롤러
    func uploadNewComment(postId: Int, content: String, parentCommentId: Int?, fromCurrentVC: UIViewController) {
        CommentService.postNewComment(postId: postId, content: content, parentCommentId: parentCommentId) { [weak self] data, failed in
            guard let data = data else {
                switch failed {
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "댓글 등록에 실패하였습니다."), animated: true)
                }
                return
            }

            print("=== [CommentViewModel] uploadNewComment succeeded ===")
            print("== data: \(data)")

            // 만약 실패한 경우 실패했다고 알림창
            if !data.isSuccess {
                fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "댓글 등록에 실패하였습니다."), animated: true)
                return
            }
            
            self?.uploadCommentResponseData = data
        }
    }
    
    /// CommentService를 사용해 댓글을 삭제하는 메소드입니다.
    /// - Parameters:
    ///   - postId: 삭제하려는 댓글이 달린 게시물의 postId
    ///   - commentId: 댓글의 commentId
    ///   - fromCurrentVC: 현재 요청을 보내는 뷰컨트롤러
    func deleteComment(postId: Int, commentId: Int, fromCurrentVC: UIViewController) {
        CommentService.deleteComment(postId: postId, commentId: commentId) { [weak self] data, failed in
            guard let data = data else {
                // 에러가 난 경우, alert 창 present
                switch failed {
                case .disconnected:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                case .serverError:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: failed!.localizedDescription), animated: true)
                default:
                    fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "댓글 삭제에 실패하였습니다."), animated: true)
                }
                return
            }

            print("=== [CommentViewModel] deleteComment succeeded ===")
            print("== data: \(data)")

            if !data.isSuccess {
                fromCurrentVC.present(UIAlertController.networkErrorAlert(title: "댓글 삭제에 실패하였습니다."), animated: true)
            }

            self?.deleteCommentResponseData = data
        }
    }
}
