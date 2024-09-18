//
//  CommentService.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/19/24.
//

import Foundation

struct CommentService {
    
    /// 게시글의 댓글을 조회합니다.
    /// - Parameters:
    ///   - postId: 댓글을 조회하려는 게시글의 아이디
    ///   - page: 조회하려는 댓글 페이지 번호
    ///   - completion: 핸들러
    static func getComments(
        postId: Int,
        page: Int,
        completion: @escaping (_ succeed: CommentGetResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(CommentAPI.getComments(postId: postId, page: page)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getComments service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 게시글 댓글의 자식 댓글을 조회합니다.
    /// - Parameters:
    ///   - postId: 댓글을 조회하려는 게시글 아이디
    ///   - commentId: 대댓글을 조회하려는 부모 댓글 아이디
    ///   - page: 조회하려는 대댓글의 페이지
    ///   - completion: 핸들러
    static func getChildComments(
        postId: Int,
        commentId: Int,
        page: Int,
        completion: @escaping (_ succeed: ChildCommentGetResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(ChildCommentAPI.getChildComments(postId: postId, 
                                                                           commentId: commentId,
                                                                           page: page)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getChildComments service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 새로운 댓글 혹은 대댓글을 등록합니다.
    /// - Parameters:
    ///   - postId: 댓글 혹은 대댓글을 등록하려는 게시글 아이디
    ///   - content: 댓글 혹은 대댓글 내용
    ///   - parentCommentId: (대댓글인 경우만) 부모 댓글 아이디 (댓글 등록인 경우 nil 전달)
    ///   - completion: 핸들러
    static func postNewComment(
        postId: Int,
        content: String,
        parentCommentId: Int?,
        completion: @escaping (_ succeed: CommentPostResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(CommentPostAPI.postNewComment(postId: postId, 
                                                                        request: CommentPostRequest(content: content, parentCommentId: parentCommentId))
            ) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postNewComment service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 댓글을 삭제합니다.
    /// - Parameters:
    ///   - postId: 삭제하려는 댓글이 달려있는 게시글 아이디
    ///   - commentId: 삭제하려는 댓글의 아이디
    ///   - completion: 핸들러
    static func deleteComment(
        postId: Int,
        commentId: Int,
        completion: @escaping (_ succeed: CommentDeleteResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(CommentDeleteAPI.deleteComment(postId: postId, commentId: commentId)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== deleteComment service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
