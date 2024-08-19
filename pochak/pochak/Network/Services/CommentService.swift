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
}