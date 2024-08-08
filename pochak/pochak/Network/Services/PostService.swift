//
//  PostService.swift
//  pochak
//
//  Created by Suyeon Hwang on 8/8/24.
//

import Foundation

struct PostService {
    
    /// 게시글 상세 데이터 조회하기
    /// - Parameters:
    ///   - postId: 상세 조회하고자 하는 게시글 아이디
    ///   - completion: 핸들러 (뷰컨트롤러에 있음
    static func getPostDetail(
        postId: Int,
        completion: @escaping (_ succeed: PostDetailResponse?, _ failed: NetworkError?) -> Void) {
            NetworkService.shared.request(PostAPI.getPostDetail(postId)) { response in
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
    
    /// 게시글 삭제하기
    /// - Parameters:
    ///   - postId: 삭제하려는 게시글 아이디
    ///   - completion: 핸들러 (뷰컨트롤러에 있음)
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
    
    /// 게시글 신고하기
    /// - Parameters:
    ///   - reportRequest: 게시글 신고 요청에 필요한 body (게시글 아이디, 신고 사유)
    ///   - completion: 통신 후 핸들러 (뷰컨트롤러에 있음)
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
}
