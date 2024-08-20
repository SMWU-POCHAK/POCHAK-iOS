//
//  PostService.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

import Foundation

struct PostService {
    
    /// 게시글 상세 내용을 조회합니다.
    /// - Parameters:
    ///   - postId: 상세 조회하고자 하는 게시글 아이디
    ///   - completion: 핸들러
    static func getPostDetail(
        postId: Int,
        completion: @escaping (_ succeed: PostDetailResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(PostDetailAPI.getPostDetail(postId)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== getPostDetail service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 게시글을 삭제합니다.
    /// - Parameters:
    ///   - postId: 삭제하려는 게시글 아이디
    ///   - completion: 핸들러
    static func deletePostDetail(
        postId: Int,
        completion: @escaping (_ succeed: PostDeleteResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(PostDeleteAPI.deletePostDetail(postId)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== deletePostDetail service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
    }
    
    /// 게시글을 신고합니다.
    /// - Parameters:
    ///   - reportRequest: 게시글 신고 요청에 필요한 body (게시글 아이디, 신고 사유)
    ///   - completion: 핸들러
    static func postReportPost(
        reportRequest: PostReportRequest,
        completion: @escaping (_ succeed: PostReportResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(PostReportAPI.postReportPost(reportRequest)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postReportPost service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
    
    /// 게시글에 좋아요를 누르거나 취소합니다.
    /// - Parameters:
    ///   - postId: 좋아요를 누르거나 취소하려는 게시글 아이디
    ///   - completion: 핸들러
    static func postLikePost(
        postId: Int,
        completion: @escaping (_ succeed: PostLikeResponse?, _ failed: NetworkError?) -> Void) {
            
            NetworkService.shared.request(PostLikeAPI.postLikePost(postId)) { response in
                switch response {
                case .success(let data):
                    completion(data, nil)
                case .failure(let error):
                    print("=== postLikePost service error ===")
                    print(error.localizedDescription)
                    completion(nil, error)
                }
            }
        }
}
