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
}
